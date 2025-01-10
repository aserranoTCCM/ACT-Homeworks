
# Explanation of the code
It contains two parts that need to be compiled: the sparsematrix module and the main program.

---

## Module: `sparsematrix`
This module, `sparsematrix`, is a Fortran implementation designed for handling sparse matrices and their operations. It includes utilities for reading, converting, and performing matrix multiplications using both dense and sparse matrix representations.

### Type: `SparseMatrixType`

This custom type represents a sparse matrix and contains the following fields:

- **`matrix_size`**: Integer, the size of the matrix (assumes a square matrix of size `matrix_size x matrix_size`).
- **`row_indices`**: Integer array, the row indices of the non-zero elements.
- **`col_indices`**: Integer array, the column indices of the non-zero elements.
- **`values`**: Real array, the values of the non-zero elements.
- **`is_symmetric`**: Logical, indicates whether the matrix is symmetric (default is `false`).

---

### Subroutine: `read_symmetric_sparsematrix`

**Purpose**: Reads a sparse matrix in symmetric format from a file and initializes a `SparseMatrixType` object.  
- **Inputs**:
  - `filename`: Name of the file containing the matrix data.
- **Outputs**:
  - `matrix`: A `SparseMatrixType` object populated with the matrix data.

The subroutine:
1. Reads the file line by line, extracting row indices, column indices, and values.
2. Allocates memory for the sparse matrix.
3. Verifies if the matrix is symmetric by checking mirrored entries.

---

### Subroutine: `sparse_to_densematrix`

**Purpose**: Converts a sparse matrix into a dense matrix representation.  
- **Inputs**:
  - `sparse`: A `SparseMatrixType` object.
- **Outputs**:
  - `dense_matrix`: A 2D dense matrix of size `[matrix_size, matrix_size]`.

The subroutine:
1. Initializes a dense matrix filled with zeros.
2. Assigns values from the sparse matrix to the corresponding positions in the dense matrix.
3. If the matrix is symmetric, fills both `(i, j)` and `(j, i)`.

---

### Subroutine: `multiply_dense_by_hand`

**Purpose**: Performs matrix multiplication manually on dense matrices.  
- **Inputs**:
  - `A`: First dense matrix.
  - `B`: Second dense matrix.
  - `N`: The size of the matrices (assumes square matrices of size `N x N`).
- **Outputs**:
  - `C`: Resulting dense matrix.

This subroutine uses three nested loops to compute the matrix product.

---

### Subroutine: `multiply_dense_BLAS`

**Purpose**: Uses the BLAS library (`dgemm`) for efficient dense matrix multiplication.  
- **Inputs**:
  - `A`: First dense matrix.
  - `B`: Second dense matrix.
  - `N`: The size of the matrices.
- **Outputs**:
  - `C`: Resulting dense matrix.

This subroutine leverages `dgemm` for optimized performance.

---

### Subroutine: `multiply_sparse`

**Purpose**: Multiplies two sparse matrices and produces a sparse matrix result.  
- **Inputs**:
  - `matrix1`: First sparse matrix (`SparseMatrixType`).
  - `matrix2`: Second sparse matrix.
- **Outputs**:
  - `result`: Resulting sparse matrix.
  - `number_of_multiplications`: The total number of multiplications performed.

This subroutine iterates through the non-zero elements of the two input matrices, computes products when indices align, and accumulates the results into the output sparse matrix.

---

### Subroutine: `print_dense_matrix_to_file`

**Purpose**: Prints a dense matrix to a specified file.  
- **Inputs**:
  - `matrix`: The dense matrix to print.
  - `unit`: The file unit identifier.

If the matrix size is small (`<= 10`), it uses formatted output; otherwise, it uses unformatted output.

---

### Subroutine: `calculate_filling_rate`

**Purpose**: Calculates the filling rate of a sparse matrix as a percentage.  
- **Inputs**:
  - `matrix`: A `SparseMatrixType` object.
- **Outputs**:
  - `filling_rate`: The percentage of non-zero elements relative to the total number of elements.

---

## Features Summary

1. **Sparse Matrix Representation**: Efficiently stores non-zero elements.
2. **Symmetry Detection**: Identifies symmetric matrices automatically.
3. **Conversion Tools**: Transforms sparse matrices into dense format.
4. **Matrix Multiplication**:
   - Manual dense multiplication.
   - Optimized dense multiplication with BLAS.
   - Sparse matrix multiplication.
5. **Output and Analysis**:
   - Writes dense matrices to files.
   - Computes the filling rate of sparse matrices.

---

## Example Use Cases

