set(CMAKE_ASM_COMPILER "clang")
set(CMAKE_ASM-ATT_COMPILER "clang")
set(CMAKE_C_COMPILER "clang")
set(CMAKE_CXX_COMPILER "clang++")
set(CMAKE_Fortran_COMPILER "gfortran")
set(CMAKE_AR
    llvm-ar
    CACHE FILEPATH "Archive manager" FORCE
)
set(CMAKE_NM
    llvm-nm
    CACHE FILEPATH "Symbol table dumper" FORCE
)
set(CMAKE_RANLIB
    llvm-ranlib
    CACHE FILEPATH "Archive index generator" FORCE
)
