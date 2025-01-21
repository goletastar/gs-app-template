if(NOT PkgConfig_FOUND)
    find_package(PkgConfig REQUIRED)
endif()

find_package(Threads QUIET)

if(OE_BUILD_ENV)
    pkg_check_modules(SPDLOG IMPORTED_TARGET spdlog-header-only)
else()
    find_package(fmt REQUIRED)
    find_package(spdlog REQUIRED)
endif()

# redis_ipc exported target sets INTERFACE_LINK_LIBRARIES via PkgConfig so cmake
# needs to know about those targets the same way
pkg_check_modules(HIREDIS IMPORTED_TARGET hiredis)
pkg_check_modules(JSONC IMPORTED_TARGET json-c)
pkg_check_modules(RIPC IMPORTED_TARGET redis-ipc)

# workaround for packages <= 0.0.2 missing pkg-config support
if(RIPC_FOUND)
    set(RIPC_LIBRARIES PkgConfig::RIPC)
else()
    find_path(
        RIPC_INCLUDE_DIR
        NAMES redis_ipc.h
        PATH_SUFFIXES include
        PATHS /usr /usr/local/
    )

    find_library(
        RIPC_LIBRARY
        NAMES redis_ipc libredis_ipc
        PATH_SUFFIXES lib lib64 lib32
        PATHS /usr /usr/local/
    )

    set(RIPC_LDFLAGS -lredis_ipc)
    set(RIPC_LIBRARIES ${RIPC_LIBRARY})
    set(RIPC_INCLUDE_DIRS ${RIPC_INCLUDE_DIR})

    include(FindPackageHandleStandardArgs)
    find_package_handle_standard_args(
        redis_ipc DEFAULT_MSG RIPC_LIBRARY RIPC_INCLUDE_DIR
    )
    mark_as_advanced(RIPC_INCLUDE_DIR RIPC_LIBRARY)
endif()

include_directories(${RIPC_INCLUDE_DIRS})
include_directories(src)

# (optional) shared between real app and unit tests
add_library(app_name_lib STATIC src/turbo.h src/turbo.cpp)

target_link_libraries(
    app_name_lib PRIVATE ${RCL_LIBS} ${RIPC_LIBRARIES}
                         spdlog::spdlog_header_only
)

target_compile_definitions(
    app_name_lib PUBLIC SPDLOG_FMT_EXTERNAL=1 FMT_HEADER_ONLY=1
)

# real app
add_executable(app_name src/main.cpp)

install(TARGETS app_name DESTINATION ${CMAKE_INSTALL_BINDIR})

target_link_libraries(app_name app_name_lib ${CMAKE_THREAD_LIBS_INIT})

if(BUILD_TESTING)
    enable_testing()
    # tell ctest to run main app as a test; note this is mainly for illustration
    # purposes, since we want to show at least one branch in the coverage
    add_test(
        NAME version_test
        COMMAND app_name -v
        WORKING_DIRECTORY "${app_name_SOURCE_DIR}"
    )

    add_test(
        NAME main_test
        COMMAND app_name
        WORKING_DIRECTORY "${app_name_SOURCE_DIR}"
    )

    add_test(
        NAME usage_test
        COMMAND app_name -r
        WORKING_DIRECTORY "${app_name_SOURCE_DIR}"
    )

    set_property(TEST usage_test PROPERTY WILL_FAIL TRUE)

    # unit test apps
    add_executable(app_name_test test/app_name_test.cpp)
    target_compile_options(app_name_test PUBLIC ${GTEST_CFLAGS})
    target_link_libraries(
        app_name_test app_name_lib gtest_main gtest gmock
        ${CMAKE_THREAD_LIBS_INIT}
    )

    message(STATUS "test discovery enabled")
    include(GoogleTest)
    gtest_discover_tests(app_name_test)

    add_custom_target(
        check
        COMMAND ${CMAKE_CTEST_COMMAND}
        DEPENDS app_name_test app_name
    )
endif()
