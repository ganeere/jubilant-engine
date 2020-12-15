
; Parameters are pushed before the CALL instruction
; This is why parameters are references as [ebp+value]
; Local variables are referenced as [ebp-value]



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SUBPROGRAM n_gram
; Return address  is at [ebp+4]
;
; DEFINE PARAMETERS OF THE SUBROUTINE
%define str1           ebp+8            ;input string str_1
%define size1          ebp+12           ;size of str_1
%define str2           ebp+16           ;input string str_2
%define size2          ebp+20           ;size of str_2
%define nvalue         ebp+24           ;integer value of n
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; DEFINE LOCAL VARIABLES OF THE SUBROUTINE
; NOTE THAT ADDRESSES OF THE VARIABLES ARE CALCULATED AS
;       SUBSTRACTING THE SIZE VALUE FROM BASE POINTER(FRAME POINTER)
%define index_i ebp-4                   ;index used in for loop
%define index_j ebp-8                   ;index used in for loop
%define index_k ebp-12                  ;index used in for loop

%define ngram_size_1 ebp-24
%define ngram_size_2 ebp-28

%define counter ebp-16                  ;counter for ngram comparison
%define counter_global ebp-20           ;counter for total ngram match

%define total    ebp-32          ; total n-gram subtrings including intersections
%define result   ebp-36          ; similarity value calculated as result (this is also the return value)



%define temp    ebp-37          ;1 byte value   (temporary char which holds a character value of a substring)
%define temp2   ebp-38          ;1 byte value






segment .text
        global n_gram

;Define subroutine code: n_gram
n_gram:
        ; Prologue 
        push    ebp
        mov     ebp, esp
        sub     esp, 48                         ;allocate total area for local variables needed  whichis 48 bytes in the stack
        ;enter   48, 0

        mov     dword  [index_i], 0               ;initialize index value as 0
        mov     dword  [index_j], 0               ;initialize index value as 0
        mov     dword  [index_k], 0              ;initialize index value as 0


        mov     eax, dword  [size1]            ;ngram_size_1 = size_1-n+1;
        sub     eax, dword  [nvalue]            ;
        add     eax, 1                          ;
        mov     dword  [ngram_size_1], eax            ;

        mov     eax, dword  [size2]            ;int ngram_size_2 = size_2-n+1;
        sub     eax, dword  [nvalue]            ;
        add     eax, 1                          ;
        mov     dword  [ngram_size_2], eax            ;

        mov     dword  [counter], 0                      ;initialize counter value used for char comparison as 0
        mov     dword  [counter_global], 0                      ;initialize global counter value used for total match  as 0

        mov     dword  [index_i], 0               ;initialize loop_1(outer loop of 3 loops) for the first time(it will be initialized for 1 time)
        jmp     .check_loop_1_condition

.loop_2_initialize:
        mov     dword  [index_j], 0
        jmp     .check_loop_2_condition

.loop_3_initialize:
        mov     dword  [index_k], 0
        jmp     .check_loop_3_condition

.inside_loop_3:
        mov     edx, dword  [index_i]
        mov     eax, dword  [index_k]
        add     eax, edx
        mov     edx, eax
        mov     eax, dword  [str1]
        add     eax, edx
        movzx   eax, byte  [eax]
        mov     byte  [temp], al

        mov     edx, dword  [index_j]
        mov     eax, dword  [index_k]
        add     eax, edx
        mov     edx, eax
        mov     eax, dword  [str2]
        add     eax, edx
        movzx   eax, byte  [eax]
        mov     byte  [temp2], al

        movzx   eax, byte  [temp]
        cmp     al, byte  [temp2]
        jne     .chars_dont_match
        add     dword  [counter], 1              ; chars matched, increase counter by 1 (chars of substrings matched)


.chars_dont_match:
        mov     eax, dword  [counter]
        cmp     eax, dword  [nvalue]
        jne     .not_enough_char_match
        add     dword  [counter_global], 1              ;n chars matched, increase global_counter by 1 (substring match)


.not_enough_char_match:
        add     dword  [index_k], 1


.check_loop_3_condition:
        mov     eax, dword  [index_k]
        cmp     eax, dword  [nvalue]
        jl      .inside_loop_3

        mov     dword  [counter], 0                      ;reset local counter to 0
        
        add     dword  [index_j], 1                       ;go back to loop 2 and reiterate


.check_loop_2_condition:
        mov     eax, dword  [index_j]
        cmp     eax, dword  [ngram_size_2]
        jl      .loop_3_initialize
        add     dword  [index_i], 1                       ;does not satisfy condition, so increase outer loop index and reiterate


.check_loop_1_condition:
        mov     eax, dword  [index_i]
        cmp     eax, dword  [ngram_size_1]
        jl      .loop_2_initialize

        ;if loop ends, calculate the similarity value
        mov     edx, dword  [ngram_size_1]                    ; calculate total number of set including intersection ; total = ngram_size_1 + ngram_size_2
        mov     eax, dword  [ngram_size_2]                    ;
        add     eax, edx                                ;
        mov     dword  [total], eax                    ;

        mov     eax, dword  [counter_global]                    ; calculate the result(similarity value as percentage) as follows:    
        imul    eax, eax, 100                           ;       result = ( 100 * global_counter/(total - global_counter) )
        mov     edx, dword  [total]                    ;    
        mov     ecx, edx                                ;
        sub     ecx, dword  [counter_global]                    ;


        ; Unsigned division version
        ;xor edx, edx
        ;div ecx        
        ;; Signed division version
        cdq                                             ; edx = signbit of eax             
        idiv    ecx                                     ; eax = eax/ecx and edx = eax%ecx

        mov     dword  [result], eax
        mov     eax, dword  [counter_global]
        cmp     eax, dword  [result]
        jle     .if_similarity_so_high
        mov     dword  [result], 100

.if_similarity_so_high:
        mov     eax, dword  [result]
        leave
        ret


        ; ; This part is just for readability purpose
        ; mov     dword  [result], eax
        ; mov     eax, dword  [result]

        ; leave                                           ; Dealocate local variables
        ; ret                                             ; Return back to the previous eip before call