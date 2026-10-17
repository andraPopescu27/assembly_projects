section .note.GNU-stack

section .rodata
	;caz nu e heavy 
	format_not_heavy db "The number is not heavy", 0
	;caz este heavy 
	format_heavy db "The number is heavy", 0
	;printare nr si dupa \n
	printare_numar db "%d", 10, 0

section .text

extern printf 
extern stdout 
extern puts 

global ave
global switch_cases
global heavy
global flat_matrix

ave:
	push rbp
	mov rbp, rsp
	xor rax, rax
	; TODO - write the ave function
	push r12
	push r13
	push r14
	push r15 

	mov r12, rdi ;sursa 
	mov r13, rsi ;dest 
	mov r14, rdx ;n 
	xor r8, r8
loop:
	xor r15, r15
	mov r15b, byte[r12+r8] ;luam un caracter din string ul sursa
	;verificam sa fie diferit de 0
	cmp r15b, 0
	je gata 

	sub r15, 'A'
	add r15, r14 

	xor rdx, rdx ;restul 
	mov rax, r15
	;impartim la 31, facem mod 31 
	mov qword rbx, 31
	;verificam semnul deimpartitului (rax=r15)
	;pentru a face extinderea semnului (0 pt poz; 1 pt neg)
	cmp rax, 0
	jl negativ

	;altfel, este pozitiv 
	mov rdx, 0 
	jmp continua

negativ:
	mov rdx, -1	;echivalentul lui 11111111

continua:
	idiv rbx
	;acum avem restul in rdx 
	add rdx, 'A'
	; in rdx avem tot calculul 

	mov byte[r13+r8], dl  
	inc r8

	jmp loop

gata:
	mov byte[r13+r8], 0 ;punem terminator 
	mov rax, r13 ;destinatia 

	pop r15
	pop r14
	pop r13
	pop r12
	leave
	ret

switch_cases:
	push rbp
	mov rbp, rsp
	xor rax, rax
	; TODO - write the switch_cases function
	push r12
	push r13
	push r14
	push r15

	mov r12, rdi ;sursa
	mov r13, rsi ;destinatia

	xor r8, r8 ;contor de string 
	xor r14, r14

loop2:
	mov r14b, byte [rdi+r8]
	;verificam terminator 
	cmp r14, 0
	je gata_switch 

	;verficam litera mare
	cmp r14, 65
	jl afiseaza

	;compar cu 'z' 
	cmp r14, 122
	jg afiseaza 

	;compar cu 'Z'
	cmp r14, 90 
	jg verificare_intre_cazuri 
	;ajunge aici, deci este lit mare
	;facem conversia cu +32
	add r14, 32
	mov byte [r13+r8], r14b

	inc r8
	jmp loop2

verificare_intre_cazuri:
	;90<r14<97
	cmp r14, 97
	jl afiseaza

nu_lit_mare:
	;alfel, avem litera mica 
	;facem conversia cu -32
	sub r14, 32
	mov byte [r13+r8], r14b
	inc r8
	jmp loop2

afiseaza:
	mov byte[r13+r8], r14b
	inc r8
	jmp loop2

gata_switch:
	mov byte[r13+r8], 0 ;punem terminator 
	mov rax, r13 ;destinatia 

	pop r15
	pop r14
	pop r13
	pop r12 
	leave
	ret

heavy:
	push rbp
	mov rbp, rsp
	xor rax, rax
	; TODO - write the heavy function

	push r12
	push r13

	mov r12, rdi ;int number 
	mov ebx, 0x80000000
	and edi, ebx ;masca are 1 doar pe MSB

	;verific daca are msb setat pe 0 
	cmp edi, 0
	je nu_e_heavy 

	;pastram doar octetii 3 si 4 
	mov rax, r12 ;rdi ul pt copie e stricat mai sus 
	mov r13, rax 
	; shiftam pt a obtine octetul 4
	shr r13, 24
	and r13, 0xFF 
	; shiftam pt a obtine octetul 3
	shr rax, 16 
	and rax, 0XFF ;octetul 3 
	;il mutam la stanga 
	shl rax, 8 

	or r13, rax ;ca sa inversam ordinea octetilor sa avem octet3+octet 4 

	;vedem cum este fata de 255
	cmp r13, 255
	jle nu_e_heavy

	jmp e_heavy

nu_e_heavy:
	mov rdi, format_not_heavy 
	call puts 
	;nu e heavy => 0 (fals)
	mov rax, 0
	jmp gata_heavy

e_heavy:
	mov rdi, format_heavy 
	call puts 
	;este heavy => 1(adevarat)
	mov rax, 1 

gata_heavy:
	pop r13
	pop r12
	leave
	ret

flat_matrix:
	push rbp
	mov rbp, rsp
	xor rax, rax
	; TODO - write the flat_matrix function

	push r12
	push r13
	push r14
	push r15

	mov r12, rdi ;adresa vectorului 
	mov r13, rsi ;n elemente 
	mov r15, r13 ;r15 = n 

	dec r15 ; r15 = n-1 

	;pentru a salva maximul per coloana 
	xor r10, r10 

	;contor mare de parcurs elementele de pe prima linie -i 
	xor r14, r14 

	;rbx - contor mic de parcurs elementele de pe fiecare coloana (*(n)) -j
	xor rbx, rbx 

bucla_mare:
	mov r9, r13 
	imul r9, r9 ; r9 = n^2 

	cmp r14, r13 ; i < n
	jge gata_matrix 

	;luam element din vector 
	mov r8d, dword[r12+r14*4]

	;primul element este maximul 
	mov r10, r8 

	mov rbx, r14 ; cu rbx plecam de la r14 

bucla_mica:
	;calculam produsul dintre indice mic si (n-1)
	;prin adunari succesive de (n-1)
	add rbx, r13 ; rbx = rbx + r13 = k*(n)
	cmp rbx, r9 ; (n^2) e aici 
	;inseamna ca am terminat coloana respectiva 
	jge continuare ; j > (n^2) 
	;intru n bucla mica de elemente 
	;ca sa ajungem pe urm element din aceeasi coloana 
	;sparg mov r11d, dword[r12+r14*4+r15*4]
	lea rcx, [rbx]
	;il comparam cu cel situat la (n) distanta de el
	mov r11d, dword[r12+rcx*4] 
	;verific care e mai mare si salvez maximul 
	cmp r10, r11 ;verific 2 elemente din aceeasi col 
	jl seteaza_maxim 
	;altfel, r10 contine deja maximul 
	jmp bucla_mica

seteaza_maxim: 
	mov r10, r11 
	;si caut alt maxim 
	jmp bucla_mica

continuare:
	;afisam maximul r10 
	mov rdi, printare_numar
	mov rsi, r10 
	xor eax, eax 
	call printf

	;maximul se initializeaza iar pt o noua coloana 
	;avansam pe urm element din vector 
	xor r10, r10 
	inc r14 
	jmp bucla_mare 

gata_matrix:
	pop r15
	pop r13
	pop r12
	pop r11 
	leave 
	ret
