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

## Prerequisites/Requirements

You will need **VS Code** and one of the following development environments:

- **GHC / GHCup** installed locally, if building outside a container.
- **Docker Desktop**, if using the VS Code Dev Container.
- **GitHub Codespaces** access, if using a cloud-based development environment.
- **Laptop**, you need a functioning laptop that can handle code.

## Running

# Option A: Local VS Code Setup

Use this option if you have GHC installed locally and want to build without Docker.

# Clone the repository

```bash
git clone https://github.com/anish-chilakala/modal-depth-ADS-safety-method.git
cd modal-depth-ADS-safety-method
git fetch origin add-devcontainer-vscode-config
git checkout -b add-devcontainer-vscode-config origin/add-devcontainer-vscode-config
```

# Open in VS Code

```bash
code .
```

# Build and run

If GHC is installed locally:

```bash
make build
make run
```

Alternatively, in VS Code:

1. Open the Command Palette.
2. Select **Tasks: Run Build Task** to build the project.
3. Select **Run Task** → **Run (Make)** to run it.
4. You may also use the Run and Debug view to start the **Run Haskell executable** configuration.

# Option B: VS Code Dev Container

This is the recommended option because it provides a reproducible environment and does not require a local Haskell installation.

# Requirements

- Docker Desktop
- VS Code
- The **Dev Containers** extension for VS Code

# Setup

Clone and check out the repository branch:

```bash
git clone https://github.com/anish-chilakala/modal-depth-ADS-safety-method.git
cd modal-depth-ADS-safety-method
git fetch origin add-devcontainer-vscode-config
git checkout -b add-devcontainer-vscode-config origin/add-devcontainer-vscode-config
```

Open the repository in VS Code:

```bash
code .
```

Then:

1. Install and enable the **Dev Containers** extension if needed.
2. Open the Command Palette.
3. Select **Dev Containers: Reopen in Container**.
4. Wait for VS Code to build and configure the container.

The development container installs GHCup, GHC, Cabal, and Haskell Language Server automatically.

# Build and run

After setup completes, either use the VS Code Tasks interface or run:

```bash
make build
make run
```

# Option C: GitHub Codespaces

Use this option if you want to develop in the cloud without installing Docker or Haskell locally.

1. Open the [repository](https://github.com/anish-chilakala/modal-depth-ADS-safety-method) in your browser.
2. Click **Code**.
3. Select **Open with Codespaces** → **New codespace**.
4. Choose the `add-devcontainer-vscode-config` branch when creating the Codespace.
5. Wait for the `.devcontainer` environment to finish configuring.

Once the Codespace is ready, build and run using the integrated terminal:

```bash
make build
make run
```

You can also use the VS Code Tasks interface.

# Option D: Open Repository Remotely

This option is useful for quickly viewing or editing files, but it does not provide a complete runnable development environment.

1. Install the **GitHub Repositories** extension in VS Code.
2. Open the Command Palette.
3. Select **GitHub Repositories: Open Remote Repository**.
4. Paste the repository URL:

```text
https://github.com/anish-chilakala/modal-depth-ADS-safety-method
```

For building and running the project, use Option A, B, or C instead.

# Troubleshooting

- The first Dev Container startup may take several minutes because `postCreateCommand` installs tools through GHCup.
- If Haskell Language Server reports a version mismatch, wait for container setup to complete and restart the VS Code window inside the container.
- The repository may contain compiled `.o` and `.hi` files. They should not prevent builds, but they are normally removed and added to `.gitignore`.
- To confirm the active Git branch, open **View** → **Source Control**, or run:

```bash
git branch
```

## Paper

The accompanying paper, source files, and experimental documentation are included in this repository.

## License

This project is licensed under the MIT license. Further information is listed in the LICENSE file.

## Author

Anish Chilakala  
Independent student researcher
