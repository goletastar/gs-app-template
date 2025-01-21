# we need a debug build, default is RelWithDebInfo

set(CMAKE_C_FLAGS "--coverage")
set(CMAKE_CXX_FLAGS "--coverage")
set(CMAKE_SHARED_LINKER_FLAGS "--coverage")

if(CMAKE_CXX_COMPILER_ID STREQUAL Clang)
    set(EXTRA_LCOV_ARGS --gcov-tool llvm-cov --gcov-tool gcov)
endif()

set(COVERAGE_OUTPUT_DIR "${CMAKE_SOURCE_DIR}/coverage")
set(TRACEFILE "${CMAKE_SOURCE_DIR}/coverage.info")
set(REPORT_DIR "${COVERAGE_OUTPUT_DIR}")

# cmake-format: off
add_custom_command(
  OUTPUT "${TRACEFILE}" always
  WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
  COMMAND ${CMAKE_COMMAND} -E remove "${TRACEFILE}"
  COMMAND ${CMAKE_COMMAND} -E remove_directory "${COVERAGE_OUTPUT_DIR}"
  COMMAND ${CMAKE_CTEST_COMMAND}  # execute default test suite

  COMMAND lcov
    --config-file "${CMAKE_SOURCE_DIR}/.lcovrc"
    --include "${CMAKE_SOURCE_DIR}/*"
    --exclude "${CMAKE_SOURCE_DIR}/ext/*"
    --capture
    --output-file "${TRACEFILE}"
    --directory .
    ${EXTRA_LCOV_ARGS}

#    --ignore-errors inconsistent,inconsistent,unsupported,unused

  COMMAND genhtml ${TRACEFILE}
    --prefix "."
    --title "${CMAKE_PROJECT_NAME}"
    --legend --show-details
    --output-directory ${REPORT_DIR}

  VERBATIM  # for correct handling of wildcards in command line parameters
)
# cmake-format: on

add_custom_target(cov DEPENDS ${TRACEFILE} always)
add_dependencies(cov check)
