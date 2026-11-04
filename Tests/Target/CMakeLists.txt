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

target_include_directories(unity PUBLIC
    ${unity_SOURCE_DIR}/src
)
