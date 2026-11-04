# STM32F407 Project Template

![Build](https://github.com/koenigr/stm32f407_project_template/actions/workflows/build.yml/badge.svg)

A reusable bare-metal project template for developing embedded systems based on the **STM32F407** microcontroller.

The project provides a CMake-based build system, ARM GNU toolchain configuration, CMSIS integration, host and target testing infrastructure, static analysis, debugging support and GitHub Actions CI.

The template deliberately avoids STM32 HAL and CubeMX to provide direct control over hardware initialization, peripheral configuration and the build process.

## Features

- Bare-metal STM32F407 firmware development.
- C11 and C++17 support.
- CMake-based build configuration.
- Separate host and STM32 build configurations.
- ARM GNU Toolchain integration.
- CMSIS-Core and CMSIS-Device integration.
- Custom startup code and interrupt vector table.
- Custom linker script.
- No dependency on STM32 HAL or STM32CubeMX.
- Host-based unit testing with GoogleTest.
- Target-side testing infrastructure with Unity.
- Renode-based firmware simulation tests.
- Static analysis with clang-tidy and Cppcheck.
- MISRA C checking.
- Automated builds and tests using GitHub Actions.
- OpenOCD, GDB and SWO debugging infrastructure.
- Pre-commit hooks for basic code and configuration checks.

## Target Hardware

The initial target configuration is designed for:

| Component | Configuration |
|---|---|
| Microcontroller | STM32F407VG |
| Development board | STM32F407G-DISC1 |
| Core | ARM Cortex-M4 |
| Instruction set | Thumb |
| Floating-point unit | FPv4-SP-D16 |
| ABI | Hard-float |

The project can serve as a starting point for other STM32F407-based projects. Adapt the linker script, startup code, device configuration and peripheral definitions as necessary for different hardware.

## Requirements

### Build tools

- CMake >= 3.22
- ARM GNU Toolchain (`arm-none-eabi-gcc`, `arm-none-eabi-g++`)
- GNU Make
- Python 3
- Git

### Testing and development tools

- Host GCC/G++
- GoogleTest (downloaded through CMake FetchContent)
- Unity (downloaded through CMake FetchContent)
- clang-tidy
- Cppcheck
- pre-commit
- Renode and `renode-test` (for local simulation tests)
- OpenOCD (for hardware debugging)

CMake FetchContent requires network access when dependencies are not already cached.

## Getting Started

### 1. Clone the repository

CMSIS dependencies are managed as Git submodules.

Clone the repository including its submodules:

```bash
git clone --recurse-submodules https://github.com/koenigr/stm32f407_project_template.git
cd stm32f407_project_template
```

If the repository was cloned without submodules:

```bash
git submodule update --init --recursive
```

### 2. Build and test for the
