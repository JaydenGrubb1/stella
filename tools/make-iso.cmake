if(CMAKE_HOST_SYSTEM_NAME MATCHES Linux)
	if(VERBOSE)
		execute_process(COMMAND grub-mkrescue -o ${CMAKE_BINARY_DIR}/stella.iso ${CMAKE_BINARY_DIR}/iso)
	else()
		execute_process(COMMAND grub-mkrescue -o ${CMAKE_BINARY_DIR}/stella.iso ${CMAKE_BINARY_DIR}/iso OUTPUT_QUIET ERROR_QUIET)
	endif()
else()
	message(FATAL_ERROR "Unsupported host system: ${CMAKE_HOST_SYSTEM_NAME}")
endif()