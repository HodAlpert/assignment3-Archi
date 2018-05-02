
%macro check_malloc 0 
jne %%skip
call malloc_failed
%%skip:
%endmacro

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 	
section .data
    fs_print: DB "%d: buffer-%d",10, 0
    fs_long: DB "%lu", 0
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



main:

    enter 0x28,0 ;allocate space for local variables
    xor rbx, rbx
    mov qword n, -1

.read:
    add qword n, 1
    mov rdi, fs_print
    mov rsi, qword n
    mov rax, rsi
    shl rax, 3
    mov rdx, qword [buffer + rax-8]
    xor rax, rax
    call printf

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

    mov qword cLoop, 0
.readcheck:

    mov rdi, fs_print
    mov rsi, qword cLoop
    mov rax, rsi
    shl rax, 3
    mov rdx, qword [buffer+rax]
    xor rax, rax
    call printf
    add qword cLoop, 1
    mov rax, qword cLoop
    cmp rax, qword n
    jne .readcheck

    
    ;calloc(n, 8)
    mov rdi, qword n
    mov rsi, 0x8
    xor rax, rax
    call calloc
    cmp rax, 0
    check_malloc
    mov qword M, rax

    xor rcx, rcx
.copy:
    
    mov r8, qword [buffer + rcx]
    mov rax, qword M
    mov qword [rax + rcx], r8
    inc rcx
    cmp rcx, qword n
    jne .copy

    jmp .done
    mov rax, qword M ; rax is the address of M
    xor rcx, rcx ; i - "instuction pointer"
    mov qword i, rcx
    mov r8, qword [rax + rcx] ; M[i] = A
    mov r9, qword [rax + rcx + 1] ;M[i+1] = B
    mov r10, qword [rax + rcx + 2] ;M[i+2] = C
    jmp .check_SIC

.SIC_LOOP:
    mov rcx, qword i ;set rcx to i
    mov r8, qword [rax + rcx] ; M[i]
    mov r9, qword [rax + rcx + 1] ;M[i+1]
    mov r10, qword [rax + rcx + 2] ;M[i+2]
    
    mov rbx, qword [r8] ; M[M[i]]
    sub rbx, qword [r9] ; M[M[i+1]]
    cmp rbx, 0x0 ; if ( M[M[i]] -= M[M[i+1]] ) < 0 
    jge .else
    mov rbx, [r10]
    mov qword i, rbx ; i = M[M[i+3]]
    jmp .check_SIC

.else:
    add qword i, 3
    
.check_SIC:
    
    OR r8, r9
    OR r8, r10
    cmp r8, 0x0
    jne .SIC_LOOP

    cmp qword n, 0x0
    je .done
    xor rcx, rcx

.print_Loop:

    mov rdi, fs_long
    mov rax, qword M
    mov rsi, [rax + rcx]
    xor rax, rax
    call printf
    cmp rcx, 0x0
    jne .print_Loop

.done:

    leave
    ret

malloc_failed:
    mov rdi, fs_malloc_failed
    mov rax, 0
    call printf
    mov rax, 60
    syscall