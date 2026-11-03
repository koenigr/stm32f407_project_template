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

find_program(ARM_OBJCOPY arm-none-eabi-objcopy REQUIRED)

add_custom_command(TARGET firmware POST_BUILD
    COMMAND ${ARM_OBJCOPY} -O ihex
        $<TARGET_FILE:firmware>
        $<TARGET_FILE_DIR:firmware>/firmware.hex

    COMMAND ${ARM_OBJCOPY} -O binary
        $<TARGET_FILE:firmware>
        $<TARGET_FILE_DIR:firmware>/firmware.bin

    COMMENT "Generating HEX and BIN firmware images"
)
