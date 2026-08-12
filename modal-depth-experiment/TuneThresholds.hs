module Main where

import Types
import Scenario
import Policy
import System.Environment (getArgs)
import Control.Monad (when)
import Data.List (sortOn)
import Data.Ord (Down(..))
import Text.Printf (printf)

data Modality = ModA | ModE | ModC | ModS deriving (Eq, Show)

data Bucket = BucketHigh | BucketMid | BucketLow deriving (Eq, Show, Ord)

bucketOf :: Scenario -> Bucket
bucketOf s
  | observed_context s >= 0.55 = BucketHigh
  | observed_context s >= 0.1  = BucketMid
  | otherwise                  = BucketLow

modLabel :: Modality -> String
modLabel ModA = "A"
modLabel ModE = "E"
modLabel ModC = "C"
modLabel ModS = "S"

modValue :: Modality -> Scenario -> Double
modValue ModA = d_a
modValue ModE = d_e
modValue ModC = d_c
modValue ModS = d_s

unimodalAction :: Modality -> Double -> Scenario -> Action
unimodalAction modality thr scenario =
    case modality of
        ModS -> if modValue modality scenario <= thr then ACT else NO_ACT
        _    -> if modValue modality scenario >= thr then ACT else NO_ACT

correctAction :: Action -> Scenario -> Bool
correctAction ACT scenario = observed_context scenario >= 5.5 && observed_context scenario <= 10
correctAction NO_ACT scenario = observed_context scenario < 5.5

type Metrics = (Double, Int, Int)

evaluateThreshold :: Modality -> Double -> [Scenario] -> Metrics
evaluateThreshold modality thr scenarios =
    let results = map (unimodalAction modality thr) scenarios
        correctCount = length $ filter (\(act, sc) -> correctAction act sc) (zip results scenarios)
        total = length scenarios
        falsePos = length $ filter (\(act, sc) -> act == ACT && not (correctAction act sc)) (zip results scenarios)
        falseNeg = length $ filter (\(act, sc) -> act == NO_ACT && not (correctAction act sc)) (zip results scenarios)
        acc = if total == 0 then 0 else fromIntegral correctCount / fromIntegral total
    in (acc, falsePos, falseNeg)

bucketName :: Bucket -> String
bucketName BucketHigh = "High (observed_context >= 0.55)"
bucketName BucketMid  = "Mid  (0.10 <= observed_context < 0.55)"
bucketName BucketLow  = "Low  (observed_context < 0.10)"

clamp01 :: Double -> Double
clamp01 x = max 0.0 (min 1.0 x)

rangeAround :: Double -> Double -> Double -> [Double]
rangeAround center radius step =
    let start = clamp01 (center - radius)
        end = clamp01 (center + radius)
        mk i = clamp01 (start + step * fromIntegral i)
        n = floor ((end - start) / step + 0.5)
    in [ mk i | i <- [0 .. n] ]

bestThresholdForBucket :: Bucket -> Modality -> [Scenario] -> IO (Double, Metrics)
bestThresholdForBucket _ modality bucketScenarios = do
    let stage1 = [0.0,0.01..1.0]
        evaluateList values = [ (thr, evaluateThreshold modality thr bucketScenarios) | thr <- values ]
        chooseBest = maximumOn (\t -> let (acc, _, _) = snd t in acc)
        (bestThr1, _) = chooseBest (evaluateList stage1)
        (bestThr2, _) = chooseBest (evaluateList (rangeAround bestThr1 0.02 0.001))
        best3 = chooseBest (evaluateList (rangeAround bestThr2 0.005 0.0001))
    return best3

maximumOn :: Ord b => (a -> b) -> [a] -> a
maximumOn f = head . sortOn (Down . f)

printBest :: Bucket -> Modality -> (Double, Metrics) -> IO ()
printBest bucket modality (thr, (acc, fp, fn)) = do
    printf "%-6s | %-10s | threshold = %.6f | accuracy = %.6f | FP = %d | FN = %d\n"
        (bucketName bucket)
        (modLabel modality)
        thr
        acc
        fp
        fn

collectBuckets :: [Scenario] -> [(Bucket, [Scenario])]
collectBuckets scenarios =
    [ (BucketHigh, filter ((== BucketHigh) . bucketOf) scenarios)
    , (BucketMid,  filter ((== BucketMid)  . bucketOf) scenarios)
    , (BucketLow,  filter ((== BucketLow)  . bucketOf) scenarios)
    ]

main :: IO ()
main = do
    args <- getArgs
    let n = case args of
            (x:_) -> read x
            _     -> 200000
    putStrLn $ "Generating " ++ show n ++ " scenarios..."
    scenarios <- generateScenarios n
    let buckets = collectBuckets scenarios
    mapM_ (\(bucket, bucketScenarios) -> do
        putStrLn $ "\nBucket: " ++ bucketName bucket ++ " (" ++ show (length bucketScenarios) ++ " examples)"
        when (null bucketScenarios) $ putStrLn "  WARNING: no scenarios in this bucket"
        mapM_ (\modality -> do
            (thr, metrics) <- bestThresholdForBucket bucket modality bucketScenarios
            printBest bucket modality (thr, metrics)
            ) [ModA, ModE, ModC, ModS]
        ) buckets
    putStrLn "\nTuning complete. Use runhaskell TuneThresholds.hs <numScenarios> to change sample size."
