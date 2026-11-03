.PHONY: all host stm32 test size clean help

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

help:
	@echo "Available targets:"
	@echo "  all    - Build host tests and STM32 firmware"
	@echo "  host   - Build host tests"
	@echo "  stm32  - Build STM32 firmware"
	@echo "  test   - Build and run host tests"
	@echo "  size   - Show firmware memory usage"
	@echo "  clean  - Remove build directory"