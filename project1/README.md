# MP2.
## Introduction.
This code is part of the Advanced Computational Techniques homework. The goal of this project is to compute the energy of different molecules at HF MP2 theory level. For this purpose we made a code in C using the [TREXIO](https://trex-coe.eu/trex-quantum-chemistry-codes/trexio) library.
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
@article{trexio_2023,
  author = {Posenitskiy, Evgeny and Chilkuri, Vijay Gopal and Ammar, Abdallah and Hapka, Micha{\l} and Pernal, Katarzyna and Shinde, Ravindra and Landinez Borda, Edgar Josu{\'{e}} and Filippi, Claudia and Nakano, Kosuke and Kohul{\'{a}}k, Otto and Sorella, Sandro and de Oliveira Castro, Pablo and Jalby, William and R{\'{\i}}os, Pablo L{\'{o}}pez and Alavi, Ali and Scemama, Anthony},
  title = {{TREXIO: A file format and library for quantum chemistry}},
  journal = {J. Chem. Phys.},
  volume = {158},
  number = {17},
  year = {2023},
  month = may,
  issn = {0021-9606},
  publisher = {AIP Publishing},
  doi = {10.1063/5.0148161}
}

## Credits.
1. [Ander Aleson.](https://github.com/AnderAleson)
2. Lucia Vidal.
3. [Alvaro Serrano.](https://github.com/aserranoTCCM)
