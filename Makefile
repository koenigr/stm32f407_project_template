.PHONY: all host stm32 test size clean help tidy-host tidy-stm32 \
	misra pre-commit-checks target-tests renode

CPPCHECK ?= cppcheck
MISRA_ADDON ?= $(shell find /usr /usr/local \
	-type f -path '*/cppcheck/addons/misra.py' \
	-print -quit 2>/dev/null)

all: host stm32

host:
	cmake --preset host
	cmake --build --preset host

stm32:
	cmake --preset stm32
	cmake --build --preset stm32

test: host
	ctest --preset host

size: stm32
	arm-none-eabi-size build/stm32/App/firmware.elf

clean:
	rm -rf build

tidy-host:
	cmake --preset host
	cmake --build --preset host
	clang-tidy -p build/host Tests/Host/test_main.cpp

tidy-stm32:
	cmake --preset stm32
	cmake --build --preset stm32
	clang-tidy -p build/stm32 App/Src/main.c Platform/Startup/runtime.c

misra: stm32
	@test -f "$(MISRA_ADDON)" || \
		(echo "ERROR: Cppcheck MISRA addon not found"; exit 1)
	$(CPPCHECK) \
		--project=build/stm32/compile_commands.json \
		--addon=$(MISRA_ADDON) \
		--enable=warning,style,performance,portability \
		--inline-suppr \
		--suppress='*:*_deps/unity-src*' \
		--error-exitcode=1

pre-commit-checks: host stm32
	git diff --check
	clang-tidy -p build/host Tests/Host/test_main.cpp
	clang-tidy -p build/stm32 App/Src/main.c Platform/Startup/runtime.c
	$(MAKE) misra

target-tests: stm32
	cmake --build --preset stm32 --target target_tests

renode: stm32
	renode-test --variable ELF:@$(CURDIR)/build/stm32/App/firmware.elf \
		Tests/Renode/stm32f4_discovery.robot

help:
	@echo "Available targets:"
	@echo ""
	@echo "Build:"
	@echo "  all                 Build host tests and STM32 firmware"
	@echo "  host                Configure and build host tests"
	@echo "  stm32               Configure and build STM32 firmware"
	@echo "  clean               Remove build directory"
	@echo ""
	@echo "Tests:"
	@echo "  test                Build and run host tests"
	@echo "  target-tests        Build STM32 target tests"
	@echo "  renode              Run Renode simulation tests"
	@echo ""
	@echo "Analysis:"
	@echo "  size                Show firmware memory usage"
	@echo "  tidy-host           Run clang-tidy on host code"
	@echo "  tidy-stm32          Run clang-tidy on STM32 code"
	@echo "  misra               Run Cppcheck with MISRA checks"
	@echo "  pre-commit-checks   Run all pre-commit checks"
	@echo ""
	@echo "Run 'make <target>' to execute a target."
