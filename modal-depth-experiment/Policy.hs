{- HLINT ignore "Use camelCase" -}
module Policy where

import Data.List (sort, sortOn)
import Types (Scenario(d_a, d_e, d_c, d_s), Action(..), SpecificThreshold(..), DangerState(..), PolicyState(..), ProbabilityTrace(..))

specificThreshold :: SpecificThreshold
specificThreshold = SpecificThreshold
  { highValues = [7.125, 7.750, 8.125, 8.625, 9.000, 9.375, 9.625, 9.875, 7.375, 7.875, 8.375, 8.875, 9.125, 9.500, 9.750, 9.250]
  , lowValues = [0.125, 0.375, 0.625, 0.875, 1.125, 1.375, 1.625, 1.875, 2.125, 2.375, 2.625, 2.875, 3.125, 3.375, 3.625, 3.875]
  }

classify :: SpecificThreshold -> Double -> DangerState
classify threshold value
  | value `elem` highValues threshold = HighDanger
  | value `elem` lowValues threshold = LowDanger
  | otherwise = UncertainZone

classifyForSafety :: SpecificThreshold -> Double -> DangerState
classifyForSafety threshold value =
  case classify threshold value of
    UncertainZone -> HighDanger
    danger -> danger

initialPolicyState :: PolicyState
initialPolicyState = PolicyState UncertainZone UncertainZone UncertainZone UncertainZone

updateStates :: PolicyState -> Scenario -> PolicyState
updateStates _ scenario = PolicyState
  { stateA = classifyForSafety specificThreshold (d_a scenario)
  , stateE = classifyForSafety specificThreshold (d_e scenario)
  , stateC = classifyForSafety specificThreshold (d_c scenario)
  , stateS = classifyForSafety specificThreshold (d_s scenario)
  }

softmax :: [Double] -> [Double]
softmax logits =
  let maximumLogit = maximum logits
      weights = map (exp . subtract maximumLogit) logits
      totalWeight = sum weights
  in map (\weight -> weight * 100.0 / totalWeight) weights

maximumIndex :: [(Int, Double)] -> Int
maximumIndex [] = 0
maximumIndex ((firstIndex, firstValue):remaining) =
  fst (foldl choose (firstIndex, firstValue) remaining)
  where
    choose best@(_, bestValue) candidate@(_, candidateValue)
      | candidateValue > bestValue = candidate
      | otherwise = best

normalize :: [Double] -> [Double]
normalize values =
  let total = sum values
  in map (\value -> value * 100.0 / total) values

assignProbabilities :: Int -> [(Int, Double)] -> [Double]
assignProbabilities count assignments =
  [ maybe 0.0 id (lookup index assignments)
  | index <- [0 .. count - 1]
  ]

rerouteProbabilities :: [Double] -> Int -> Int -> [Double]
rerouteProbabilities probabilities dangerousIndex safeIndex =
  let orderedProbabilities = sort probabilities
      middleProbabilities = take (length probabilities - 2) (drop 1 orderedProbabilities)
      remainingIndices = sortOn (probabilities !!)
        [index | index <- [0 .. length probabilities - 1], index /= dangerousIndex, index /= safeIndex]
      assignments = (dangerousIndex, head orderedProbabilities)
        : (safeIndex, last orderedProbabilities)
        : zip remainingIndices middleProbabilities
  in normalize (assignProbabilities (length probabilities) assignments)

fixedNoOpLogit :: Double
fixedNoOpLogit = case lowValues specificThreshold of
  value:_ -> value
  [] -> 0.0

injectNoOpProbabilities :: [Double] -> [Double]
injectNoOpProbabilities logits =
  let injectedProbabilities = softmax (logits ++ [fixedNoOpLogit])
      orderedProbabilities = sort injectedProbabilities
      existingCount = length logits
      existingIndices = sortOn (injectedProbabilities !!) [0 .. existingCount - 1]
      assignments = zip existingIndices (take existingCount orderedProbabilities)
        ++ [(existingCount, last orderedProbabilities)]
  in normalize (assignProbabilities (existingCount + 1) assignments)

execute :: PolicyState -> [Double] -> (Action, [Double], [Double], Double)
execute states logits =
  let labels = [stateA states, stateE states, stateC states, stateS states]
      probabilities = softmax logits
      winner = maximumIndex (zip [0..] probabilities)
      safeIndices =
        [ (index, probability)
        | (index, (label, probability)) <- zip [0..] (zip labels probabilities)
        , label == LowDanger
        ]
  in if labels !! winner == LowDanger
       then (NO_ACT, probabilities, probabilities, 0.0)
       else case safeIndices of
         [] ->
           let injectedProbabilities = injectNoOpProbabilities logits
           in (ACT, probabilities, take (length logits) injectedProbabilities, last injectedProbabilities)
         _ ->
           let safestIndex = maximumIndex safeIndices
           in (ACT, probabilities, rerouteProbabilities probabilities winner safestIndex, 0.0)

policy :: PolicyState -> Scenario -> (PolicyState, Action, ProbabilityTrace)
policy previousState scenario =
  let nextState = updateStates previousState scenario
      logits = [d_a scenario, d_e scenario, d_c scenario, d_s scenario]
      (action, before, after, noOp) = execute nextState logits
      trace = ProbabilityTrace before after noOp
  in (sum before + sum after + noOp) `seq` (nextState, action, trace)