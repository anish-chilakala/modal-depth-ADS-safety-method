module Experiment where

import Types
import Scenario
import Evaluate

runSimulation :: ModeSet -> Int -> IO [Result]
runSimulation modeset n =
    fmap (map (processScenario modeset)) (Scenario.generateScenarios n)


-- Provide a local fallback for generateScenarios in case it's not
-- exported from the Scenario module. This returns an empty list of
-- scenarios for the requested count.
generateScenarios :: Int -> IO [Scenario]
generateScenarios _ = return [] 