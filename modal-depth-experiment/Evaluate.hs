module Evaluate where

import Types ( Action(..), Scenario, Result(..), PolicyState, ProbabilityTrace )
import Policy (policy)

processScenario :: PolicyState -> (Scenario, Action, Bool) -> (PolicyState, Result, ProbabilityTrace)
processScenario previousState (scenario, expected, isUncertain) =
    let (nextState, actualAction, trace) = policy previousState scenario
    in (nextState, Result actualAction expected (actualAction == expected) isUncertain, trace)

falsePositive :: Result -> Bool
falsePositive r = action r == ACT && not (correct r)

falseNegative :: Result -> Bool
falseNegative r = action r == NO_ACT && not (correct r)

