# Compilers
set(CMAKE_C_COMPILER       mpicc)
set(CMAKE_CXX_COMPILER     mpicxx)
set(CMAKE_Fortran_COMPILER mpifc)

# Hardware Specification
set(DIRAC3_HOST        kathleen)
set(HOST_CPUS_PER_NODE       40)
set(HOST_THREADS_PER_CPU      2)
set(HOST_COMPILER_ID      intel)
set(HOST_SUBMIT_COMMAND    qsub)
