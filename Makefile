.PHONY: all host stm32 test size clean help tidy-host tidy-stm32 \
	misra misra-check pre-commit-checks

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

misra: misra-check
	@test -f "$(MISRA_ADDON)" || \
		(echo "ERROR: Cppcheck MISRA addon not found"; exit 1)
	$(CPPCHECK) \
		--project=build/stm32/compile_commands.json \
		--addon=$(MISRA_ADDON) \
		--enable=warning,style,performance,portability \
		--inline-suppr \
		--error-exitcode=1

pre-commit-checks: host stm32
	git diff --check
	clang-tidy -p build/host Tests/Host/test_main.cpp
	clang-tidy -p build/stm32 App/Src/main.c Platform/Startup/runtime.c
	$(MAKE) misra-check

misra-check: stm32
	@test -f "$(MISRA_ADDON)" || \
		(echo "ERROR: Cppcheck MISRA addon not found"; exit 1)
	$(CPPCHECK) \
		--project=build/stm32/compile_commands.json \
		--addon=$(MISRA_ADDON) \
		--enable=warning,style,performance,portability \
		--inline-suppr \
		--error-exitcode=1

help:
	@echo "Available targets:"
	@echo "  all    - Build host tests and STM32 firmware"
	@echo "  host   - Build host tests"
	@echo "  stm32  - Build STM32 firmware"
	@echo "  test   - Build and run host tests"
	@echo "  size   - Show firmware memory usage"
	@echo "  clean  - Remove build directory"
