.PHONY: all host stm32 test clean tidy misra

all: host

host:
	cmake --preset host
	cmake --build --preset host

stm32:
	cmake --preset stm32
	cmake --build --preset stm32

test: host
	ctest --preset host

tidy:
	@echo "clang-tidy configuration pending"

misra:
	@echo "Cppcheck configuration pending"

clean:
	rm -rf build