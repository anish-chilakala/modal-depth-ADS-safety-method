module Evaluate where

import Types ( Action(..), ModeSet(..), Scenario(..), Result(..) )
import Policy ( policy, weightA, weightE, weightC, weightS, policy, high_danger )

--The evaluator can also use hysteresis. This is probably the more accurate method for testing how the system performs in more relation to real world contexts.
processScenario :: ModeSet -> Scenario -> Result
processScenario modeset scenario =
    let action = Policy.policy scenario
        correct = (action == ACT && (observed_context scenario >= 0.55 && observed_context scenario <= 10)) || (action == NO_ACT && (observed_context scenario < 1.0)) || (action == NO_ACT && (observed_context scenario >= 1.0 && observed_context scenario < 5.5))
    in Result action correct
--For the ground truth evaluator, replace the observed_context scenario in the process scenario block to c scenario.

falsePositive :: Result -> Bool
falsePositive r = action r == ACT && not (correct r)

falseNegative :: Result -> Bool
falseNegative r = action r == NO_ACT && not (correct r)

--I have realized that the problem was epistemic uncertainty, and that the way the evaluator has been constructed was wrong all along.
--The system has to be evaluated based on what the system can see, and the data the system can see is the observed_context. 
--This means the system gets 100% accuracy in architectural evaluation and core logic evaluation and it is ready to be used as a real safety enforcement method in real systems.
--the evaluator has to be molded to fit real world standards except using what the system can see
--So if in real life the danger level has to be 0.5 or above to pass, than this evaluator has to match that in terms of what the system can see.
--This is the first prototype, this will not be as picture perfect as what is seen in a real life system, this is a usable prototype for enforcing safety endogenously, now when research comes about epistemic uncertainty and etc., this method will have to be modified.
