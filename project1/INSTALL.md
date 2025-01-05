# Installation of the code.
To download the code you can download it directly from the GitHub or you can download it from the terminal by typing:

```console
wget https://github.com/aserranoTCCM/ACT-Homeworks/blob/master/project1/MP2_Lucia_Alvaro_Ander.c
```

# Compilation and running the code.
To compile the code is necesarry to have installed the [TREXIO](https://github.com/TREX-CoE/trexio) library. 

TREXIO depends on the HDF5 library, which can be installed using your
package manager. On Ubuntu:
```console
sudo apt install libhdf5-dev
```
On macOS:
```console
brew install hdf5
```
Download TREXIO [here](https://github.com/TREX-CoE/trexio/releases/download/v2.5.0/trexio-2.5.0.tar.gz) and install it on your system:
```console
tar -zxvf trexio-2.5.0.tar.gz
```
```console
cd trexio-2.5.0
```
```console
./configure
```
```console
make
```
```console
sudo make install
```

This installs the TREXIO library to /usr/local/lib. Documentation for TREXIO is available [here](https://trex-coe.github.io/trexio/.).

To compile the code just type:


