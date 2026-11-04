# STM32F407 Project Template

A reusable bare-metal project template for developing embedded systems based on the **STM32F407** microcontroller.

The project provides a CMake-based build system, ARM GNU toolchain configuration, CMSIS integration, host and target testing infrastructure, static analysis and GitHub Actions CI.

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
- Target-side testing with Unity.
- Static analysis with clang-tidy and Cppcheck.
- MISRA C checking.
- Automated builds and tests using GitHub Actions.
- Infrastructure for hardware testing and Renode-based simulation.
- OpenOCD, GDB and SWO debugging infrastructure.
- Pre-commit hooks for basic code and configuration checks.

## Target Hardware

The initial target configuration is designed for:

- **Microcontroller:** STM32F407VG
- **Development board:** STM32F407G-DISC1
- **Core:** ARM Cortex-M4
- **Instruction set:** Thumb
- **Floating-point unit:** FPv4-SP-D16
- **ABI:** Hard-float

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
- OpenOCD (for hardware debugging)
- Renode (for simulation, where supported)

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

### 2. Configure and build for the host

```bash
cmake --preset host
cmake --build --preset host
```

Run the host tests:

```bash
make test
```

The host configuration is intended for developing and testing application logic independently of the target hardware.

### 3. Configure and build for STM32

Make sure the ARM GNU Toolchain is installed and available in your PATH.

Configure and build:

```bash
cmake --preset stm32
cmake --build --preset stm32
```

The firmware build generates:

- ELF executable
- Intel HEX file
- Binary image

The ELF file can be used for debugging with GDB and OpenOCD.

## Build Commands

The Makefile provides convenient shortcuts:

| Command | Description |
|---|---|
| `make host` | Build the host configuration |
| `make stm32` | Build the STM32 firmware |
| `make test` | Run host tests |
| `make size` | Display firmware size information |
| `make tidy-host` | Run clang-tidy on host code |
| `make tidy-stm32` | Run clang-tidy on STM32 code |
| `make misra` | Run Cppcheck with MISRA checks |
| `make clean` | Remove build directories |
| `make help` | Display available targets |

## Project Structure

```text
.
├── App/
│   ├── Inc/                 # Application headers
│   └── Src/                 # Application source files
│
├── cmake/
│   └── arm-none-eabi-gcc.cmake
│
├── config/                  # Configuration files
├── docs/                    # Project documentation
├── Drivers/                 # Application-specific drivers
│
├── Platform/
│   ├── CMSIS/               # CMSIS Git submodules
│   │   ├── Core/            # ARM CMSIS-Core
│   │   └── Device/          # ST CMSIS-Device-F4
│   ├── Debug/               # Debugging support
│   ├── Linker/              # Linker scripts
│   └── Startup/             # Startup code and vector table
│
├── scripts/                 # Development and debugging scripts
│
├── Tests/
│   ├── Host/                # Host-based unit tests (GoogleTest)
│   ├── target/              # Target-side tests (Unity)
│   ├── Hardware/             # Physical hardware test infrastructure
│   └── Renode/               # Renode simulation tests
│
├── .github/
│   └── workflows/           # GitHub Actions workflows
│
├── CMakeLists.txt
├── CMakePresets.json
├── Makefile
├── .gitmodules
├── .clang-tidy
├── .pre-commit-config.yaml
├── AGENTS.md
└── README.md
```

## Build System

The project uses CMake presets to separate host and embedded builds.

### Host configuration

- Native compiler.
- Firmware build disabled.
- Host unit tests enabled.
- GoogleTest integration through FetchContent.

### STM32 configuration

- ARM GNU Toolchain.
- Firmware build enabled.
- Host tests disabled.
- Cortex-M4 compiler and linker settings.
- Unity integration for target-side tests.

### Dependency management

External dependencies are managed using two approaches:

**Git submodules:**
- CMSIS-Core.
- CMSIS-Device-F4.

**CMake FetchContent:**
- GoogleTest.
- Unity.

This keeps third-party dependencies separate from the project's own source code and allows their versions to be pinned.

### CMSIS

The project uses the official ARM and ST CMSIS components.

**CMSIS-Core** provides standardized Cortex-M core definitions and interfaces, including:

- Core register definitions.
- NVIC.
- SysTick.
- Interrupt handling.
- Core-specific intrinsic functions.

**CMSIS-Device-F4** provides STM32F4-specific definitions, including:

- Peripheral register structures.
- Peripheral base addresses.
- Interrupt numbers.
- Device-specific definitions.

The project does not depend on STM32 HAL or LL drivers. Peripheral configuration is implemented directly using the available hardware register definitions.

