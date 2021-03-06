# DiRAC3-testsuite

## Benchmarks

### Extreme-Scaling

* [Grid](https://github.com/paboyle/Grid/) - Lattice quantum chromodynamics
* [MILCmk](https://asc.llnl.gov/CORAL-benchmarks/) - Lattice quantum chromodynamics
* [QPhiX](https://jeffersonlab.github.io/qphix/) - Lattice quantum chromodynamics

### Memory-Intensive

* [CloverLeaf3D](http://uk-mac.github.io/CloverLeaf3D/) - Magnetohydrodynamics on a structured grid
* [Gadget3-Eagle](http://icc.dur.ac.uk/Eagle/) (Private) - Smoothed-particle hydrodynamics
* [Stream](http://www.cs.virginia.edu/stream/) - Streaming memory bandwidth
* [Stride](https://asc.llnl.gov/CORAL-benchmarks/) - Strided memory bandwidth
* [Swift](http://icc.dur.ac.uk/swift/) - Smoothed-particle hydrodynamics

### Data-Intensive

* [IOR](https://sourceforge.net/projects/ior-sio/) - Filesystem I/O
* [Walls](http://www.damtp.cam.ac.uk/research/gr/public/cs_evol.html) (Private) - Cosmological domain walls on a structured grid

## Dependencies

* [CMake 3.x](https://cmake.org/download/)
* [Python 2.7.x](https://www.python.org/downloads/)
* [libtool](https://www.gnu.org/software/libtool/)
* [Automake >= 1.11](http://www.gnu.org/software/automake/)
* [HDF5](https://www.hdfgroup.org/downloads/index.html) (including h5cc and h5pcc for Swift)
* [METIS 5.x](http://glaros.dtc.umn.edu/gkhome/metis/metis/download) (recommended, improves Swift load balance)
* [FFTW >= 2.1.5](http://www.fftw.org/download.html) (configured for both single and double precision, see [here](http://www.hpcadvisorycouncil.com/pdf/GADGET-2_Best_Practices.pdf))
* [GSL](https://www.gnu.org/software/gsl/)

## Other requirements

SWIFT expects ```$CC``` and ```mpicc``` to have the same 'flavour' e.g. Intel, GCC, ...
  * You *might* need to set the ```I_MPI_CC``` environment variable for Intel MPI (as on DiRAC Complexity)
  * If (as on DiRAC COSMOS) the system ```mpicc``` cannot be configured, place a shell script like this before it in the path:

    ```
    #!/bin/sh
    icc "$@" # append MPI compiler, linker options as required
    ```

  * n.b. ```configure``` sets the environment variable ```CC=mpicc```, so the compiler (here ```icc```) must be named directly.

## Module File and Submission Script Template

Before building the benchmarks, three files must be created for a `hostname` and `compiler` of your choice:

* A shell script named `modules/modules.hostname.compiler` that loads all necessary modules.
* A CMake toolchain script named `cmake/toolchain.hostname.compiler.cmake` that specifies the compilers to use and defines additional variables regarding the hardware.
* A template shell script named `templates/submit.hostname` for submitting benchmarks to a batch job scheduler.

Sample module, toolchain and submission template scripts are provided for a range of systems.

## Build Instructions

The testsuite is downloaded, configured and built for the chosen `hostname` as below:

```
git clone --recursive git@github.com:DiRAC-benchmarks/DiRAC3-testsuite.git
cd DiRAC3-testsuite
source modules/modules.hostname.compiler
mkdir build
cd build
cmake .. -DCMAKE_TOOLCHAIN_FILE=../cmake/toolchain.hostname.compiler.cmake
make all
```

If you have access to the private benchmark repositories you should also pass the flag `-DDIRAC3_PRIVATE=TRUE` to `cmake`.

## Additional configuration for Archer Cray XC30

The benchmarks have been tested on the [Archer UK National Supercomputing Service](http://www.archer.ac.uk/) using Intel and GNU compilers. The modules used are given in `modules/modules.archer.intel` and `modules/modules.archer.gcc` respectively. The following additional configurations were necessary:

* The ```/home``` filesystem is not available on the compute nodes; we recommended building from source in ```/work```.

* To link with shared libraries, set `CRAYPE_LINK_TYPE=dynamic` when calling cmake and make.

* Archer's HDF5 module does not have the ```h5cc``` and ```h5pcc``` scripts required by Swift. A workaround is to create both scripts in ```PATH``` with the following body:

  ```
  #!/bin/sh
  cc "$@"
  ```

The final build command is then:

```
source modules/modules.archer.intel
cd build
CRAYPE_LINK_TYPE=dynamic cmake .. -DCMAKE_TOOLCHAIN_FILE=../cmake/toolchain.archer.intel.cmake -DDIRAC3_PRIVATE=TRUE
CRAYPE_LINK_TYPE=dynamic make all
```

## Additional configuration for Cosma5 IBM iDataPlex

The benchmarks have been tested on the [Cosma5 Cosmology Machine](https://www.cosma.dur.ac.uk) using Intel compilers. The following additional configurations were necessary:

* The variable `MKLROOT` should be set to `/cosma/local/intel/Parallel_Studio_XE_2016-update3/mkl` when calling make.

* The Intel compilers use the default GNU v4.4.6 that does not support all of the C++11 features needed by the Grid benchmark. But the GNU v5.3.0 module conflicts with the Intel compiler module. In `src/Grid/CMakeLists.txt` the additional compiler flag `-cxxlib=/cosma/local/gcc/5.3.0` and link flag `-Wl,-rpath=/cosma/local/gcc/5.3.0/lib64` need to be added to the configuration command.

The final build command is then:

```
source modules/modules.cosma.intel
cd build
cmake .. -DCMAKE_TOOLCHAIN_FILE=../cmake/toolchain.cosma.intel.cmake -DDIRAC3_PRIVATE=TRUE
env MKLROOT=/cosma/local/intel/Parallel_Studio_XE_2016-update3/mkl make all
```

## Additional configuration for Cosmos SGI UV200

The benchmarks have been tested on the [COSMOS UK National Cosmology Supercomputer](http://www.cosmos.damtp.cam.ac.uk/) using Clang (C and C++) and Intel (Fortran) compilers. The following additional configurations were necessary:

* CMake and Automake are outdated. Newer versions should be built and installed so that the executables are in `PATH`.

* Metis needs to be installed and its include and lib directories should be passed to `CPPFLAGS` and `LDFLAGS` respectively when calling make.

The final build command is then:

```
source modules/modules.cosmos.clang
cd build
cmake .. -DCMAKE_TOOLCHAIN_FILE=../cmake/toolchain.cosmos.clang.cmake -DDIRAC3_PRIVATE=TRUE
CPPFLAGS=-I/path/to/metis/include LDFLAGS=-L/path/to/metis/lib make all
```

## Running the Benchmarks

For each benchmark, a batch job submission script named `scripts/submit.benchmark.hostname` is generated. These can be submitted either manually or all together using `bash scripts/submit.all`. Each job calls another generated script called `scripts/run.benchmark.hostname` that runs the benchmark while forwarding the stdout and sterr streams to `outputs/out.benchmark.hostname` and `outputs/err.benchmark.hostname` respectively.
