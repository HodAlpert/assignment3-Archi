
%macro check_malloc 0 
jne %%skip
call malloc_failed
%%skip:
%endmacro

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 	
section .data
    fs_print: DB "** %d **",10, 0
    fs_print_loop: DB "%d: buffer-%d",10, 0
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

; mov qword cLoop, 0
; .readcheck:

;     mov rdi, fs_print
;     mov rsi, qword cLoop
;     mov rax, rsi
;     shl rax, 3
;     mov rdx, qword M
;     add rdx, rax
;     mov rdx, [rdx]
;     xor rax, rax
;     call printf
;     add qword cLoop, 1
;     mov rax, qword cLoop
;     cmp rax, qword n
;     jne .readcheck

    mov rax, qword M ; rax is the address of M
    mov qword i, 0 ; i - "instuction pointer"
    mov rcx, 0 
    mov r8, qword [rax + rcx] ; M[0] = A

    ; mov rdi, fs_print
    ; mov rsi, qword M
    ; shl r8, 3
    ; add rsi, r8
    ; mov rsi, [rsi]
    ; xor rax, rax
    ; call printf
    
    mov rcx, 1
    shl rcx, 3
    mov r9, qword [rax + rcx] ;M[1] = B
    
    mov rcx, 2
    shl rcx, 3
    mov r10, qword [rax + rcx] ;M[2] = C

    jmp .check_SIC

.SIC_LOOP:
    mov rcx, qword i ;set rcx to i
    shl rcx, 3
    mov r8, qword [rax + rcx] ; M[i]
    
    mov rcx, qword i ;set rcx to i+1
    add rcx, 1
    shl rcx, 3
    mov r9, qword [rax + rcx] ;M[i+1]
    
    mov rcx, qword i ;set rcx to i+2
    add rcx, 2
    shl rcx, 3
    mov r10, qword [rax + rcx] ;M[i+2]
    
    mov rbx, qword M
    shl r8, 3
    add rbx, r8
    mov rbx, qword [rbx] ; M[M[i]]
    
    mov rcx, qword M
    shl r9, 3
    add rcx, r9
    sub rbx, qword [rcx] ; M[M[i] -= M[M[i+1]]
    cmp rbx, 0x0 ; if ( M[M[i]] -= M[M[i+1]] ) < 0 
    ;jmp .done
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