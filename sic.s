
%macro check_malloc 0 
jne %%skip
call malloc_failed
%%skip:
%endmacro

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 	
section .data
    fs_printline: DB 10, 0
    fs_print: DB "%d",10, 0
    fs_long: DB "%lu ", 0
	fs_malloc_failed: DB "A call to malloc() failed", 10, 0
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 
section .bss
    buffer: resq 4096
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 
section .text
    
    global main
    
    global malloc_failed

    extern calloc
    extern free
    extern scanf
    extern printf


%xdefine M qword [rbp-0x8]
%xdefine n qword [rbp-0x10]
%xdefine i qword [rbp-0x18]
%xdefine bufftemp qword [rbp-0x20]
%xdefine cLoop qword [rbp-0x28]
%xdefine M_i qword [rbp-0x30]
%xdefine M_i1 qword [rbp-0x38]
%xdefine M_i2 qword [rbp-0x40]
%xdefine M_M_i qword [rbp-0x48]
%xdefine M_M_i1 qword [rbp-0x50]
%xdefine M_M_i2 qword [rbp-0x58]


main:

    enter 0x58,0 ;allocate space for local variables
    xor rbx, rbx
    mov qword n, -1

.read:
    add qword n, 1
    
    ;scanf("%lu", &buff[n]);
    mov rdi, fs_long
    lea rsi, [rbp-0x20] ; bufftemp
    xor rax, rax
    call scanf
    mov rbx, qword bufftemp
    mov rcx, qword n
    shl rcx, 3
    mov qword [buffer + rcx], rbx
    cmp eax, -1 ; if we reached EOF
    jne .read

    ;calloc(n, 8)
    mov rdi, qword n
    mov rsi, 0x8
    xor rax, rax
    call calloc
    cmp rax, 0
    check_malloc
    mov qword M, rax

    mov qword cLoop, 0
.copy:
    mov rcx, qword cLoop
    shl rcx, 3 
    mov rbx, qword [buffer + rcx]
    mov rax, qword M
    mov qword [rax + rcx], rbx
    add qword cLoop, 1
    mov rcx, qword cLoop
    cmp rcx, qword n
    jne .copy
 
    mov qword i, 0 ; i - "instuction pointer"
    jmp .check_SIC

.SIC_LOOP:

    mov rax, qword M
    mov r8, qword M_i
    shl r8, 3
    add rax, r8
    mov rax, qword [rax] ; M[M[i]]
    mov qword M_M_i, rax

    mov rax, qword M
    mov r9, qword M_i1
    shl r9, 3
    add rax, r9
    mov rax, qword [rax] ; M[M[i+1]]
    mov qword M_M_i1, rax

    mov rax, qword M
    mov r9, qword M_i2
    shl r10, 3
    add rax, r10
    mov rax, qword [rax] ; M[M[i+2]]
    mov qword M_M_i2, rax

    ; M[M[i]] -= M[M[i+1]]
    mov rbx, qword M_M_i
    mov rcx, qword M_M_i1
    sub rbx, rcx 
    
    mov rax, qword M
    mov r8, qword M_i
    shl r8, 3
    add rax, r8
    mov qword [rax], rbx ; M[M[i]] = M[M[i]] - M[M[i+1]]
    
    test rbx, rbx ; if ( M[M[i]] -= M[M[i+1]] ) < 0 
    jns .else
    
    mov rax, qword M_i2 ;i = M[i+2]
    mov qword i, rax

    jmp .check_SIC

.else:
    add qword i, 3
    
.check_SIC:

    mov rcx, qword i ;set rcx to i
    shl rcx, 3
    mov rax, qword M
    mov r8, qword [rax + rcx] ; M[i]
    mov qword M_i, r8

    mov rcx, qword i ;set rcx to i+1
    add rcx, 1
    shl rcx, 3
    mov rax, qword M
    mov r9, qword [rax + rcx] ;M[i+1]
    mov qword M_i1, r9

    mov rcx, qword i ;set rcx to i+2
    add rcx, 2
    shl rcx, 3
    mov rax, qword M
    mov r10, qword [rax + rcx] ;M[i+2]
    mov qword M_i2, r10

    mov r8, qword M_i
    mov r9, qword M_i1
    mov r10, qword M_i2
    OR r8, r9
    OR r8, r10
    cmp r8, 0x0
    jne .SIC_LOOP

    cmp qword n, 0x0
    je .done

    mov qword cLoop, 0
.printRes:

    mov rdi, fs_long
    mov rax, qword cLoop
    shl rax, 3
    mov rsi, qword M
    add rsi, rax
    mov rsi, [rsi]
    xor rax, rax
    call printf
    add qword cLoop, 1
    mov rax, qword cLoop
    cmp rax, qword n
    jne .printRes

    mov rdi, fs_printline
    xor rax,rax
    call printf
.done:

    leave
    ret

malloc_failed:
    mov rdi, fs_malloc_failed
    mov rax, 0
    call printf
    mov rax, 60
    syscall