cmake_minimum_required(VERSION 3.13)
project(MergeReturnPass)

# ── Find LLVM ────────────────────────────────────────────────────────────────
find_package(LLVM REQUIRED CONFIG)

message(STATUS "Found LLVM ${LLVM_PACKAGE_VERSION}")
message(STATUS "Using LLVMConfig.cmake in: ${LLVM_DIR}")

list(APPEND CMAKE_MODULE_PATH "${LLVM_CMAKE_DIR}")
include(AddLLVM)

add_definitions(${LLVM_DEFINITIONS})
include_directories(${LLVM_INCLUDE_DIRS})

# ── Pass shared library ───────────────────────────────────────────────────────
add_library(MergeReturnPass MODULE
        MergeReturnPass/MergeReturnPass.cpp
)

# Suppress LLVM's own RTTI/EH to match the way opt is built.
target_compile_options(MergeReturnPass PRIVATE
    -fno-rtti
)

set_target_properties(MergeReturnPass PROPERTIES
    PREFIX ""            # no "lib" prefix — matches convention in these projects
    CXX_STANDARD 17
    CXX_STANDARD_REQUIRED ON
)
