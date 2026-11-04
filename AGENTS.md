# STM32F407 Project Template — Agent Notes

## Project identity

- Repository: `https://github.com/koenigr/stm32f407_project_template`
- Local path: `~/git/stm32f407_project_template`
- Main branch: `main`
- Status date: 4 November 2026
- Purpose: reusable, reproducible bare-metal STM32F407 project template.
- Keep this repository separate from `stm32f407-register-level-access-control`.

## Working principles

- Work incrementally, but avoid unnecessary micro-steps.
- Give direct, actionable instructions and move to the next planned task.
- Do not recreate existing files or configurations without checking first.
- Avoid unnecessary dependencies and frameworks.
- Do not introduce STM32 HAL or CubeMX unless explicitly requested.
- Distinguish clearly between implemented, locally executed, CI-executed, simulator-executed and physically hardware-executed tests.
- Never claim a test has run on physical hardware unless that has actually happened.
- Keep documentation consistent with the actual implementation.
- Do not claim a feature is complete merely because its configuration or infrastructure exists.
- Preserve working configurations and avoid rewriting files wholesale without a clear reason.

## Project plan

The agreed work plan:

1. Repository structure and README
2. CMake + ARM toolchain + Makefile
3. Startup code + linker script + CMSIS
4. Host tests with GoogleTest
5. Target tests with Unity
6. CI workflow and badges
7. clang-tidy + Cppcheck/MISRA
8. Renode integration
9. OpenOCD + GDB + SWO
10. Memory analysis and firmware reporting
11. V-Model documentation templates
12. Release workflow and project housekeeping

Much of the basic build and CI infrastructure is already implemented.

### Current priorities

1. Finish and verify pre-commit configuration.
2. Review and stabilize the Makefile.
3. Complete Unity target-test integration.
4. Verify all build and static-analysis commands from clean build directories.
5. Review Renode, debugging and hardware-test infrastructure.
6. Complete remaining documentation and housekeeping.

Always inspect the current repository state before changing existing implementation.

## Repository structure

Known structure:

```text
App/
  Inc/
  Src/
cmake/
  arm-none-eabi-gcc.cmake
config/
docs/
Drivers/
.github/
  workflows/
Platform/
  CMSIS/
  Debug/
  Linker/
  Startup/
Tests/
  Hardware/
  Host/
  Renode/
  Target/
```

The exact contents of all directories have not been fully inspected.

## Build system

Implemented / reported:

- CMake minimum version 3.22.
- C11 and C++17.
- CMake presets named `host` and `stm32`.
- ARM GCC toolchain: `cmake/arm-none-eabi-gcc.cmake`.
- Compile commands exported.
- Explicit source file lists.
- Separate host and firmware build configurations.
- Debug build configuration.
- Custom startup code, vector table, linker script and runtime initialization.
- ELF, HEX and BIN firmware outputs.
- No STM32 HAL or CubeMX dependency.

ARM toolchain configuration uses:

- `arm-none-eabi-gcc`
- `arm-none-eabi-g++`
- Cortex-M4
- Thumb
- Hardware floating point
- Hard-float ABI

STM32F407VG memory layout:

| Memory | Address | Size |
|---|---|---|
| Flash | `0x08000000` | 1 MB |
| SRAM | `0x20000000` | 128 KB |
| CCMRAM | `0x10000000` | 64 KB |

## Startup, linker and CMSIS

Existing files observed:

```text
Platform/Linker/STM32F407VGTx_FLASH.ld
Platform/Startup/runtime.c
Platform/Startup/startup_stm32f407xx.s
```

A generated-looking file `Platform/Startup/runtime.c.ctu-info` was also observed. Check whether it is tracked; generated analysis artifacts should generally not be committed.

### CMSIS integration

The intended architecture is CMSIS-Core + CMSIS-Device, without STM32 HAL or LL.

Intended dependencies:

- CMSIS-Core: `https://github.com/ARM-software/CMSIS_6.git`
- CMSIS-Device-F4: `https://github.com/STMicroelectronics/cmsis-device-f4.git`

Intended locations:

