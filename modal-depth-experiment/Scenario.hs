module Scenario where
import Types (Scenario(..), Action(..), SpecificThreshold(..))
import Text.Read (readMaybe)
import Policy (specificThreshold)
import System.IO (IOMode(WriteMode), hPutStrLn, withFile)
import Text.Printf (printf)

scenarioContext :: Double
scenarioContext = 0.1

scenarioCount :: Int
scenarioCount = 1000000

unidentifiedScenarioValues :: [Double]
unidentifiedScenarioValues = [4.125, 4.500, 4.875, 5.250, 5.625, 6.000, 6.375, 6.750]

scenarioCsvHeader :: String
scenarioCsvHeader = "d_a,d_e,d_c,d_s,expected_action"

loadScenarioCases :: IO [(Scenario, Action)]
loadScenarioCases = do
    contents <- readFile "ScenarioInputs.csv"
    case lines contents of
        header:rows
            | header == scenarioCsvHeader -> do
                cases <- either (ioError . userError) return
                    (traverse (uncurry parseScenarioRow) (zip [2..] rows))
                if length cases == scenarioCount
                    then return cases
                    else ioError (userError ("Expected " ++ show scenarioCount ++ " scenario rows, found " ++ show (length cases)))
            | otherwise -> ioError (userError "ScenarioInputs.csv has an unexpected header")
        [] -> ioError (userError "ScenarioInputs.csv is empty")

parseScenarioRow :: Int -> String -> Either String (Scenario, Action)
parseScenarioRow rowNumber row =
    case splitCsvRow row of
        [valueA, valueE, valueC, valueS, expectedText] -> do
            modalityA <- parseModality "d_a" valueA
            modalityE <- parseModality "d_e" valueE
            modalityC <- parseModality "d_c" valueC
            modalityS <- parseModality "d_s" valueS
            expected <- case expectedText of
                "ACT" -> Right ACT
                "NO_ACT" -> Right NO_ACT
                _ -> Left (rowError "expected_action must be ACT or NO_ACT")
            return
                ( Scenario scenarioContext modalityA modalityE modalityC modalityS scenarioContext
                , expected
                )
        _ -> Left (rowError "expected five comma-separated fields")
  where
    rowError message = "ScenarioInputs.csv row " ++ show rowNumber ++ ": " ++ message
    parseModality name valueText =
        case (readMaybe valueText :: Maybe Double) of
            Just value
                | not (isNaN value || isInfinite value) && value >= 0.0 && value <= 10.0 -> Right value
            _ -> Left (rowError (name ++ " must be a number between 0 and 10"))

splitCsvRow :: String -> [String]
splitCsvRow row =
    case break (== ',') row of
        (field, []) -> [field]
        (field, _:remaining) -> field : splitCsvRow remaining

generateScenarios :: Int -> IO [(Scenario, Action, Bool)]
generateScenarios n = do
    cases <- loadScenarioCases
    let count = min scenarioCount (max 0 n)
    return
        [ (scenario, expected, index >= 660000)
        | (index, (scenario, expected)) <- zip [0..] (take count cases)
        ]

writeScenarioInputs :: FilePath -> IO ()
writeScenarioInputs path = withFile path WriteMode $ \handle -> do
    hPutStrLn handle scenarioCsvHeader
    mapM_ (hPutStrLn handle . renderScenarioRow) [0 .. scenarioCount - 1]

renderScenarioRow :: Int -> String
renderScenarioRow index =
    let threshold = specificThreshold
        values
          | index < 330000 =
              insertAt (index `mod` 4)
                (highValues threshold !! (index `mod` length (highValues threshold)))
                (takeRotated 3 (lowValues threshold) (index * 3))
          | index < 660000 = takeRotated 4 (lowValues threshold) (index * 4)
          | index < 830000 =
              insertAt ((index - 660000) `mod` 4)
                (unidentifiedScenarioValues !! ((index - 660000) `mod` length unidentifiedScenarioValues))
                (takeRotated 3 (lowValues threshold) ((index - 660000) * 3))
          | otherwise = takeRotated 4 unidentifiedScenarioValues ((index - 830000) * 4)
        expected
          | index < 330000 = "ACT"
          | index < 660000 = "NO_ACT"
          | index `mod` 2 == 0 = "ACT"
          | otherwise = "NO_ACT"
    in joinWithComma (map (printf "%.3f") values ++ [expected])

takeRotated :: Int -> [a] -> Int -> [a]
takeRotated count values offset = take count (drop (offset `mod` length values) (cycle values))

insertAt :: Int -> a -> [a] -> [a]
insertAt index value values =
    take index values ++ [value] ++ drop index values

joinWithComma :: [String] -> String
joinWithComma [] = ""
joinWithComma [value] = value
joinWithComma (value:remaining) = value ++ "," ++ joinWithComma remaining