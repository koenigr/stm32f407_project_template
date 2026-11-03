add_executable(firmware
    Src/main.c
    ../Platform/Startup/startup_stm32f407xx.s
    ../Platform/Startup/runtime.c
)

target_include_directories(firmware PRIVATE
    Inc
)

target_compile_options(firmware PRIVATE
    ${ARM_CPU_FLAGS}
    -Wall
    -Wextra
    -Werror
    -ffunction-sections
    -fdata-sections
)

target_link_options(firmware PRIVATE
    ${ARM_CPU_FLAGS}
    -T${CMAKE_SOURCE_DIR}/Platform/Linker/STM32F407VGTx_FLASH.ld
    -nostartfiles
    --specs=nano.specs
    --specs=nosys.specs
    -Wl,--gc-sections
    -Wl,--print-memory-usage
    -Wl,-Map=${CMAKE_CURRENT_BINARY_DIR}/firmware.map
)

set_target_properties(firmware PROPERTIES
    SUFFIX ".elf"
    LINKER_LANGUAGE CXX
)