- `Platform/CMSIS/Core`
- `Platform/CMSIS/Device/ST/STM32F4xx`

Confirm actual `.gitmodules`, submodule status and commit state before assuming integration is complete.

Keep the existing custom startup and linker implementation unless there is a deliberate migration plan. Do not add a second competing startup implementation.

CMSIS headers do not by themselves add runtime code to the ELF; only referenced code and data are linked.

## Host tests

Implemented / reported:

- GoogleTest fetched with CMake `FetchContent`.
- GoogleTest version/tag `v1.15.2`.
- Host test executable exists.
- Basic host test has been successfully executed.
- GoogleTest FetchContent is declared in `Tests/Host/CMakeLists.txt`.

Do not move GoogleTest dependency management without a reason.

## Target tests and Hardware tests

The repository has both `Tests/Target/` and `Tests/Hardware/`.

Keep their responsibilities distinct:

- `Tests/Target/`: tests compiled for the STM32 target. Unity is the intended test framework. A target-test binary may execute on the physical MCU or, if supported by the test environment, in a simulator.
- `Tests/Hardware/`: tests and procedures that validate real board/hardware behaviour and hardware-facing workflows. These may use OpenOCD, GDB, SWO, scripts or invoke a target-test binary on a physical board.

A target test is defined by its build/runtime target. A hardware test is defined by its dependence on actual hardware. They are related but not interchangeable.

### Unity integration — outstanding work

Agreed approach:

- Integrate Unity using CMake `FetchContent`, not a Git submodule.
- GoogleTest remains in `Tests/Host/CMakeLists.txt`.
- Unity dependency should be declared in `Tests/Target/CMakeLists.txt` (check actual directory capitalization before editing).
- Connect Unity and the target-test executable to the STM32 build only.
- Do not accidentally pull Unity into the host build.

Before editing target wiring:

1. Inspect the actual root `CMakeLists.txt`.
2. Inspect the existing target-test CMake file.
3. Identify the actual firmware target name and link dependencies.
4. Check the existing startup and linker target arrangement.

Do not invent target names or assume a particular target arrangement.

Unity is C source (`unity.c`) with headers under Unity's `src` directory. Verify the selected release's CMake integration rather than assuming it has a compatible top-level CMake project.

Avoid creating a test executable with an empty test suite as if meaningful target tests were already implemented. Add real initial tests or clearly label a minimal runner as infrastructure-only.

## Makefile

Known targets:

- `all`
- `host`
- `stm32`
- `test`
- `size`
- `clean`
- `help`
- `tidy-host`
- `tidy-stm32`
- `misra`
- `misra-check`
- `pre-commit-checks`

The Makefile currently uses CMake presets for host and STM32 builds.

`misra` and `misra-check` invoke Cppcheck with the generated STM32 `compile_commands.json`.

Review notes:

- Ensure every phony target, including `pre-commit-checks`, appears in `.PHONY`.
- Ensure `misra-check` cannot run before the STM32 compile database exists; make dependencies explicit.
- Avoid redundant duplicate Cppcheck invocations.
- The `help` target should describe all relevant targets.
- Preserve working commands; do not rewrite the Makefile wholesale.

## Static analysis

Reported configuration:

- `.clang-tidy` enables `clang-analyzer-*`, `bugprone-*` and `performance-*`.
- Header filter covers `App/`, `Platform/` and `Drivers/`.
- Cppcheck version 2.7.
- MISRA addon configured.
- An earlier raw Cppcheck invocation passed after fixing an MISRA 8.4 issue involving `_init`.
- `make misra` still needs explicit confirmation in the final infrastructure verification.
- Generated Cppcheck artifacts should not be tracked.

clang-tidy is intentionally not part of pre-commit. It runs in CI and can also be invoked locally.

## CI

Workflow:

```text
.github/workflows/build.yml
```

Reported jobs/checks:

1. Host tests and clang-tidy.
2. STM32 firmware build, clang-tidy and MISRA/Cppcheck.

Triggers:

- Push
- Pull request
- Manual `workflow_dispatch`

Both CI checks were confirmed green before the latest pre-commit and Unity-related work.