### Startup and runtime

The project provides its own startup implementation, including:

- Interrupt vector table.
- Default interrupt handlers.
- Initialization of the `.data` section.
- Zero-initialization of the `.bss` section.
- C/C++ runtime initialization.
- Entry into `main()`.

### Memory layout

The default linker configuration targets the STM32F407VG:

| Memory | Start address | Size |
|---|---|---|
| Flash | `0x08000000` | 1 MB |
| SRAM | `0x20000000` | 128 KB |
| CCMRAM | `0x10000000` | 64 KB |

The initial stack pointer is configured at `0x20020000`.

Review the linker script when adapting the template to another microcontroller.

## Testing

The project separates host-based tests from target-side, hardware-related and simulation tests.

### Host tests

GoogleTest is integrated through CMake FetchContent.

Host tests allow application logic to be tested without requiring an STM32 development board.

### Target tests

The `Tests/target` directory contains tests compiled for the STM32 target.

Unity is used as the embedded testing framework.

Target tests are intended to execute on the microcontroller. Depending on the test environment, they may also be executed in a compatible simulator.

### Hardware tests

The `Tests/Hardware` directory contains hardware-oriented test infrastructure.

These tests validate actual board behaviour and require physical target hardware for execution.

### Renode

The `Tests/Renode` directory contains simulation test infrastructure.

Renode provides a way to execute and test supported firmware behaviour without physical hardware.

Simulation results must be distinguished from tests executed on physical hardware.

## Static Analysis

### clang-tidy

The `.clang-tidy` configuration enables:

- `clang-analyzer-*`
- `bugprone-*`
- `performance-*`

The configuration uses a header filter covering application, platform and driver code.

Run:

```bash
make tidy-host
make tidy-stm32
```

### Cppcheck and MISRA

Cppcheck is used for static analysis and MISRA C checks.

Run:

```bash
make misra
```

The MISRA analysis is intended to identify potential compliance issues. Any deviations or justified exceptions should be documented rather than hidden through broad suppressions.

## Continuous Integration

GitHub Actions automatically checks the project.

The workflow is defined in:

```text
.github/workflows/build.yml
```

It contains two main jobs:

1. **Host:** Build host code, execute unit tests and run clang-tidy.
2. **STM32:** Build firmware, run clang-tidy and perform Cppcheck/MISRA analysis.

The workflow runs on pushes and pull requests and can also be started manually.

## Pre-commit Hooks

The project uses the pre-commit framework.

The configuration is stored in:

```text
.pre-commit-config.yaml
```

The configured hooks check:

- Trailing whitespace.
- End-of-file formatting.
- YAML syntax.
- Merge conflict markers.

Run all hooks manually:

```bash
pre-commit run --all-files
```

Install the Git hooks:

```bash
pre-commit install
```

## Debugging

The firmware ELF file can be used with GDB and OpenOCD.

The `Platform/Debug` and `scripts` directories provide the starting point for target debugging.

A typical debugging setup consists of:

- ST-Link debugger.
- OpenOCD.
- ARM GDB.
- STM32 development board.

SWO can be used for lightweight runtime diagnostics.

Debugging configuration may need adaptation depending on the target board and installed tools.

## Adapting the Template

When starting a new project:

1. Create a new repository from this template.
2. Clone the repository including its Git submodules.
3. Adapt the application code in `App/`.
4. Add or modify drivers as required.
5. Review the startup code and interrupt vector table.
6. Adapt the linker script if the memory layout differs.
7. Configure the required peripherals and clocks.
8. Add host-based unit tests.
9. Add target-specific tests where appropriate.
10. Extend the CI workflow when introducing new checks.

Keep hardware-independent application logic separate from hardware-specific implementations wherever practical. This makes it easier to test application logic on the host.

## Project Status

The following table distinguishes implemented infrastructure from work that is still being integrated or requires physical hardware.

| Component | Status |
|---|---|
| CMake build system | Implemented |
| Host build | Implemented |
| STM32 cross-compilation | Implemented |
| Custom startup code | Implemented |
| Custom linker configuration | Implemented |
| CMSIS integration | Being integrated |
| Host GoogleTest integration | Implemented |
| Target Unity integration | In progress |
| clang-tidy configuration | Implemented |
| Cppcheck/MISRA integration | Implemented |
| GitHub Actions CI | Implemented |
| Pre-commit configuration | Configured |
| Hardware test infrastructure | In progress |
| Physical hardware test execution | Requires physical hardware |
| Renode simulation tests | In progress |
| OpenOCD/GDB/SWO infrastructure | In progress |

## License

Add the project's chosen license here before distributing or reusing the template.
