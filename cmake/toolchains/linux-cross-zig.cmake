cmake_minimum_required(VERSION 3.25)

# Experimental cross-compile toolchain using Zig as a cross C/C++ compiler
# Target: x86_64 Linux (musl)

set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR x86_64)

# Locate Zig: honor user-provided ZIG_EXECUTABLE, else search PATH for 'zig'
if(NOT DEFINED ZIG_EXECUTABLE OR ZIG_EXECUTABLE STREQUAL "")
    find_program(ZIG_EXECUTABLE NAMES zig)
endif()

if(NOT ZIG_EXECUTABLE)
    message(FATAL_ERROR "Zig executable not found. Install Zig and ensure it is on PATH, or pass -DZIG_EXECUTABLE=full\\ path\\ to\\ zig(.exe)")
endif()

set(CMAKE_C_COMPILER   ${ZIG_EXECUTABLE})
set(CMAKE_CXX_COMPILER ${ZIG_EXECUTABLE})

# Use zig cc / zig c++ modes
set(CMAKE_C_COMPILER_TARGET   x86_64-linux-musl)
set(CMAKE_CXX_COMPILER_TARGET x86_64-linux-musl)

set(CMAKE_C_COMPILER_FRONTEND_VARIANT   "GNU")
set(CMAKE_CXX_COMPILER_FRONTEND_VARIANT "GNU")

set(CMAKE_C_STANDARD   11)
set(CMAKE_CXX_STANDARD 17)

# Tell CMake how to invoke Zig for C/C++
set(CMAKE_C_COMPILER_ARG1   cc)
set(CMAKE_CXX_COMPILER_ARG1 c++)

# Do not try to run test executables when probing the toolchain
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# Prefer lld and PIC for shared libs
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -fuse-ld=lld")
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -fuse-ld=lld")

# Position independent code by default
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Linux specific defs
add_compile_definitions(_LINUX)

# Note: Choose generator on the command line, e.g. -G Ninja

# ----------------------------------------------------------------------------
# Provide archiver (ar/ranlib) using Zig subcommands to avoid CMAKE_AR-NOTFOUND
# ----------------------------------------------------------------------------
# Use zig's built-in ar/ranlib to create static archives when needed.
set(_ZIG_AR_COMMAND   "\"${ZIG_EXECUTABLE}\" ar")
set(_ZIG_RANLIB_CMD   "\"${ZIG_EXECUTABLE}\" ranlib")

# C rules
set(CMAKE_C_ARCHIVE_CREATE "<CMAKE_COMMAND> -E remove -f <TARGET>; ${_ZIG_AR_COMMAND} qc <TARGET> <OBJECTS>")
set(CMAKE_C_ARCHIVE_APPEND "${_ZIG_AR_COMMAND} q  <TARGET> <OBJECTS>")
set(CMAKE_C_ARCHIVE_FINISH "${_ZIG_RANLIB_CMD} <TARGET>")

# CXX rules
set(CMAKE_CXX_ARCHIVE_CREATE "<CMAKE_COMMAND> -E remove -f <TARGET>; ${_ZIG_AR_COMMAND} qc <TARGET> <OBJECTS>")
set(CMAKE_CXX_ARCHIVE_APPEND "${_ZIG_AR_COMMAND} q  <TARGET> <OBJECTS>")
set(CMAKE_CXX_ARCHIVE_FINISH "${_ZIG_RANLIB_CMD} <TARGET>")

