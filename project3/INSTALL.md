Project 3 consists on a C code used to run Molecular Dynamics by using the Verlet Algorithm. Here a detailed explanation of how to run the code can be found.

## Getting Started
### 1. Download and access to the necessary files
- **1.a) Clone the Repository**

First, clone the repository to your local machine using the following command on the terminal:

```git clone https://github.com/aserranoTCCM/ACT-Homeworks```

Once you have the repository downloaded, navigate to the /src folder containing the code.

- **1.b) Download only the code and inputs**

This is only mandatory in case you don't want to download the whole repository, if you already downloaded the repository, skip these intructions.

First, navigate in the web version of the repository to the /src file and download the MD code by clicking on the download button on the top right corner.

Second, download the inputs directory in a similar way.

## Compiling the code
Once you have downloaded the code, inputs and you have found the code in your system use the following command to compile it.

```gcc MD_simulation.c -lm```

This should generate an a.out code in the directory ready to be executed. In case you want a different name you can use.

```gcc MD_simulation.c -o YourExecutableName -lm```

In case that you cannot compile it using gcc because of not having the compiler intalled, you should install it following the intructions the terminal gives you.

## Running the code
Once compiled the code you can run it by using the following command.

```./a.out /path_where_the_input_to_study_is_stored```





