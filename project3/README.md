# Molecular Dynamics Directory

This directoy contains all the relevant files for project 3.

Project 3 consists on the creation of a C code which purpose is to illustrate key concepts in MD simulations. The program will read force field parameters and the initial positions of atoms from an input file and after each small displacement of atoms according to their velocieties, the updated coordinates will be saved to an output file, enabling the creation of a video animation with an external tool.

**A breakdown of each file can be found below.**

- **INSTALL.md:** The purpose of this file is to bring clear instructions on how to compile and run the program. In addition a short explanation of how to use github will be given as well.

- **Dynamics.pdf:** This is the file from where the instructions of how to make the Molecular Dynamic code have been followed. In it we can find all the formulas and algorithm used.

- **Inputs directory:** This directory is used to store all the input used to test the code. It it we can find the original Ar input as well as other ones.

- **Tests directory:** This directory is used to store all the trajectories calculated with the code. The purpose of each trajectory is to later on use it on an external software to visualize the dynamic.

- **SRC directory:** This directory is used to store all the relevant source files of the program. The C code can be found inside this directory.

- **Authors.md:** In this file, all the collaborators that have worked on the code can be found.


# Code Explanation

This section is used to explain the key features of the code.

To begin with, here we present a Molecular Dynamics code that simulates the movement of atoms based on their initial positions and velocites. Specifically, a program that illustrates key concepts in MD simulations has been developed. The program reads force field parameters as well as the initial positions of atoms from an input file and after each small displacement of atoms according to their velocities, the updated coordinates will be saved to an output file, enabling the creation of a video animation with an external tool such as Jmol or Molden.

**Below a breakdown of the code can be found.**