1. **Reading a Sparse Matrix**:
   ```fortran
   type(SparseMatrixType) :: matrix
   call read_symmetric_sparsematrix('matrix_file.txt', matrix)
---
## Program: main.f90

This document explains the functionality of a Fortran program that reads two sparse matrices, performs various operations, and compares the results. The program leverages the `sparsematrix` module and demonstrates dense and sparse matrix multiplications while profiling their performance.

---

## Program Overview

The main program performs the following steps:

1. **Argument Parsing**: It reads the command-line arguments to obtain the filenames of the two sparse matrices and the output file.
2. **Sparse Matrix Reading**: It loads two sparse matrices from files in a symmetric sparse format.
3. **Matrix Format Transformation**: The sparse matrices are converted into dense format for comparison with dense multiplication methods.
4. **Matrix Multiplication**:
   - Dense matrix multiplication using both handwritten and BLAS (DGEMM) routines.
   - Sparse matrix multiplication using a specialized routine.
5. **Results Validation**: Compares the results of the three multiplication methods to ensure correctness.
6. **Profiling**: Reports time taken by each method and the filling rate of the resulting sparse matrix.
7. **Output**: Writes all results, including profiling data, to the output file.

---

## Key Program Sections

### 1. **Command-Line Argument Parsing**
The program uses `get_command_argument` to parse arguments:
- `filename1`: Input file for the first sparse matrix.
- `filename2`: Input file for the second sparse matrix.
- `output_filename`: File to store the results and analysis.

### 2. **Sparse Matrix Reading**
The program uses `read_symmetric_sparsematrix` to read two sparse matrices.
- The matrices are stored as instances of `SparseMatrixType` defined in the `sparsematrix` module.

### 3. **Sparse-to-Dense Transformation**
The sparse matrices are converted to dense format using `sparse_to_densematrix` for:
- Printing the matrices in dense format.
- Performing dense matrix multiplications.

### 4. **Matrix Multiplications**
#### Handwritten Dense Multiplication
- Uses nested loops to compute the product of two dense matrices.
- Timed using `cpu_time`.

#### Dense Multiplication with BLAS
- Calls `multiply_dense_BLAS` to perform DGEMM-based multiplication.
- Optimized and faster than the handwritten method.

#### Sparse Matrix Multiplication
- The program calls `multiply_sparse` to compute the product in sparse format.
- The sparse result is also converted to dense format for comparison.

### 5. **Results Comparison**
#### Dense Methods Comparison
- Compares results from BLAS and handwritten methods using an element-wise tolerance.

#### Sparse vs. Dense Methods Comparison
- Converts the sparse result into dense format.
- Compares the dense representation of the sparse result with the BLAS result.

### 6. **Profiling and Scaling Analysis**
The program calculates:
- **Matrix Filling Rate**: The percentage of non-zero elements in the resulting sparse matrix.
- **Execution Times**: Time taken for each multiplication method.

### 7. **Output**
Results are written to the output file, including:
- Sparse and dense formats of input matrices.
- Resulting matrices from all three methods.
- Comparison results and profiling data.

---

## Key Subroutines Used

### `read_symmetric_sparsematrix`
- Reads sparse matrix data from a file.
- Ensures the matrix is symmetric.

### `sparse_to_densematrix`
- Converts a sparse matrix to dense format.

### `multiply_dense_by_hand`
- Computes dense matrix multiplication using nested loops.

### `multiply_dense_BLAS`
- Uses DGEMM from BLAS for dense matrix multiplication.

### `multiply_sparse`
- Multiplies two sparse matrices efficiently.

### `print_dense_matrix_to_file`
- Prints a dense matrix to the output file.

### `calculate_filling_rate`
- Computes the filling rate of a sparse matrix.

---

## Example Usage

### Command to Run
```bash
./matrix_program matrix1.txt matrix2.txt output.txt
```
---

## Performance Metrics

-Dense Multiplications: The BLAS method should outperform the handwritten routine due to its optimized implementation.
-Sparse Multiplication: Efficient for large sparse matrices, offering significant performance benefits in memory and computation.
This program is a comprehensive demonstration of matrix multiplication techniques and performance profiling, suitable for large-scale scientific computations involving sparse matrices

	
An example can be found in the following graph. I multiplied every 125x125 matrix from the output folder with each other and compare how much time it took for the multiplication to end for each of the three multiplication methods. 

![[IMAGES/image.png]]

Here we can see that the sparse multiplication method is very efficient when the degree of filling is very small. Once this percentage is increased, the timing scales the most. 
Out of the dense multiplication routines, the DGEMM routine is a little bit more efficient than the handwritten one. Their efficiency stays similiar when the filling percentage of the resulting matrices increases. 
Here is a more detailed graph were we can see that the sparse method is more efficient for "emptier" matrices than multiplicating them in a dense format. 
![[IMAGES/actfortran.png]] 
