# pre-test discovery mode for gtest_discover_tests was added in 3.18
cmake_minimum_required(VERSION 3.18)

option(USE_GIT_SUBMODULE "Use submodule during build" ON)
option(USE_COMMON_LIBS "Use common libs from build environment" OFF)

# Add cmake modules of this project to the module path
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules)

if(DEFINED ENV{HAVE_COMMON_LIBS})
    set(USE_COMMON_LIBS "$ENV{HAVE_COMMON_LIBS}")
endif()

if(USE_COMMON_LIBS)
    set(USE_GIT_SUBMODULE OFF)
endif()

if(NOT SCM_VERSION_INFO)
    include(cmake/GetGitRev.cmake)
    get_git_head_revision(GIT_REFSPEC GIT_SHA1)
    string(SUBSTRING "${GIT_SHA1}" 0 8 GIT_SHA1_SHORT)
    git_describe(GIT_DESCRIPTION)
    message(STATUS "Git description is ${GIT_DESCRIPTION}")
    git_describe(GIT_TAG_LAST "--abbrev=0")
    git_get_exact_tag(GIT_TAG_EXACT)
    if(NOT REVISION)
        if(GIT_TAG_EXACT)
            string(SUBSTRING "${GIT_TAG_EXACT}" 1 -1 REVISION)
            message(STATUS "Currently on Git tag ${GIT_TAG_EXACT}")
        else(GIT_TAG_LAST)
            message(STATUS "Latest recognized Git tag is ${GIT_TAG_LAST}")
            set(GIT_TAG_EXACT "")
            execute_process(
                COMMAND git rev-list ${GIT_TAG_LAST}.. --count
                WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
                OUTPUT_VARIABLE GIT_REV_COUNT
                OUTPUT_STRIP_TRAILING_WHITESPACE
            )
            string(SUBSTRING "${GIT_TAG_LAST}.${GIT_REV_COUNT}" 1 -1 REVISION)
            string(SUBSTRING "${GIT_DESCRIPTION}" 1 -1 DEV_VERSION)
        endif()
        message(STATUS "Git HEAD is ${GIT_SHA1}")
    endif()

    # strip leading 'v', and make unique for the tag
    message(STATUS "Project version is ${REVISION}")
    message(STATUS "Project dev-hash version is ${DEV_VERSION}")
    if(VERSION_FORMAT_DEV)
        set(SCM_VERSION_INFO ${DEV_VERSION})
    else()
        set(SCM_VERSION_INFO ${REVISION})
    endif()
endif()

if(SCM_VERSION_INFO AND NOT REVISION)
    message(WARNING "SCM_VERSION_INFO must be a valid CMake Project version")
    set(REVISION SCM_VERSION_INFO)
endif()

project(
    app_name
    LANGUAGES CXX C
    VERSION ${REVISION}
)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_VERBOSE_MAKEFILE ON)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS ON)

if(CMAKE_CXX_COMPILER_ID STREQUAL Clang)
    set(CLANG_DEFAULT_CXX_STDLIB libc++)
    set(CLANG_DEFAULT_RTLIB compiler-rt)
endif()

set(CMAKE_C_STANDARD 11)
set(CMAKE_DEBUG_POSTFIX d)

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE
        "RelWithDebInfo"
        CACHE STRING "Default build type: RelWithDebInfo" FORCE
    )
endif()

include(CTest)
include(GNUInstallDirs)

# eventually this should default to OFF
option(BUILD_TESTING "build and run tests" ON)

set(WITH_COVERAGE
    ""
    CACHE PATH "build with test coverage enabled"
)

if(VENDOR_GTEST)
    include(FetchContent)
    # current tests are broken on Gtest >= 1.15
    FetchContent_Declare(
        googletest
        GIT_REPOSITORY https://github.com/google/googletest.git
        GIT_TAG v1.14.0
    )
    set(gtest_force_shared_crt
        ON
        CACHE BOOL "" FORCE
    )
    FetchContent_MakeAvailable(googletest)
endif()

# ~~~
# Adds custom target for lcov report generation (does not build, only
# runs test cmd). Uses the same .lcovrc and command args as autotools.
# ~~~
if(WITH_COVERAGE)
    set(BUILD_TESTING ON)
    include(TestCoverage)
endif()

# Generate config.h
configure_file(config.h.in config.h)
add_compile_definitions(HAVE_CONFIG_H)
if(VERSION_FORMAT_DEV)
    add_compile_definitions(VERSION_FORMAT_DEV)
endif()
include_directories(${CMAKE_CURRENT_BINARY_DIR})

set(GOOGLETEST_SRC_DIR
    ""
    CACHE PATH "path to googletest source, in place of prebuilt library"
)

if(BUILD_TESTING)
    if(GOOGLETEST_SRC_DIR)
        set(BUILD_GMOCK ON)
        set(BUILD_GTEST ON)
        add_subdirectory(${GOOGLETEST_SRC_DIR} googletest)
    else()
        # we use this for both gtest and other libs
        find_package(PkgConfig)

        pkg_search_module(GTEST REQUIRED gtest_main)
        pkg_search_module(GMOCK REQUIRED gmock)
    endif()
endif()

include(SetRPATH) # mainly for non-system install paths

add_subdirectory(app_name)
