module sparsematrix
    implicit none

    type :: SparseMatrixType
        integer :: matrix_size
        integer, allocatable :: row_indices(:)
        integer, allocatable :: col_indices(:)
        real(8), allocatable :: values(:)
        logical :: is_symmetric = .false.  ! Indica si la matriz es simétrica
    end type SparseMatrixType

contains

    subroutine read_symmetric_sparsematrix(filename, matrix)
        character(len=*), intent(in) :: filename
        type(SparseMatrixType), intent(out) :: matrix
        integer :: i, n, unit, max_row, max_col, ierr
        integer :: row, col
        real(8) :: value

        open(newunit=unit, file=filename, status='old', action='read', iostat=ierr)
        if (ierr /= 0) then
            print *, "Error opening file: ", trim(filename)
            stop
        end if

        max_row = 0
        max_col = 0
        n = 0

        do while (.true.)
            read(unit, *, iostat=ierr) row, col, value
            if (ierr /= 0) exit
            if (row <= 0 .or. col <= 0) then
                print *, 'Error: invalid row or column index.'
                stop
            end if
            n = n + 1
            if (row > max_row) max_row = row
            if (col > max_col) max_col = col
        end do

        rewind(unit)

        allocate(matrix%row_indices(n))
        allocate(matrix%col_indices(n))
        allocate(matrix%values(n))

        n = 0
        do while (.true.)
            read(unit, *, iostat=ierr) row, col, value
            if (ierr /= 0) exit
            n = n + 1
            matrix%row_indices(n) = row
            matrix%col_indices(n) = col
            matrix%values(n) = value
        end do

        close(unit)

        matrix%matrix_size = max(max_row, max_col)

        if (any(matrix%row_indices < 1) .or. any(matrix%col_indices < 1) .or. &
            any(matrix%row_indices > matrix%matrix_size) .or. any(matrix%col_indices > matrix%matrix_size)) then
            print *, 'Error: Invalid index in sparse matrix data.'
            stop
        end if

        ! Verificar si la matriz es simétrica
        matrix%is_symmetric = .true.
        do i = 1, n
            if (matrix%row_indices(i) /= matrix%col_indices(i)) then
                if (.not. any(matrix%row_indices == matrix%col_indices(i) .and. &
                              matrix%col_indices == matrix%row_indices(i) .and. &
                             matrix%values == matrix%values(i))) then
                    matrix%is_symmetric = .false.
                    exit
                end if
            end if
        end do
    end subroutine read_symmetric_sparsematrix

    subroutine sparse_to_densematrix(sparse, dense_matrix)
        type(SparseMatrixType), intent(in) :: sparse
        real(8), allocatable, intent(out) :: dense_matrix(:,:)
        integer :: i

        allocate(dense_matrix(sparse%matrix_size, sparse%matrix_size))
        dense_matrix = 0.0

        do i = 1, size(sparse%row_indices)
            dense_matrix(sparse%row_indices(i), sparse%col_indices(i)) = sparse%values(i)
            if (sparse%is_symmetric .and. sparse%row_indices(i) /= sparse%col_indices(i)) then
                dense_matrix(sparse%col_indices(i), sparse%row_indices(i)) = sparse%values(i)
            end if
        end do
    end subroutine sparse_to_densematrix

    subroutine multiply_dense_by_hand(A, B, C, N)
        real(8), intent(in) :: A(:,:), B(:,:)
        real(8), intent(out) :: C(:,:)
        integer, intent(in) :: N
        integer :: i, j, k

        C = 0.0
        do i = 1, N
            do j = 1, N
                do k = 1, N
                    C(i, j) = C(i, j) + A(i, k) * B(k, j)
                end do
            end do
        end do
    end subroutine multiply_dense_by_hand

    subroutine multiply_dense_BLAS(A, B, C, N)
        real(8), intent(in) :: A(:,:), B(:,:)
        real(8), intent(out) :: C(:,:)
        integer, intent(in) :: N
        real(8) :: alpha, beta

        alpha = 1.0
        beta = 0.0
        call dgemm('N', 'N', N, N, N, alpha, A, N, B, N, beta, C, N)
    end subroutine multiply_dense_BLAS

    subroutine multiply_sparse(matrix1, matrix2, result, number_of_multiplications)
        type(SparseMatrixType), intent(in) :: matrix1, matrix2
        type(SparseMatrixType), intent(out) :: result
        integer, intent(out) :: number_of_multiplications

        integer :: i, j, k, idx, n
        integer, allocatable :: temp_row_indices(:), temp_col_indices(:)
        real(8), allocatable :: temp_values(:)
        real(8) :: value
        logical :: found

        number_of_multiplications = 0
        n = size(matrix1%values) * size(matrix2%values)
        allocate(temp_row_indices(n))
        allocate(temp_col_indices(n))
        allocate(temp_values(n))

        idx = 0

        do i = 1, size(matrix1%values)
            do j = 1, size(matrix2%values)
                if (matrix1%col_indices(i) == matrix2%row_indices(j)) then
                    value = matrix1%values(i) * matrix2%values(j)
                    found = .false.
                    do k = 1, idx
                        if (temp_row_indices(k) == matrix1%row_indices(i) .and. &
                            temp_col_indices(k) == matrix2%col_indices(j)) then
                            temp_values(k) = temp_values(k) + value
                            found = .true.
                            exit
                        end if
                    end do
                    if (.not. found) then
                        idx = idx + 1
                        temp_row_indices(idx) = matrix1%row_indices(i)
                        temp_col_indices(idx) = matrix2%col_indices(j)
                        temp_values(idx) = value
                    end if
                    number_of_multiplications = number_of_multiplications + 1
                end if
            end do
        end do

        allocate(result%row_indices(idx))
        allocate(result%col_indices(idx))
        allocate(result%values(idx))

        result%row_indices = temp_row_indices(1:idx)
        result%col_indices = temp_col_indices(1:idx)
        result%values = temp_values(1:idx)
        result%matrix_size = matrix1%matrix_size

        result%is_symmetric = matrix1%is_symmetric .and. matrix2%is_symmetric

        deallocate(temp_row_indices, temp_col_indices, temp_values)
    end subroutine multiply_sparse
    
    subroutine print_dense_matrix_to_file(matrix, unit)
       real(8), intent(in) :: matrix(:,:)
       integer, intent(in) :: unit
       integer :: i, n

       n=size(matrix,1) 

       if (n<=10) then 
               do i=1,n
                        write(unit,'(10F8.3)') matrix(i,:)
               end do
       else 
               do i=1, n
               write(unit, *) matrix(i, :)
               end do 
       end if

    end subroutine print_dense_matrix_to_file

    subroutine calculate_filling_rate(matrix, filling_rate)
          type(SparseMatrixType), intent (in) :: matrix
          real(8), intent(out) :: filling_rate
          integer :: total_elements, non_zero_elements
          
          total_elements = matrix%matrix_size * matrix%matrix_size
          non_zero_elements=size(matrix%values)

          filling_rate=(real(non_zero_elements)/real(total_elements))*100.0
    end subroutine calculate_filling_rate
            

end module sparsematrix

