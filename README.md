# modal-depth-ADS-safety-method

Sandbox feasibility experiment for a modal-depth-based safety-enforcement method in Autonomous Decision Systems (ADSs).

## Overview

This repository contains the sandbox environment used to develop and test the safety method presented in:

> **An Endogenous Modal-Depth Architecture for Safety Enforcement in Autonomous Decision Systems**

The method is designed to operate within an ADS action pipeline. It evaluates internal system context through multiple modalities, applies threshold-based danger classifications, and produces one of two decisions:

- `ACT` — enforce a safety intervention
- `NO_ACT` — allow the action pipeline to proceed

The sandbox uses a noisy `observed_context`, derived from hidden ground truth, to model uncertainty and evaluate the feasibility of the architecture.

## Scope

This repository is a controlled feasibility experiment and is not a deployment-ready ADS implementation.

The sandbox supports experimentation with:

- Modal structures
- Threshold strategies
- Policy logic
- Evaluator behavior
- Uncertainty-handling approaches

A real ADS implementation requires system-specific modality definitions, thresholds, evaluators, and enforcement behavior.

## Requirements

You will need VS Code and one of the following development environments:

- **GHC / GHCup**, if building locally without a container
- **Docker Desktop**, if using the VS Code Dev Container
- **GitHub Codespaces** access, if using a cloud development environment

## Running the Project

### Clone the Repository

Clone the repository and check out the development branch:

```bash
git clone https://github.com/anish-chilakala/modal-depth-ADS-safety-method.git
cd modal-depth-ADS-safety-method
git fetch origin add-devcontainer-vscode-config
git checkout -b add-devcontainer-vscode-config origin/add-devcontainer-vscode-config
```

Then, choose one of the setup options below.

### Option A: Local VS Code Setup

Use this option if GHC is installed locally and you do not want to use Docker.

Open the project in VS Code:

```bash
code .
```

Build and run the project:

```bash
make build
make run
```

Alternatively, in VS Code:

1. Open the Command Palette.
2. Select **Tasks: Run Build Task** to build the project.
3. Select **Run Task** → **Run (Make)** to run the project.
4. You may also use the Run and Debug view to start the **Run Haskell executable** configuration.

### Option B: VS Code Dev Container

This is the recommended option because it provides a reproducible environment and does not require a local Haskell installation.

#### Additional requirements

- Docker Desktop
- VS Code
- The **Dev Containers** VS Code extension

Open the repository in VS Code:

```bash
code .
```

Then:

1. Install the **Dev Containers** extension if needed.
2. Open the Command Palette.
3. Select **Dev Containers: Reopen in Container**.
4. Wait for VS Code to build and configure the container.

The development container installs GHCup, GHC, Cabal, and Haskell Language Server automatically.

After setup completes, build and run the project:

```bash
make build
make run
```

### Option C: GitHub Codespaces

Use this option to develop in the cloud without installing Docker or Haskell locally.

1. Open the [repository](https://github.com/anish-chilakala/modal-depth-ADS-safety-method) in a browser.
2. Click **Code**.
3. Select **Open with Codespaces** → **New codespace**.
4. Select the `add-devcontainer-vscode-config` branch.
5. Wait for the Codespace and `.devcontainer` environment to finish configuring.

Once setup is complete, use the integrated terminal:

```bash
make build
make run
```

You can also use the VS Code Tasks interface to build and run the project.

### Option D: Open the Repository Remotely

This option is useful for quickly viewing or editing repository files, but it does not provide a full runnable development environment.

1. Install the **GitHub Repositories** extension in VS Code.
2. Open the Command Palette.
3. Select **GitHub Repositories: Open Remote Repository**.
4. Paste the repository URL:

```text
https://github.com/anish-chilakala/modal-depth-ADS-safety-method
```

To build and run the project, use Option A, B, or C.

## Troubleshooting

- The first Dev Container startup may take several minutes because the `postCreateCommand` installs Haskell tools through GHCup.
- If Haskell Language Server reports a version mismatch, wait for container setup to finish and restart the VS Code window inside the container.
- To confirm the active Git branch, open **View** → **Source Control** in VS Code or run:

```bash
git branch
```

## Paper

The accompanying paper, LaTeX source, and experimental documentation are included in this repository.

## License

The source code in this repository is licensed under the MIT License. See the `LICENSE` file for details.

## Author

Anish Chilakala  
Independent student researcher
