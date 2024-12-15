set(CMAKE_TOOLCHAIN_FILE ${CMAKE_SOURCE_DIR}/tools/toolchain.cmake)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON CACHE INTERNAL "")

cmake_minimum_required(VERSION 3.12)
project(stella-os)

if(NOT ARCH)
	set(ARCH x86_64)
endif()

add_subdirectory(kernel)

add_custom_command(
	OUTPUT ${CMAKE_BINARY_DIR}/initrd.img
	COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/initrd
	# TODO: add files to initrd
	COMMAND ${CMAKE_COMMAND} -P ${CMAKE_SOURCE_DIR}/tools/make-initrd.cmake
	# TODO: DEPENDS
	VERBATIM
)

add_custom_target(initrd ALL DEPENDS ${CMAKE_BINARY_DIR}/initrd.img)

add_custom_command(
	OUTPUT ${CMAKE_BINARY_DIR}/stella.iso
	COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/iso/boot/grub
	COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/conf/grub/grub.cfg ${CMAKE_BINARY_DIR}/iso/boot/grub/grub.cfg
	COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_BINARY_DIR}/kernel/kernel.bin ${CMAKE_BINARY_DIR}/iso/boot/stella.bin
	COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_BINARY_DIR}/initrd.img ${CMAKE_BINARY_DIR}/iso/boot/initrd.img
	COMMAND ${CMAKE_COMMAND} -P ${CMAKE_SOURCE_DIR}/tools/make-iso.cmake
	DEPENDS ${CMAKE_SOURCE_DIR}/conf/grub/grub.cfg
	DEPENDS kernel
	DEPENDS initrd
	VERBATIM
)

add_custom_target(iso ALL DEPENDS ${CMAKE_BINARY_DIR}/stella.iso)
