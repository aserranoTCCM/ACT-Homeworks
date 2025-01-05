# MP2.
## Introduction.
This code is part of the Advanced Computational Techniques homework. The goal of this project is to compute the energy of different molecules at HF MP2 theory level. For this purpose we made a code in C using the [TREXIO](https://trex-coe.eu/trex-quantum-chemistry-codes/trexio) library.

In this directory you can find the code file (MP2_Lucia_Alvaro_Ander.c), a file with the indications to download the code and run it (INSTALL.md),a directory containing the inputs for the code (data), a directory containing the outputs of the tests to ensure that the program behaves as expected (outputs) and this README.md file containing the information about the directory structure
and the project.
## Runing the code.
To run the code the first step is to compile it
```console
gcc MP2_Lucia_Alvaro_Ander.c -o MP2_Lucia_Alvaro_Ander -ltrexio
```
This should create the executable. To run the executable you need to introduce as first argument the trexio file and second argument the name of the file where the results will be written.
```console
./MP2_Lucia_Alvaro_Ander h2o.h5 H2O.out
```

## Bibliography.
Posenitskiy, E., Chilkuri, V. G., Ammar, A., Hapka, M., Pernal, K., Shinde, R., Landinez Borda, E. J., Filippi, C., Nakano, K., Kohulák, O., Sorella, S., de Oliveira Castro, P., Jalby, W., López Ríos, P., Alavi, A., & Scemama, A. (2023). **TREXIO: A file format and library for quantum chemistry**. *J. Chem. Phys.*, 158(17). AIP Publishing. https://doi.org/10.1063/5.0148161


## Credits.
1. [Ander Aleson.](https://github.com/AnderAleson)
2. [Lucia Vidal.](https://github.com/luvidal-a)
3. [Alvaro Serrano.](https://github.com/aserranoTCCM)
