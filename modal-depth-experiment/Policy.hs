{- HLINT ignore "Use camelCase" -}
module Policy where

import Types (Scenario(d_a, d_e, d_c, d_s, observed_context), Action(..))
import qualified Types as ACT

-- Stochastic Noise Filters need to be implemented for the observed_context to filter out the noise variations to get past the 95% accuracy and overcome the 5% bottleneck.
-- If this stochastic noise filter is implemented properly, it should get the accuracy to 100% and it wil be a perfectly viable option for formal verfication endogenous systems.
-- This is the problem I can think of, if this isn't the case, then it might be a new discovery in this field of research.

{- thresholds :: Scenario -> (Double, Double, Double, Double)
thresholds scenario
  | observed_context scenario >= 0.55 = (0.0, 0.0, 0.0, 0.55)
  | observed_context scenario >= 0.1 = (0.5537, 0.5417, 0.5016, 0.57410)
  | otherwise = (0.1393, 0.0501, 0.0631, 0.0) -}

--Right now, the thresholds are very simple because there is no stochastic noise in the way of the measurment and the accuracy, so the thresholds can be simple to prove the core logic of the system right.
--In the architectural evaluator that evaluates whether the architecture of the system is structurally correct, the thresholds in the way it is right now need to be ultra precise hyperparamters to overcome the most stochastic noise variations.
--This does not mean the noise is the problem, it is a suggestion of a possiblity of why the system is unable to overcome a 5% bottleneck.
--The system has been tested as a whole without removing anything because doing that would compromise the results of the cre logic evaluation test.
thresholds :: Scenario -> (Double, Double, Double, Double)
thresholds scenario
  | observed_context scenario >= 0.55 = (0.0, 0.0, 0.0, 0.0)
  | observed_context scenario >= 0.1 && observed_context scenario < 0.55 = (1.0, 1.0, 1.0, 0.0)
  | otherwise = (1.0, 1.0, 1.0, 0.0)

thresholdA :: Scenario -> Double
thresholdA scenario = let (a,_,_,_) = thresholds scenario in a
thresholdE :: Scenario -> Double
thresholdE scenario = let (_,e,_,_) = thresholds scenario in e
thresholdC :: Scenario -> Double
thresholdC scenario = let (_,_,c,_) = thresholds scenario in c
thresholdS :: Scenario -> Double
thresholdS scenario = let (_,_,_,s) = thresholds scenario in s

clamp :: Double -> Double
clamp x = max 0.0 (min 1.0 x)

high_danger :: Scenario -> (Bool, Bool, Bool, Bool)
high_danger scenario =
  (d_a scenario >= thresholdA scenario,
  d_e scenario >= thresholdE scenario,
  d_c scenario >= thresholdC scenario,
  d_s scenario <= thresholdS scenario)

low_danger :: Scenario -> (Bool, Bool, Bool, Bool)
low_danger scenario =
  (d_a scenario < thresholdA scenario,
  d_e scenario < thresholdE scenario,
  d_c scenario < thresholdC scenario,
  d_s scenario > thresholdS scenario)

weightA :: Integer
weightA = 2
weightE :: Integer
weightE = 3
weightC :: Integer
weightC = 4
weightS :: Integer
weightS = 4

policy :: Scenario -> Action
policy scenario =
  let
      (highA, highE, highC, highS) = high_danger scenario
      (lowA, lowE, lowC, lowS) = low_danger scenario

      high_danger_score = ((if highA then weightA else 0) + (if highE then weightE else 0) + (if highC then weightC else 0) + (if highS then weightS else 0))
      low_danger_score  = (if lowA then weightA else 0) + (if lowE then weightE else 0) + (if lowC then weightC else 0) + (if lowS then weightS else 0)

      override =  observed_context scenario >= 0.55

  in if override || high_danger_score > low_danger_score
     then ACT
     else NO_ACT

--regardless of threshold values, the observed_context evaluator wont have a change in accuracy because of the override function.
--so if you want to test the policy with the observed_context evaluator you have to remove the override function so it doesn't overpower the tri-threshold system.