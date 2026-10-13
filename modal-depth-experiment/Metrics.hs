module Metrics where

import Types (Result(..), Action(..))
import Evaluate (falsePositive, falseNegative)

accuracy :: [Result] -> Double
accuracy = accuracyWhere (const True)

accuracyForExpected :: Action -> [Result] -> Double
accuracyForExpected expected = accuracyWhere matchesExpected
    where
        matchesExpected result = not (uncertain result) && expectedAction result == expected

accuracyForUncertain :: [Result] -> Double
accuracyForUncertain = accuracyWhere uncertain

-- First 66% only: expected ACT and NO_ACT. Uncertain-zone scenarios are not scored.
accuracyForSpecification :: [Result] -> Double
accuracyForSpecification = accuracyWhere (not . uncertain)

accuracyWhere :: (Result -> Bool) -> [Result] -> Double
accuracyWhere include results =
    let selected = filter include results
        total = length selected
        correctCount = length (filter correct selected)
    in if total == 0 then 0.0 else fromIntegral correctCount / fromIntegral total

countScored :: [Result] -> Int
countScored = length . filter (not . uncertain)

countFP :: [Result] -> Int
countFP = length . filter falsePositive

countFN :: [Result] -> Int
countFN = length . filter falseNegative

countUncertainAct :: [Result] -> Int
countUncertainAct = length . filter isUncertainAct
    where
        isUncertainAct result = uncertain result && action result == ACT

countUncertainNoAct :: [Result] -> Int
countUncertainNoAct = length . filter isUncertainNoAct
    where
        isUncertainNoAct result = uncertain result && action result == NO_ACT

countExpected :: Action -> [Result] -> Int
countExpected expected = length . filter matchesExpected
    where
        matchesExpected result = not (uncertain result) && expectedAction result == expected