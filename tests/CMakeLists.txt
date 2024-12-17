# This CMakeLists (stella-tests) must be built separately from the main
# CMakeLists (stella-os) as gtest cannot be built using the kernel toolchain.

cmake_minimum_required(VERSION 3.12)
project(stella-tests)

set(CMAKE_CXX_STANDARD 20)
enable_language(CXX)

include_directories(${CMAKE_SOURCE_DIR}/../kernel/include)

set(SOURCES
	kstd/types.cpp
)

enable_testing()
add_executable(tests ${SOURCES})
target_link_libraries(tests gtest gtest_main)

include(GoogleTest)
gtest_discover_tests(tests)

add_custom_target(run
	COMMAND tests --gtest_brief=1
	DEPENDS tests
)
