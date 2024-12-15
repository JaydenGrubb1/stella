set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED true)

enable_language(CXX)
enable_language(ASM_NASM)

set(CXX_FLAGS
	-Wall
	-Wextra
	-Wold-style-cast
	-ffreestanding
	-fno-exceptions
	-fno-rtti
	-nostdlib
	-lgcc
	-mno-red-zone
	-fno-use-cxa-atexit
	-fno-threadsafe-statics
	-mcmodel=kernel
	-masm=intel
	-fmacro-prefix-map=${CMAKE_SOURCE_DIR}=.
)

set(ASM_FLAGS
	-w-all
	# FIXME suppress only "uninitialized space declared in non-BSS section" warnings
)

set(LINK_FLAGS
	-ffreestanding
	-nostdlib
	-lgcc
	-mno-red-zone
	-mcmodel=kernel
)

if(NOT CMAKE_BUILD_TYPE)
	set(CMAKE_BUILD_TYPE Debug)
endif()

if(CMAKE_BUILD_TYPE MATCHES Debug)
	set(CXX_FLAGS
		${CXX_FLAGS}
		-g
		-O0
		-fno-omit-frame-pointer
	)
	add_definitions(-DDEBUG)
elseif(CMAKE_BUILD_TYPE MATCHES Release)
	set(CXX_FLAGS
		${CXX_FLAGS}
		-O3
		-fomit-frame-pointer
	)
elseif(CMAKE_BUILD_TYPE MATCHES RelWithDebInfo)
	set(CXX_FLAGS
		${CXX_FLAGS}
		-g
		-O3
		-fno-omit-frame-pointer
	)
else()
	message(FATAL_ERROR "Unknown build type: ${CMAKE_BUILD_TYPE}")
endif()

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)

set(SOURCES
	src/new.cpp
)

if(ARCH MATCHES x86_64)
	add_definitions(-DARCH_x86_64)
	add_subdirectory(src/arch/x86_64)
	set(SOURCES
		${SOURCES}
		${ARCH_SOURCES}
	)
	set(LINKER_SCRIPT ${CMAKE_CURRENT_SOURCE_DIR}/src/arch/x86_64/linker.ld)
else()
	message(FATAL_ERROR "Unsupported architecture: ${ARCH}")
endif()

set(CMAKE_EXECUTABLE_SUFFIX ".bin")
add_executable(kernel ${SOURCES})

target_compile_options(kernel
	PRIVATE
	$<$<COMPILE_LANGUAGE:CXX>:${CXX_FLAGS}>
	$<$<COMPILE_LANGUAGE:ASM_NASM>:${ASM_FLAGS}>
)
target_link_options(kernel
	PRIVATE
	-T ${LINKER_SCRIPT}
	${LINK_FLAGS}
)

set_target_properties(kernel PROPERTIES LINK_DEPENDS ${LINKER_SCRIPT})
