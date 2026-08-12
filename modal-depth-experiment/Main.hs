module Main where

import Types
import Experiment
import Metrics
import Control.Monad (replicateM)

{- Setting each modal depth through modeset -}
unimodal = ModeSet True False False False
bimodal  = ModeSet True True False False
trimodal = ModeSet True True True False
quadmodal = ModeSet True True True True

{-This section defines how the simulation is run-}
main :: IO ()
main = do
    {- Run the modal depth simulation (can be changed). The number of scenarios to generate-}
    results <- replicateM 100 (runSimulation quadmodal 10000)

    let combinedResults = concat results

    print (accuracy combinedResults)
    print (countFP combinedResults)
    print (countFN combinedResults)
    --remove these and test how fast the system actually is
    --do this for system optimized haskell and system optimized rust
    --this will show us how fast the system actually is.
    --This is needed as a final note to show how fast the system actually is and how fast the system can actually be to make sure the core logic of the system is actually 100% (including speed).
    
