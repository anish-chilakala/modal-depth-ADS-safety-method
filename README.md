# modal-depth-ADS-safety-method

Sandbox Safety Method feasibility experiment for a modal-depth-based safety-enforcement method in Autonomous Decision Systems (ADS).

## Overview

This repository contains the sandbox environment used to develop and test the safety method presented in:

> **An Endogenous Modal-Depth Architecture for Safety Enforcement in Autonomous Decision Systems**

The method is designed to operate within an ADS's action pipeline. It evaluates the system's internal context through multiple modalities, applies threshold-based danger classifications, and outputs either:

- `ACT` — enforce a safety intervention
- `NO_ACT` — allow the action pipeline to proceed

The sandbox uses a noisy `observed_context` derived from hidden ground truth to model uncertainty and evaluate the feasibility of the architecture.

## Scope

This repository is a controlled feasibility experiment, not a deployment-ready ADS implementation.

The sandbox is intended for testing and modifying:

- Modal structures
- Threshold strategies
- Policy logic
- Evaluator behavior
- Uncertainty-handling approaches

Real ADS deployment requires system-specific modalities, thresholds, evaluators.

## Requirements

- GHC / Haskell
- Required Haskell libraries listed in the project files
- A laptop that turns on and works

## Running

Replace `Main.hs` if your main file has a different name:

```bash
ghc -O2 -rtsopts -fforce-recomp Main.hs -o sim_test
./sim_test +RTS -A600m -s
```

## Paper

The accompanying paper, source files, and experimental documentation are included in this repository.

## License

This project is licensed under the MIT license. Further information is listed in the LICENSE file.

## Author

Anish Chilakala  
Independent student researcher
