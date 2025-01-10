program main
    use sparsematrix
    implicit none
    type(SparseMatrixType) :: matrix1, matrix2, result_sparse
    real(8), allocatable :: A(:,:), B(:,:), C(:,:), C_sparse(:,:), C_hand(:,:), C_sparse_dense(:,:)
    integer :: number_of_multiplications
    real(8) :: start_time_hand, end_time_hand, time_taken_hand
    real(8) :: start_time_blas, end_time_blas, time_taken_blas
    real(8) :: start_time_sparse, end_time_sparse, time_taken_sparse
    logical :: matrices_are_equal_BLAS_hand, matrices_are_equal_BLAS_sparse
    integer :: n
    character(len=256) :: filename1, filename2, output_filename
    integer :: i, j
    real(8) :: tolerance
    integer :: output_unit, ierr
    real(8) :: filling_rate
    integer :: repeat_count, cmd_arg_count
 
    cmd_arg_count=command_argument_count()
    if (cmd_arg_count < 3) then
            print *, "Usage: ./[nameofyourprogram] [matrix1] [matrix2] [output_filename]"
            stop
    end if


    call get_command_argument(0, output_filename)
    call get_command_argument(1, filename1)
    call get_command_argument(2, filename2)
    call get_command_argument(3, output_filename)
    call get_command_argument(cmd_arg_count)

    if (cmd_arg_count < 3) then 
            print *, "Usage: ", trim(output_filename), "[matrix1] [matrix2] [output_filename]"
            stop
    end if 


    call read_symmetric_sparsematrix(trim(filename1), matrix1)

    call read_symmetric_sparsematrix(trim(filename2), matrix2)

    
    open(newunit=output_unit, file=trim(output_filename), status='replace', action='write', iostat=ierr)
    
    if (ierr/=0) then
            print *, "Error opening output file"
            stop
    end if 
    write(output_unit, *) '-------------------------------------------------------------------------------'
    write(output_unit, *) ''
    write(output_unit, *) ' SPARSE MATRIX MULTIPLICATION IN FORTRAN '
    write(output_unit, *) ''
    write(output_unit, *) '-------------------------------------------------------------------------------'
    
    ! Print the input matrices in sparse format
    write(output_unit, *) ''
    write(output_unit, *) 'INPUT MATRICES' 
    write(output_unit, *) ''
    write(output_unit, *) "~Sparse format~"
    write(output_unit, *) ''
    write(output_unit, *) 'MATRIX 1:'
    write(output_unit, *) 'Row Indices:', matrix1%row_indices
    write(output_unit, *) 'Column Indices:', matrix1%col_indices
    write(output_unit, *) 'Values:', matrix1%values
    write(output_unit, *) ''
    write(output_unit, *) 'MATRIX 2:'
    write(output_unit, *) 'Row Indices:', matrix2%row_indices
    write(output_unit, *) 'Column Indices:', matrix2%col_indices
    write(output_unit, *) 'Values:', matrix2%values
    write(output_unit, *) ''
    
    ! Transform sparse input matrices into dense format 

    call sparse_to_densematrix(matrix1, A)
    call sparse_to_densematrix(matrix2, B)
    write(output_unit, *) '~Dense format~'
    write(output_unit, *) ''

    ! Print the input matrices transformed into dense format
    
    write(output_unit, *) 'MATRIX 1:'
    call print_dense_matrix_to_file(A,output_unit)
    
    write(output_unit, *) ''
    write(output_unit, *) 'MATRIX 2:'
    call print_dense_matrix_to_file(B,output_unit)
    write(output_unit, *) ''
    
    allocate(C(matrix1%matrix_size, matrix1%matrix_size))
    allocate(C_sparse(matrix1%matrix_size, matrix1%matrix_size))
    allocate(C_hand(matrix1%matrix_size, matrix1%matrix_size))
    allocate(C_sparse_dense(matrix1%matrix_size, matrix1%matrix_size))
    
    repeat_count=100

    ! Timing dense matrix multiplication using handwritten routine
    call cpu_time(start_time_hand)
    do i=1, repeat_count
         call multiply_dense_by_hand(A, B, C_hand, matrix1%matrix_size)
    end do 
    call cpu_time(end_time_hand)
    time_taken_hand = (end_time_hand - start_time_hand)
        
    ! Timing dense matrix multiplication using BLAS
    call cpu_time(start_time_blas)
    do i=1, repeat_count
        call multiply_dense_BLAS(A, B, C, matrix1%matrix_size)
    end do
    call cpu_time(end_time_blas)
    time_taken_blas = end_time_blas - start_time_blas

    ! Timing sparse matrix multiplication
    call cpu_time(start_time_sparse)
    do i=1, repeat_count 
        call multiply_sparse(matrix1, matrix2, result_sparse, number_of_multiplications)
    end do
    call cpu_time(end_time_sparse)
    time_taken_sparse = end_time_sparse - start_time_sparse


    write(output_unit,*) 'RESULTING MATRICES USING THE THREE METHODS'
    write(output_unit, *)''
    ! Print the result of the dense matrix multiplication using BLAS routine
    write(output_unit, *) 'Result of dense matrix multiplication (BLAS):'
    call print_dense_matrix_to_file(C, output_unit)
    write(output_unit, *)''
    ! Print the result of the dense matrix multiplication using handwritten routine
    write(output_unit, *) 'Result of dense matrix multiplication (Handwritten):'
    call print_dense_matrix_to_file(C_hand, output_unit)
    write(output_unit, *) ''

    ! Print the resulting sparse matrix

    write(output_unit, *) 'Result of sparse matrix multiplication (Sparse):'
    write(output_unit, *) 'Row indices:', result_sparse%row_indices
    write(output_unit, *) 'Column indices:', result_sparse%col_indices
    write(output_unit, *) 'Values:', result_sparse%values
    write(output_unit, *) 'Actual number of multiplications', number_of_multiplications
    write(output_unit, *) ''
    ! Print the resulting sparse matrix but transformed into dense format
    call sparse_to_densematrix(result_sparse, C_sparse_dense)
    write(output_unit, *) 'Result of sparse matrix multiplication (Dense conversion):'

    call print_dense_matrix_to_file(C_sparse_dense, output_unit)

    write(output_unit, *) ''
   
    ! Compare the resulting dense matrixes using both dense procedures (BLAS and handwritten) 
    tolerance = 1.0e-6  
    matrices_are_equal_BLAS_hand = .true.

    do i = 1, size(C, 1)
        do j = 1, size(C, 2)
            if (abs(C(i, j) - C_hand(i, j)) > tolerance) then
                matrices_are_equal_BLAS_hand = .false.
                exit
            end if
        end do
    end do

    write(output_unit, *) ''
    
    ! Check if both BLAS and handwritten dense multiplications give the same result
    if (matrices_are_equal_BLAS_hand) then
        write(output_unit, *) '->The results from the matrix multiplication methods (BLAS and handwritten routine) match.'

        ! Convert the sparse matrix to dense format for an easier comparison before the comparison
        call sparse_to_densematrix(result_sparse, C_sparse_dense)

        ! Compare the resulting matrix for dense and sparse multiplication
        matrices_are_equal_BLAS_sparse = .true.
        do i = 1, size(C, 1)
            do j = 1, size(C, 2)
                if (abs(C(i, j) - C_sparse_dense(i, j)) > tolerance) then
                    matrices_are_equal_BLAS_sparse = .false.
                    exit
                end if
            end do
        end do

        if (matrices_are_equal_BLAS_sparse) then
            write(output_unit, *) '->The results from all three multiplication methods (sparse, BLAS, and handwritten) match.'
        else
            write(output_unit, *) '->The results from the sparse and dense matrix multiplication methods do NOT match.'
        end if

    else
        write(output_unit, *) '->The results from the matrix multiplication methods (BLAS and handwritten routine) do NOT match.'
    end if
    
    write(output_unit, *) ''
    write(output_unit, *) 'PROFILING AND SCALING ANALYSIS'
    write(output_unit, *) ''
    write(output_unit, *) 'Size of the resulting matrix:', result_sparse%matrix_size
    write(output_unit, *) ''
    call calculate_filling_rate(result_sparse, filling_rate)
    write(output_unit, *) 'Filling rate of the resulting matrix:', filling_rate, '%'
    write(output_unit, *) '-------------------------------------------------------------------------------'
    

    write(output_unit, *) ''
    write(output_unit, *) 'TIMING AND PERFORMANCE ANALYSIS'
    write(output_unit, *) ''
    write(output_unit, *) 'Time taken for dense matrix multiplication by hand: ', time_taken_hand
    write(output_unit, *) 'Time taken for dense matrix multiplication using DGEMM: ', time_taken_blas
    write(output_unit, *) 'Time taken for sparse matrix multiplication: ', time_taken_sparse
    write(output_unit, *) ''
end program main
