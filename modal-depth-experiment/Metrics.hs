module Metrics where

import Types
import Evaluate

accuracy :: [Result] -> Double
accuracy results =
    let total = length results
        correctCount = length (filter correct results)
    in fromIntegral correctCount / fromIntegral total

countFP :: [Result] -> Int
countFP = length . filter falsePositive

countFN :: [Result] -> Int
countFN = length . filter falseNegative