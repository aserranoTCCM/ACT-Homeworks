# Molecular Dynamics Directory

This directory contains all the relevant files for project 3.

Project 3 consists on the creation of a C code which purpose is to illustrate key concepts in MD simulations.

**A breakdown of each file can be found below.**

- **INSTALL.md:** The purpose of this file is to bring clear instructions on how to compile and run the program. In addition a short explanation of how to use github will be given as well.

- **Dynamics.pdf:** This is the file from where the instructions of how to make the Molecular Dynamic code have been followed. In it we can find all the formulas and algorithm used.

- **Inputs directory:** This directory is used to store all the input used to test the code. It it we can find the original Ar input as well as other ones.

- **Tests directory:** This directory is used to store all the trajectories calculated with the code. The purpose of each trajectory is to later on use it on an external software to visualize the dynamic.

- **SRC directory:** This directory is used to store all the relevant source files of the program. The C code can be found inside this directory.

- **Authors.md:** In this file, all the collaborators that have worked on the code can be found.


# Code Explanation

This section is used to explain the key features of the code.

To begin with the explanation, here we present a Molecular Dynamics code that simulates the movement of atoms based on their initial positions and velocites. Specifically, a program that illustrates key concepts in Molecular Dynamics simulations has been developed. The program reads force field parameters as well as the initial positions of atoms from an input file and after each small displacement of atoms according to their velocities, the updated coordinates will be saved to an output file, enabling the creation of a video animation with an external tool such as Jmol or Molden.

**Below a breakdown of the code can be found.**

## -Reading in the input-
The first thing to do for our program to work is to read in the number of atoms, coordinates and mass for the specific molecule (input). The corresponding lines that perform these actions can be found next.

![1](https://github.com/user-attachments/assets/5ffac3c6-c0c0-458d-b66c-13e1ccfec4f0)

This first block of lines with the corresponding ones in /int main/ are in charge of reading the first line of the input in order to get the number of atoms for the specific molecule. It uses the prototype specified in the dynamics.pdf explanation and in addition handles some erros as for example reading in a negative number of atoms.

![2](https://github.com/user-attachments/assets/2a492804-0a14-42f3-a54e-f0d02e395bd5)

Then this block of lines is in charge of reading in the coordinates and mass for each atom. Specifically, what it does is to read line by line depending on the number of atoms (number of atoms = number of lines) and stores in a coordiantes array the coordinates of the atom (coord[i][0] ...) and in a mass array the mass.

## -Calculation of distances-
Once we have all the data, we can proceed to calculate the internuclear distances between each pair of atoms.

![3](https://github.com/user-attachments/assets/541d906f-e538-4959-ac58-698982f49ab7)

Concretelly, what this does is to read line by line for **i** and line by line but for **j=i+1**, being i the first line of the coord array, and then calculate the distance of the vector between the two atoms as the formula states.

![dist](https://github.com/user-attachments/assets/8ecfb9b6-b163-49dd-b4ee-7af7065cdca4)

We do for each **i** a scan of all other **j (j=i+1, j++)**, and we calculate the differences and later on the distance, paying attention not to make redundant operations. In order to use the sqrt function in C we need to include <math.h>, therefore compiling using the -lm option. Finally, storing the distances in a distance array.

## -Calculation of the Lennard-Jones potential-
Once calculated the distances, we are able to calculate the potential energy of the system with the following formulas.

![lena](https://github.com/user-attachments/assets/88f5ee8b-b5c6-4994-b857-61c3cad8abd4)

And the piece of code that performs this is:

![4](https://github.com/user-attachments/assets/cb64a6d3-c97d-4673-906a-59997f3ecbaa)

Here we need to make use of the distances array as well as the epsilon, sigma values and number of atoms. Following the formulas we make two loops, one from **i = 0** to less than the number of atoms and another one from **j=i+1** to less than the number of atoms applying the pow(x,n) operation to the power of numbers and applying the potential energy formula, adding togheter the results for each r (distance of atom pair).

## -Calculation of the Kinetic energy and Total energy of the system-
Now we write functions to calculate the Kinetic energy and total energy. For this we apply the following formulas.

![kinetic](https://github.com/user-attachments/assets/660db2fb-43d9-4264-a85f-e27292e8d67c)

![total](https://github.com/user-attachments/assets/058ea22d-14c5-484b-92b0-6f056f334997)

The piece of code that does this is the following one:

![5](https://github.com/user-attachments/assets/a344edfd-d92d-45d6-92dc-fccf23298d15)

This consists on two functions being the first one to calculate the kinetic energy where we make use of a loop throughout the velocities array which is originally set to 0.

## -Computing the acceleration-
Now we move on to computing the acceleration as the formula below shows.

![acceleration](https://github.com/user-attachments/assets/cc176c14-d5f2-474a-8617-ac26dc125cc5)

This is the analytical expression and it is applied in the code with the following lines:

![6](https://github.com/user-attachments/assets/70ef2957-d8c4-4456-93b2-632d00e363e3)

As we can see this procedure is similar to the one of Lennard-Jones, we again need the distances array and coordinates as well as the sigma and epsilon values. Then the formula is applied by the use of two loops. Finally computing the acceleration vector for each atom and storing it in a double precision array.

## -Implementing the molecular dynamics-




