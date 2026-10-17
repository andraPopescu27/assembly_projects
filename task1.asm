section .note.GNU-stack

section .data 
	format db "%d ", 0 ;pentru primul argument din print_vector 
	;pentru mesajul de la printf 
	format_inceput db "v -> {(", 0
	;pentru mesajul de la printf 
	format_numar db "[%d]", 0
	;pentru mesajul de la printf 
	format_gol db "[]", 0
	;pentru mesajul de la printf 
	format_sfarsit db "), %d, %d}", 10, 0
	;pentru mesajul de eroare 
	format_eroare_pop db "The vector is empty", 10, 0
	format_eroare_get db "Error: len <= %d", 10, 0 ;la fel si la set_element 

section .text

extern malloc
extern realloc
extern printf 
extern free

global new_vector
global set_element
global get_element
global push_element
global pop_element
global print_vector
global free_vector

;	struct vector {
;		int *arr;
;		int len;
;		int cap;
;	}

new_vector:
	push rbp
	mov rbp, rsp
	xor rax, rax
	; TODO - write the new_vector function
	push r12 ;punem rezultatul de la alocarea structurii 'vector'
	push r13 ;punem capacitatea, ca sa nu o pierdem 
	push r14 ; ca sa fac r13*4, fara sa l modific pe r13
	mov r13, rdi  ; => r13 = rdi = inc
	;struct vector = 8 + 4 + 4 = 16 octeti 
	push r15 ;pt aliniere 

	;aloc memorie pt 16 octeti 
	mov rdi, 16
	call malloc

	;in rax avem rezultatul de la malloc
	mov r12, rax
	imul r14, r13, 4 ; r14 = cap(adica r13) * 4 ca avem vector de int-uri
	;aloc memorie pentru vector 

	mov rdi, r14
	call malloc

	;punem la adresa campului de vector (r12+0), adresa vectorului (rax) 
	;pt ca primul camp contine adresa unui vector, deci este **int 

	mov qword[r12], rax ; qword pentru int 

	;setam si celelalte campuri 
	mov dword[r12+8], 0 ;pentru len
	mov dword[r12+12], r13d ; pentru inc 

	mov rax, r12 ;punem rezultatul de return in rax

	pop r15
	pop r12
	pop r13
	pop r14 

	leave
	ret

set_element:
	push rbp
	mov rbp, rsp
	xor rax, rax
	; TODO - write the set_element function
	mov r8, rdi ;pointer la structura, adresa structurii 'vector' 
	mov r9d, esi ; int elem 
	mov r10, rdx ; int pos 
	;lungimea vectorului - len se afla la [r12+8]
	mov r11d, [r8+8] ; int len 

	cmp r10, r11
	jl seteaza_element
	;altfel returnam -1
	;afisam mesajul de eroare 
	mov rdi, format_eroare_get
	mov rsi, r10 ;int pos
	xor rax, rax
	call printf 
	;return -1
	mov rax, 1
	neg rax 

	jmp end_set

seteaza_element:
	;la adresa [[r8 + 0] + pos] punem elementul 
	push r12 
	push r13
	mov r12, [r8] ; adresa vectorului 
	mov dword [r12+r10*4], r9d; punem elem la adresa continuta de r12+rdx = vector + pos 
	mov rax, r10

	pop r12
	pop r13

end_set:
	leave 
	ret

get_element:
	push rbp
	mov rbp, rsp
	xor rax, rax
	; TODO - write the get_element function
	push r12
	push r13
	push r14

	mov r12, rdi ;pointer la structura, adresa structurii 'vector' 
	mov r13d, esi ; int pos
	mov r14d, dword [r12+8]; int len 

	cmp r13, r14
	jl return_element

	;altfel returnam -1
	;daca nu are elemente, afisam pt len=1

	;afisam mesajul de eroare 
	mov rdi, format_eroare_get
	mov rsi, r13 ;int len 
	xor rax, rax
	call printf 

	;return -1
	mov rax, 1
	neg rax

	jmp end_get

return_element:
	mov r11, [r12]
	mov eax, dword[r11+r13*4] ;punem in rax ce se afla in vector la pozitia pos

end_get:
	pop r14
	pop r13
	pop r12
	leave
	ret

push_element:
	push rbp
	mov rbp, rsp
	xor rax, rax
	; TODO - write the push_element function
	;ca sa persiste intre apeluri 
	push r12
	push r13
	push r14 
	push r15
	mov r12, rdi ; pointer la structura, adresa structurii 'vector' 
	mov r13d, esi ; int elem 
	mov r15, [r12] ;adresa vectorului
	mov r14d, [r12+8] ;int len 
	mov edx,[r12+12] ;int cap 
	;pe pozitia len punem elem -> arr[len]=elem
	; c = 2 * c
	; rax = len
	; len ++
	;len < cap atunci putem introduce element 
	cmp r14d, edx
	jl introduce_element
	;altfel, realocam memoria & dublam capacitatea
	shl dword [r12+12], 1 
	;actualizam noua capacitate
	mov edx, dword [r12+12]
	;primul argument pt realloc - adresa vectorului 
	mov rdi, r15
	;al doilea argument pt realloc - dimensiunea = cap*4
	imul rax, rdx, 4 ; rax = cap(adica edx) * 4 ca avem vector de int-uri
	mov rsi, rax
	call realloc
	;rezultatul e in rax, actualizam noua adresa a vectorului
	;atat in structura, cat si campul in sine 
	mov [r12], rax
	mov r15, rax

