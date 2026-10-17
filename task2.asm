section .note.GNU-stack

section .bss
	input resb 100 ;pt ca sunt neinitializate datele 

section .rodata
	;pentru citirea cu scanf 
	format_citire db "%s", 0
	;pentru afisare cu printf
	format_afisare db "%ld", 10, 0

section .text

extern printf 
extern scanf
extern atol 

global reverse_polish_notation

reverse_polish_notation:
	push rbp
	mov rbp, rsp
	xor rax, rax
	; TODO - write the reverse_polish_notation function

	push r12
	push r13

reverse:
	;ne asiguram ca stiva e aliniata 
	mov r13, rsp 
	;facem add cu -16, setam ultimii 4 biti pe 0 ->e multiplu de 16 
	and rsp, -16 

	;citim caractere din fisierul de input 
	;punem in rsi primul token citit (pana la terminator)

	mov rdi, format_citire
	mov rsi, input 
	xor eax, eax 
	call scanf

	;resetam rsp ul initial, dupa apelul lui printf 
	mov rsp, r13 

	;verificam ce am citit 
	;caz end of file, returneaza nr negativ 
	cmp eax, 0
	jle gata 

	;caz 1 - operator +, *, /
	cmp byte[input], '+'
	je adunare 

	cmp byte[input], '*'
	je inmultire 

	cmp byte[input], '/'
	je impartire 

	;caz 2 - operator -
	cmp byte[input], '-'
	je verificare_input 
	;caz 3 - altfel, inseamna ca avem nr pozitiv 
	;il transformam + il punem pe stiva 
	jmp pune_pe_stiva

adunare:
	;folosim registre volatile pt a scoate operanzii 
	pop r8
	pop r9
	add r9, r8
	;urcam suma in stiva 
	push r9 
	;ne ntoarcem in functie si citim mai departe 
	jmp reverse

inmultire:
	;folosim registre volatile pt a scoate operanzii 
	pop r8
	pop r9
	imul r9, r8 
	;urcam produsul in stiva 
	push r9 
	;ne ntoarcem in functie si citim mai departe 
	jmp reverse

impartire:
	pop r8 ;impartitor
	pop r9 ;deimpartit 

	;facem r9/r8
	;verificam semnul deimpartitului (r9)
	;pentru a face extinderea semnului (0 pt poz; 1 pt neg)
	cmp r9, 0
	jl negativ

	;altfel, este pozitiv 
	mov rdx, 0 
	jmp imparte

negativ:
	mov rdx, -1	;echivalentul lui 11111111

imparte:
	mov rax, r9
	idiv r8 
	push rax ;rezultatul impartirii 
	jmp reverse

scadere:
	;folosim registre volatile pt a scoate operanzii 
	pop r8
	pop r9
	sub r9, r8
	;urcam suma in stiva 
	push r9 
	;ne ntoarcem in functie si citim mai departe 
	jmp reverse

verificare_input:
	;verificam daca urm caracter este cifra sau terminator 
	;daca e terminator, inseamna ca avem operatorul minus 
	cmp byte [input+1], 0
	je scadere 

pune_pe_stiva:
	;altfel, inseamna ca e o cifra, deci avem un numar negativ 
	mov rdi, input 
	;aliniem iar stiva, pt ca nu stim cate elemente 
	;sunt pe stiva inainte de call 
	mov r13, rsp 
	;facem add cu -16, setam ultimii 4 biti pe 0 ->e multiplu de 16 
	add rsp, -16

	call atol 
	mov rsp, r13 
	;in rax avem numarul convertit pe 64 biti
	;punem nr pe stiva 
	push rax 
	jmp reverse

gata: 
	;printam rezultatul
	pop r12	
	pop r13

	mov rdi, format_afisare
	mov rsi, r12
	xor eax, eax 
	call printf 

	leave
	ret
