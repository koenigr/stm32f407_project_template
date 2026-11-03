cmake_minimum_required(VERSION 3.22)

project(stm32f407_project_template
    VERSION 0.1.0
    LANGUAGES C CXX ASM
)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

option(BUILD_HOST_TESTS "Build host tests" ON)
option(BUILD_FIRMWARE "Build STM32 firmware" OFF)

if(BUILD_HOST_TESTS)
    enable_testing()
    add_subdirectory(Tests/Host)
endif()

if(BUILD_FIRMWARE)
    add_subdirectory(App)
endif()