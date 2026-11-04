include(FetchContent)

FetchContent_Declare(
    Unity
    GIT_REPOSITORY https://github.com/ThrowTheSwitch/Unity.git
    GIT_TAG v2.6.1
)

FetchContent_GetProperties(Unity)
if(NOT unity_POPULATED)
    FetchContent_Populate(Unity)
endif()

add_library(unity STATIC
    ${unity_SOURCE_DIR}/src/unity.c
)

target_compile_options(unity PRIVATE
    ${ARM_CPU_FLAGS}
)

target_include_directories(unity PUBLIC
    ${unity_SOURCE_DIR}/src
)

add_executable(target_tests
    test_main.c
    ../../Platform/Startup/startup_stm32f407xx.s
    ../../Platform/Startup/runtime.c
)

target_link_libraries(target_tests PRIVATE unity)

target_include_directories(target_tests PRIVATE
    ../../App/Inc
    ../../Platform/CMSIS/Core/Include
    ../../Platform/CMSIS/Device/ST/STM32F4xx/Include
)

target_compile_options(target_tests PRIVATE
    ${ARM_CPU_FLAGS}
    -Wall
    -Wextra
    -Werror
    -ffunction-sections
    -fdata-sections
)

target_link_options(target_tests PRIVATE
    ${ARM_CPU_FLAGS}
    -T${CMAKE_SOURCE_DIR}/Platform/Linker/STM32F407VGTx_FLASH.ld
    -nostartfiles
    --specs=nano.specs
    --specs=nosys.specs
    -Wl,--gc-sections
    -Wl,--print-memory-usage
    -Wl,-Map=${CMAKE_CURRENT_BINARY_DIR}/target_tests.map
)

set_target_properties(target_tests PROPERTIES
    SUFFIX ".elf"
    LINKER_LANGUAGE C
)