introduce_element:
	;introducem elementul 
	mov dword [r15+r14*4], r13d 
	;creste len cu 1 
	inc dword[r12+8]

gata_push:
	mov rax, r14 ;pozitia elementului introdus
	pop r15
	pop r14
	pop r13
	pop r12
	leave
	ret

pop_element:
	push rbp
	mov rbp, rsp
	xor rax, rax
	; TODO - write the pop_element function
	push r12
	push r13
	mov r8, rdi ; adresa structurii vector 

	;daca len=0, nu am ce sa scot 
	cmp dword [r8+8], 0
	je done_fara_elemente

	;ultimul element se afla pe poz len-1
	dec dword [r8+8]; len --
	mov r11d, [r8+8] ; int len 

	mov r9, [r8]  ;adresa vectorului arr 
	mov r10d, [r9+r11*4] ; arr[len]
	mov rax, r10

	imul r11d, dword [r8+8], 2 ; r11 = len * 2
	cmp dword [r8+12], r11d ;cap > 2*lengh 
	jge reduc_capacitatea 
	;altfel, sarim peste 
	jmp done_pop

reduc_capacitatea:
	;impart la 2
	shr dword [r8+12], 1
	;verificam daca a scazut capacitatea la 0 
	cmp dword [r8+12], 0
	je seteaza_capacitatea 
	jmp done_pop ;ca sa returnam numarul scos

seteaza_capacitatea:
	;pt cazul cand capacitatea devine 0
	mov dword [r8+12], 1
	jmp done_pop

done_fara_elemente:
	;printam mesaj de eroare 
	mov rdi, format_eroare_pop
	xor rax, rax
	call printf
	;return -1
	mov rax, -1

done_pop:
	pop r13
	pop r12
	leave
	ret

print_vector:
	push rbp
	mov rbp, rsp
	xor rax, rax
	; TODO - write the print_vector function
	;registre non-volatile ca sa reziste dupa apelurile loop ului 
	push r12
	push r13 
	push r14
	push r15
	mov r12, rdi ; adresa structurii vector 
	mov r15, [r12]; adresa vectorului 
	mov r13d, [r12+8]; int len 
	;afisam inceputul de la printf
	mov rdi, format_inceput
	xor rax, rax 
	call printf 
	;verificare caz nul 
	cmp r13, 0
	je printez_caz_nul
	dec r13 ; len -- 
	;initializare contor 
	mov qword r14, 0 

print_loop:
	cmp r14, r13 ;contor vs len 
	jg printez_paranteze 
	mov rdi, format_numar ;primul argument
	mov esi, [r15+r14*4] ;al doilea argument, valoarea porpriu-zisa 
	xor rax, rax ;al 3-lea argument, nr de valori floating point 
	call printf 

	inc r14
	jmp print_loop

printez_paranteze:
	inc r13 ; len++ inapoi, ca vectorul e indexat de la 0 
	cmp r13d, [r12+12] ; len versus capacitate 
	jge gata 
	;altfel, printam paranteze goale 
	mov r14, r13 ;contor, initial egal cu len (len de dinainte de dec)
	jmp loop_paranteze

printez_caz_nul:
	cmp r13d, [r12+12] ; len versus capacitate 
	jge gata 
	;altfel, printam paranteze goale 
	mov r14, r13 ;contor, initial egal cu len (len de dinainte de dec)

loop_paranteze:
	cmp r14d, [r12+12] ; len versus capacitate 
	je gata 
	mov rdi, format_gol
	xor rax, rax
	call printf 

	inc r14
	jmp loop_paranteze

gata: 
	mov rdi, format_sfarsit
	mov esi, [r12+8] ; int len 
	mov edx, [r12+12] ; int cap 
	xor rax, rax
	call printf 

	pop r15
	pop r14
	pop r13
	pop r12
	leave
	ret

free_vector:
	push rbp
	mov rbp, rsp
	xor rax, rax
	; TODO - write the free_vector function
	push r12
	push r13 

	;salvam adresa adresei structurii, ca sa nu avem dangling pointer la final
	mov r13, rdi

	;eliberam memoria alocata campului vector 
	mov r12, [rdi] ;adresa structurii  
	test r12, r12 ;verificam daca e alocata memorie pt structura
	je end_free

	mov rdi, [r12] ;acum am ajuns la vector (v->arr)
	;verificam daca e alocata memorie pt vector 
	test rdi, rdi
	je free_structura
	call free ;pentru vector 

free_structura:
	mov rdi, r12
	call free 
	;stergem adresa structurii 
	mov qword [r13], 0

end_free:
	pop r13
	pop r12
	leave
	ret