Recheck after relevant changes.

## Pre-commit

The project uses the pre-commit framework.

### Intended hooks

- `trailing-whitespace`
- `end-of-file-fixer`
- `check-yaml`
- `check-merge-conflict`

Check whether `check-added-large-files` is also configured in the current `.pre-commit-config.yaml`.

### Installation on the development machine

The user initially had the Ubuntu package:

```text
/usr/bin/pre-commit
pre-commit 2.17.0
```

The old version was incompatible with the selected `pre-commit-hooks` revision.

pipx was installed, followed by:

```bash
pipx install pre-commit
```

The pipx installation reported:

```text
pre-commit 4.6.2
Python 3.10.12
```

Active executable:

```text
/home/koenigr/.local/bin/pre-commit
```

The Ubuntu package at `/usr/bin/pre-commit` remains installed. The shell resolves to the pipx installation.

### Hook revision

The configuration initially used `pre-commit-hooks` revision `v5.0.0`.

A compatibility error occurred because that revision exposed the deprecated stage name `pre-commit`, which pre-commit 4.6.2 rejects.

The hook revision was changed to:

```yaml
rev: v4.6.0
```

### Remaining verification

The following steps still need confirmation:

```bash
pre-commit --version
pre-commit validate-config
pre-commit run --all-files
```

If necessary:

```bash
pre-commit clean
pre-commit install
pre-commit run --all-files
```

Do not consider the pre-commit setup complete until validation and execution succeed and the resulting configuration has been committed.

clang-tidy is intentionally not a pre-commit hook. It already runs in CI.

## README

A full README draft has been prepared.

It covers:

- Project purpose and features.
- Target hardware.
- Requirements.
- Getting started.
- Host and STM32 builds.
- Makefile commands.
- Project structure.
- Startup and memory layout.
- Testing.
- Static analysis.
- CI.
- Pre-commit.
- Debugging.
- Adapting the template.
- Project status.

Before considering the README final:

- Verify all commands against the actual CMake presets and Makefile.
- Check directory names and capitalization.
- Verify the testing and simulation descriptions.
- Do not claim physical hardware tests have passed without evidence.
- Add the chosen project license once decided.

## Renode, OpenOCD, GDB and SWO

Planned infrastructure includes:

- Renode integration under `Tests/Renode/`.
- OpenOCD/GDB/SWO support under `Platform/Debug/` and/or `scripts/`.
- Hardware test procedures under `Tests/Hardware/`.

Do not claim simulator or physical hardware tests have passed without evidence.

Keep host results, CI results, simulator results and physical-board results separate.

## Development machine

Reported machine:

- Lubuntu 22.04.5 LTS.
- Kernel 5.15.
- AMD Phenom II X4 945.
- 4 GB RAM at time of report; a 4 GB DDR3-1333 upgrade was ordered to reach 8 GB.
- MSI 760GM-P23 (FX), MS-7641.
- NVIDIA GeForce GT 610.
- Legacy BIOS.

An upgrade to Lubuntu 24.04 LTS was discussed but not scheduled.

The RAM upgrade is unrelated to the repository configuration. Do not derail project work into operating-system or hardware upgrades unless requested.

## Completion criteria

Before declaring the template complete, verify:

- Host configure/build/test from a clean build directory.
- STM32 configure/build from a clean build directory.
- Unity target-test build and execution method are clear.
- clang-tidy and Cppcheck/MISRA work locally and in CI as intended.
- Pre-commit configuration validates and all hooks pass.
- Renode tests are accurately represented.
- OpenOCD/GDB/SWO workflows are documented and reproducible.
- Memory/firmware reporting works.
- V-Model documentation templates exist.
- Release workflow and repository housekeeping are complete.
- Submodule initialization instructions are correct for template users.

## Instructions for future work

- Start by inspecting the actual repository state.
- Do not assume previous plans were completed.
- Do not confuse this repository with `stm32f407-register-level-access-control`.
- Do not repeat installation instructions for tools already installed.
- Do not introduce unnecessary documentation or dependencies.
- Keep answers concise and practical.
- Explicitly state when the build configuration phase is complete.
