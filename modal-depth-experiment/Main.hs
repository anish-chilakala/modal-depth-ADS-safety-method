-- ghc -package process -package directory -package filepath -package time -O2 -o sim_test Main.hs && ./sim_test
-- gzip -dc scenario-logs/ "the file in which you want to open up here" | less

-- highDangerValues = [7.125, 7.750, 8.125, 8.625, 9.000, 9.375, 9.625, 9.875, 7.375, 7.875, 8.375, 8.875, 9.125, 9.500, 9.750, 9.250]
-- lowDangerValues = [0.125, 0.375, 0.625, 0.875, 1.125, 1.375, 1.625, 1.875, 2.125, 2.375, 2.625, 2.875, 3.125, 3.375, 3.625, 3.875]

module Main where

import Types (ModeSet(..), Action(..), Result(uncertain))
import Experiment (runSimulation, runSafetyMethodSpeed)
import Metrics (countScored, accuracy, accuracyForExpected, accuracyForUncertain, accuracyForSpecification, countExpected, countFP, countFN, countUncertainAct, countUncertainNoAct)

{- Setting each modal depth through modeset -}
unimodal = ModeSet True False False False
bimodal  = ModeSet True True False False
trimodal = ModeSet True True True False
quadmodal = ModeSet True True True True

{-This section defines how the simulation is run-}
main :: IO ()
main = do
    (tracePath, results) <- runSimulation quadmodal 1000000

    putStrLn ("Safety trace archive: " ++ tracePath)
    print (length results)
    putStrLn "Conventional accuracy (all scenarios):"
    print (accuracy results)
    putStrLn "False positives:"
    print (countFP results)
    putStrLn "False negatives:"
    print (countFN results)
    putStrLn "Accuracy by expected outcome:"
    putStrLn "Expected ACT scenarios:"
    putStrLn "Scenario count:"
    print (countExpected ACT results)
    putStrLn "Accuracy:"
    print (accuracyForExpected ACT results)
    putStrLn "Expected NO_ACT scenarios:"
    putStrLn "Scenario count:"
    print (countExpected NO_ACT results)
    putStrLn "Accuracy:"
    print (accuracyForExpected NO_ACT results)
    putStrLn "Uncertain-zone scenarios:"
    putStrLn "Scenario count:"
    print (length (filter uncertain results))
    putStrLn "Accuracy:"
    print (accuracyForUncertain results)

    putStrLn "Specification Conformance (Did the Safety Method do what it was made to do?):"
    putStrLn "Scored scenarios:"
    print (countScored results)
    putStrLn "Accuracy:"
    print (accuracyForSpecification results)
    putStrLn "Uncertain-zone decisions:"
    putStrLn "ACT Scenarios:"
    print (countUncertainAct results)
    putStrLn "NO_ACT Scenarios:"
    print (countUncertainNoAct results)
    putStrLn "Expected: 100% specification conformance, conventional accuracy below 100%, and 340,000 ACT decisions in the uncertain zone."

    (speedCount, trialCount, meanNs, plusMinusNs) <- runSafetyMethodSpeed
    putStrLn "Safety method speed (CSV scenarios, no accuracy scoring):"
    putStrLn "Decision cycles per trial:"
    print speedCount
    putStrLn "Trials:"
    putStrLn ("N = " ++ show trialCount)
    putStrLn "Num Decision Cycles per Trial:"
    print(length results)
    putStrLn "Total Decision Cycles Count:"
    print(trialCount * length results)
    putStrLn "Average time per decision cycle:"
    putStrLn (show (round meanNs) ++ " ms ± " ++ show (round plusMinusNs) ++ " ms of cpu mutator time") 
