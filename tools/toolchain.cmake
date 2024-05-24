# CMake toolchain file for Bunnix
# To cross-compile CMake-based software for Bunnix, use
# cmake -DCMAKE_TOOLCHAIN_FILE=path/to/this/file.cmake

set(CMAKE_SYSTEM_NAME Bunnix)

set(CMAKE_C_COMPILER   x86_64-bunnix-gcc)
set(CMAKE_CXX_COMPILER x86_64-bunnix-g++)

# XXX: Edit me!
set(CMAKE_FIND_ROOT_PATH  /home/sircmpwn/sources/bunnix/target/root/)

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
