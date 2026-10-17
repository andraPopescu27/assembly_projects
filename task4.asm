section .note.GNU-stack

section .text

global check_langford
global generate_langford_sequences

check_langford:
	push rbp
	mov rbp, rsp
	xor rax, rax
	; TODO - write the check_langford function
	push r12
	push r13
	push r14
	push r15
	push rbx ;contor pt bucla mica 1<->1 etc 
	push r10

	mov r12, rdi ;adresa vectorului 
	mov r13, rsi ;lungimea vectorului 
	dec r13
	xor r14, r14 ; contor
	xor r10, r10 ;modificari pt stiva 

check:
	mov r15d, dword[r12+ 4*r14] ; iau nr din vector
	mov r9, r14 ;adaug indicele de pe care plec
	add r9, r15 ;adaug nr de la care plec
	;daca sunt pe poz 0 si am '1' trb sa ma opresc pe poz 2
	;deci incrementam r9 
	inc r9

	mov rbx, r14 ;indicele curent 

	;verific sa nu am nr de la care plec -1, adc un capat din dreapta 
	mov r8d, dword [r12+4*rbx]

	;am gasit ce am modificat eu 
	cmp r8, 0
	je sari_peste_capat_dreapta 

	inc rbx ;pozitia urmatoare 
	;facem o bucla si verificam ce se afla aici  

bulca_mica:
	mov r8d, dword [r12+4*rbx] ;iau nr de dupa 

	;verific daca ajung pe pozitia r9 
	cmp rbx, r9 
	je verificare_capat_dreapta
	;altfel, verific sa fie diferite de nr de la care plec 
	cmp r8, r15
	je nu_e_secventa_langford

	;altfel, trec la urm numar din secventa
	inc rbx 
	jmp bulca_mica 

verificare_capat_dreapta:
	cmp r8, r15
	jne nu_e_secventa_langford

	;altfel, punem capatul din dreapta pe 0, ca sa l ocolim 
	;pun mai intai valoarea initiala pe stiva 
	push r8 
	;pun si indicele 
	mov rsi, rbx 
	push rsi 
	;incrementez nr de astfel de modificari 
	inc r10 

	;abia apoi, fac modificarea in vector 
	mov dword [r12+4*rbx], 0
	inc r14 ;trec la urm nr din vectorul mare 
	jmp check 

sari_peste_capat_dreapta:
	cmp r14, r13
	je este_secventa
	inc r14
	jmp check

este_secventa:
	;return true 
	mov qword rax, 1
	jmp restituire_secventa

nu_e_secventa_langford:
	;return false 
	mov qword rax, 0
restituire_secventa:
	;nu mai am ce scoate de pe stiva 
	cmp r10, 0
	je gata
	pop rcx ;pozitia
	pop rdx ;valoare originala
	;pun valoarea de pe stiva inapoi in vector 
	mov dword[r12+4*rcx], edx
	dec r10
	jmp restituire_secventa 

gata:
	pop r10
	pop rbx 
	pop r15
	pop r14
	pop r13
	pop r12
	leave
	ret 

	pop rsi
	pop r8
	pop r10
	pop rbx 
	pop r15
	pop r14
	pop r13
	pop r12
	leave
	ret

generate_langford_sequences:
	push rbp
	mov rbp, rsp
	xor rax, rax
	; TODO - write the generate_langford_sequences function
	leave
	ret