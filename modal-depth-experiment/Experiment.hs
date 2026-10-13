module Experiment where

import Control.Exception (evaluate, onException)
import Control.Monad (foldM, replicateM)
import Data.List (intercalate, foldl')
import Data.Time (defaultTimeLocale, formatTime, getCurrentTime)
import System.Directory (createDirectoryIfMissing, removeFile)
import System.CPUTime (getCPUTime)
import System.Exit (ExitCode(..))
import System.FilePath ((</>))
import System.IO (Handle, IOMode(WriteMode), hClose, hPutStr, withBinaryFile)
import System.IO.Error (catchIOError)
import System.Process (CreateProcess(..), StdStream(CreatePipe, UseHandle), proc, waitForProcess, withCreateProcess)
import Text.Printf (printf)
import Types (ModeSet, PolicyState(..), Result(..), Scenario(..), Action, ProbabilityTrace(..))
import Scenario (generateScenarios, loadScenarioCases)
import Evaluate (processScenario)
import Policy (initialPolicyState, policy)

runSimulation :: ModeSet -> Int -> IO (FilePath, [Result])
runSimulation _ n = do
    scenarios <- generateScenarios n
    createDirectoryIfMissing True "scenario-logs"
    timestamp <- formatTime defaultTimeLocale "%Y%m%d-%H%M%S%q" <$> getCurrentTime
    let tracePath = "scenario-logs" </> ("safety-trace-" ++ timestamp ++ ".txt.gz")
    results <- writeCompressedTrace tracePath $ \traceHandle -> do
        (_, reversedResults) <- foldM (processAndTrace traceHandle) (initialPolicyState, []) (zip [0..] scenarios)
        return (reverse reversedResults)
    return (tracePath, results)

processAndTrace
    :: Handle
    -> (PolicyState, [Result])
    -> (Int, (Scenario, Action, Bool))
    -> IO (PolicyState, [Result])
processAndTrace traceHandle (previousState, results) (index, scenarioCase@(scenario, _, _)) = do
    let (nextState, result, trace) = processScenario previousState scenarioCase
    hPutStr traceHandle (renderScenarioTrace index scenario result nextState trace)
    return (nextState, result : results)

renderScenarioTrace :: Int -> Scenario -> Result -> PolicyState -> ProbabilityTrace -> String
renderScenarioTrace index scenario result states trace =
    intercalate "\n"
        [ "Scenario " ++ printf "%06d" (index + 1) ++ " (CSV row " ++ show (index + 2) ++ ")"
        , "Raw logits:"
        , renderValues [("d_a", d_a scenario), ("d_e", d_e scenario), ("d_c", d_c scenario), ("d_s", d_s scenario)]
        , "Danger classifications:"
        , renderValues [("d_a", stateA states), ("d_e", stateE states), ("d_c", stateC states), ("d_s", stateS states)]
        , "Expected action: " ++ show (expectedAction result)
        , "Uncertain zone: " ++ show (uncertain result)
        , "Probabilities before intervention:"
        , renderPercentages (beforeProbabilities trace)
        , "Safety decision: " ++ show (action result)
        , "Probabilities after intervention:"
        , renderPercentages (afterProbabilities trace)
        , "  no_op: " ++ formatPercentage (noOpProbability trace)
        , "  total: " ++ formatPercentage (sum (afterProbabilities trace) + noOpProbability trace)
        , ""
        ]

renderValues :: Show value => [(String, value)] -> String
renderValues = unlines . map (\(name, value) -> "  " ++ name ++ ": " ++ show value)

renderPercentages :: [Double] -> String
renderPercentages = unlines . map (\(name, value) -> "  " ++ name ++ ": " ++ formatPercentage value)
    . zip ["d_a", "d_e", "d_c", "d_s"]

formatPercentage :: Double -> String
formatPercentage = printf "%.6f%%"

writeCompressedTrace :: FilePath -> (Handle -> IO result) -> IO result
writeCompressedTrace tracePath writeTrace =
    writeArchive `onException` (removeFile tracePath `catchIOError` (const (return ())))
  where
    writeArchive = withBinaryFile tracePath WriteMode $ \archiveHandle ->
        withCreateProcess
            ((proc "gzip" ["-c"]) { std_in = CreatePipe, std_out = UseHandle archiveHandle })
            (\inputHandle _ _ processHandle -> do
                traceHandle <- maybe (ioError (userError "gzip did not provide an input stream")) return inputHandle
                result <- writeTrace traceHandle
                hClose traceHandle
                exitCode <- waitForProcess processHandle
                case exitCode of
                    ExitSuccess -> return result
                    ExitFailure code -> ioError (userError ("gzip exited with status " ++ show code)))

speedTrialCount :: Int
speedTrialCount = 100

-- Time only the safety method (policy) over the CSV scenarios. Accuracy
-- scoring is skipped so the result is per-decision-cycle runtime.
-- Returns (cycles per trial, trial count, mean ns/cycle, half-range ns).
runSafetyMethodSpeed :: IO (Int, Int, Double, Double)
runSafetyMethodSpeed = do
    cases <- loadScenarioCases
    let scenarios = map fst cases
    _ <- evaluate (foldl' (\() scenario -> scenario `seq` ()) () scenarios)
    perCycleNanos <- replicateM speedTrialCount (timePerCycleNanos scenarios)
    let meanNs = sum perCycleNanos / fromIntegral speedTrialCount
        plusMinusNs = (maximum perCycleNanos - minimum perCycleNanos) / 2.0
    return (length scenarios, speedTrialCount, meanNs, plusMinusNs)

timePerCycleNanos :: [Scenario] -> IO Double
timePerCycleNanos scenarios = do
    start <- getCPUTime
    let finalState = foldl' applyPolicy initialPolicyState scenarios
    _ <- evaluate (forcePolicyState finalState)
    end <- getCPUTime
    let totalSeconds = fromInteger (end - start) / 1.0e12
    return (totalSeconds / fromIntegral (length scenarios) * 1.0e9)

applyPolicy :: PolicyState -> Scenario -> PolicyState
applyPolicy previousState scenario =
    let (nextState, action, trace) = policy previousState scenario
    in action `seq` trace `seq` forcePolicyState nextState

forcePolicyState :: PolicyState -> PolicyState
forcePolicyState states =
    stateA states `seq`
    stateE states `seq`
    stateC states `seq`
    stateS states `seq`
    states