section .note.GNU-stack

section .text

extern putc 
extern stdout 
global my_printf

my_printf:
	push rbp
	mov rbp, rsp
	xor rax, rax
	; TODO - write the my_printf function
	;prima data se vor umple parametri:
	;rdi, rsi, rdx, rcx, r8, r9
	;si apoi se vor pune pe stiva ceilalti parametri
	;al 7-lea parametru fiind cap de stiva 

	;ca sa avem toti parametri pusi pe stiva, dam push celor 6 registre
	;in ordine inversa mentonarii lor 
	push r9
	push r8
	push rcx
	push rdx ;aici e arg 3 
	push rsi ;aici e arg 2 
	push rdi ;aici este formatul string-ului 

	push r12 
	push r13
	push r14
	push r15 

	;salvam in r12 capul stivei (reg non-volatil)
	mov r12, rsp ;capul stivei 
	add r12, 40 ;ca sa sarim de rdi - format + 4 push-uri, si sa avem chiar primul argument
	mov r13, rdi ;formatul 

alt_printf:
	;luam cate un caracter din format si verificam ce e acolo 
	mov al, byte[r13]
	inc r13 ;ca sa trec la urm caracter 

	;verificam ce este in al acum 
	;daca gasesc '%' caut si caracterul de dupa 
	cmp al, 0
	je gata

	cmp al, '%' 
	je verifica_urm_caracter 

	;altfel, printez, caci inseamna ca este textul propriu zis 
	xor rdi, rdi 
	mov dil, al ;primul argument pt putc 
	mov rsi, [stdout] ;al doilea argument pt putc 

	call putc 
	jmp alt_printf 

verifica_urm_caracter:
	mov bl, byte[r13]
	;verific ce tip de date trb sa am 
	cmp bl ,'s'
	je formateaza_string 

	cmp bl, 'l'
	je formateaza_numar 

	cmp bl, 'c'
	je afiseaza_caracter 

formateaza_string:
	;extrag  argument, adica parametru pt format 
	mov r15, [r12] ;adresa stringului 

afiseaza_string:
	mov cl, byte [r15] ;aici am textul ca atare pe care trb sa l afisez 
	;la r15 se afla adresa stringului 

	;verific terminator 
	cmp cl, 0
	je continua_dupa_string 

	;altfel, afisez 
	xor rdi, rdi 
	mov dil, cl
	mov rsi, [stdout]
	call putc 

	inc r15 ;modific adresa stringului, ca sa trec la urm caracter 
	jmp afiseaza_string

continua_dupa_string:
	;trec la urm caracter 
	add r13, 1 
	add r12, 8 ;trec la urm argument pt urmatoarea data cand am nevoie

	cmp r12, rbp
	jne ok1
	add r12, 16 ;sar peste rbp + adr de return 
ok1:
	jmp alt_printf

formateaza_numar:
	mov r15, [r12] ;extrag numarul de pe stiva 

	;fac rost de ultima cifra, impartind la 10 
	mov rax, r15 ;rax = numarul 
	xor r14, r14 ;cate cifre are nr 

	;sarim in textul format, peste r14 litere
	add r13, r14
	add r13, 2 ;si peste 'lu'

	;avansam in arg pe stiva
	add r12, 8 
	cmp r12, rbp
	jne ok2
	add r12, 16 ;sar peste rbp + adr de return 
ok2:

imparte:
	;verificam rax - catul diferit de 0 
	cmp rax, 0
	je afiseaza_numar 

	;a doua data deimpartitul va fi fostul cat, adica numarul/10 
	;si fac rost de ultima cifra iar, pana nu mai am cifre 
	xor rdx, rdx
	;impartim la 10 
	mov qword rbx, 10
	div rbx ; =>rax / rbx 

	;am rdx:rax, cu restul in rdx 
	;il pun pe stiva 
	push rdx 
	inc r14
	jmp imparte 

afiseaza_numar:
	;acum scoatem cifrele de pe stiva 
	cmp r14, 0
	je alt_printf

	;am scos o cifra
	pop r9 
	;o transform in litera 
	add r9, 48
	;scad r14
	dec r14
	;o afisez 
	xor rdi, rdi
	mov dil, r9b 
	mov rsi, [stdout]
	call putc 
	jmp afiseaza_numar

afiseaza_caracter:
	inc r13
	mov r15, [r12]

	add r12, 8 ;ca sa trec la urm argument 
	cmp r12, rbp
	jne ok3
	add r12, 16 ;sar peste rbp + adr de return 
ok3:
	xor rdi, rdi
	mov dil, r15b
	mov rsi, [stdout]
	call putc 
	jmp alt_printf

gata:
	pop r15
	pop r14
	pop r13
	pop r12
	pop rdi
	pop rsi
	pop rdx
	pop rcx
	pop r8
	pop r9
	leave
	ret
