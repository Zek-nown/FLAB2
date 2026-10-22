; ======================================================================
; Machine Problem 1 - Zodiac Horoscope and Fortune Teller
; NASM x86 32-bit, Linux, int 0x80
;
; Build:  nasm -f elf32 zodiac_oracle.asm -o zodiac_oracle.o
;         ld -m elf_i386 zodiac_oracle.o -o zodiac_oracle
; Run:    ./zodiac_oracle
;
; Sign index order used by every table below:
;   0 Aries   1 Taurus  2 Gemini   3 Cancer    4 Leo      5 Virgo
;   6 Libra   7 Scorpio 8 Sagittarius 9 Capricorn 10 Aquarius 11 Pisces
; Element = sign AND 3  ->  0 Fire, 1 Earth, 2 Air, 3 Water
; ======================================================================

section .data

; ---------------------------- screens ---------------------------------
welcome_art:
    db "=======================================", 10
    db "       THE MYSTIC ZODIAC ORACLE", 10
    db "=======================================", 10
    db "             *       *", 10
    db "          *     /\      *", 10
    db "               /  \", 10
    db "         *    /____\    *", 10
    db "               |  |", 10
    db "           *   |__|   *", 10
    db "       DISCOVER YOUR DESTINY!", 10
    db "=======================================", 10, 10, 0

hdr_sign:
    db 10, "=======================================", 10
    db "         YOUR ZODIAC SIGN", 10
    db "=======================================", 10, 0

menu_text:
    db 10, "[1] Love and Relationships", 10
    db "[2] Career and Studies", 10
    db "[3] Health and Wellness", 10
    db "[4] Lucky Number and Color", 10
    db "[5] View Zodiac Information", 10
    db "[6] Exit", 10, 0

bye_art:
    db 10, "=======================================", 10
    db "              .-''''-.", 10
    db "             /  .--.  \", 10
    db "            |  ( () )  |", 10
    db "             \  '--'  /", 10
    db "            __'-.__.-'__", 10
    db "           (____________)", 10
    db "   MAY THE STARS GUIDE YOUR WAY!", 10
    db "=======================================", 10, 0

; ---------------------------- prompts ---------------------------------
prompt_name:   db "Enter your name: ", 0
prompt_month:  db "Enter birth month (1-12): ", 0
prompt_day:    db "Enter birth day (1-31): ", 0
prompt_choice: db "Enter your choice: ", 0
prompt_return: db "Return to menu? (Y/N): ", 0

msg_welcome1:  db 10, "Welcome, ", 0
msg_welcome2:  db "!", 10, 0

err_name:      db "Error: name cannot be empty.", 10, 0
err_month:     db "Invalid month! Enter a number from 1 to 12.", 10, 0
err_day:       db "Invalid date! That day does not exist in that month.", 10, 0
err_choice:    db "Invalid selection! Please choose 1-6.", 10, 0
err_yn:        db "Please answer Y or N.", 10, 0

lbl_sign:      db "Zodiac Sign: ", 0
lbl_elem:      db "Element: ", 0
lbl_symbol:    db "Symbol: ", 0
lbl_pers:      db "Personality: ", 0
lbl_lucknum:   db "Lucky Number: ", 0
lbl_luckcol:   db "Lucky Color: ", 0
comma_sp:      db ", ", 0
nl:            db 10, 0

hdr_love:
    db 10, "=======================================", 10
    db "         LOVE HOROSCOPE", 10
    db "=======================================", 10, 0
hdr_career:
    db 10, "=======================================", 10
    db "         CAREER HOROSCOPE", 10
    db "=======================================", 10, 0
hdr_health:
    db 10, "=======================================", 10
    db "         HEALTH HOROSCOPE", 10
    db "=======================================", 10, 0
hdr_lucky:
    db 10, "=======================================", 10
    db "       LUCKY NUMBER AND COLOR", 10
    db "=======================================", 10, 0

; ------------------------ calendar lookup tables ----------------------
; index = month - 1
days_tbl:   db 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31   ; Feb 29 rejected
cutoff_tbl: db 19, 18, 20, 19, 20, 20, 22, 22, 22, 22, 21, 21   ; last day of earlier sign
before_tbl: db  9, 10, 11,  0,  1,  2,  3,  4,  5,  6,  7,  8   ; sign on/before cutoff
after_tbl:  db 10, 11,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9   ; sign after cutoff

; ---------------------------- sign data -------------------------------
n0:  db "Aries", 0
n1:  db "Taurus", 0
n2:  db "Gemini", 0
n3:  db "Cancer", 0
n4:  db "Leo", 0
n5:  db "Virgo", 0
n6:  db "Libra", 0
n7:  db "Scorpio", 0
n8:  db "Sagittarius", 0
n9:  db "Capricorn", 0
n10: db "Aquarius", 0
n11: db "Pisces", 0

u0:  db "ARIES", 0
u1:  db "TAURUS", 0
u2:  db "GEMINI", 0
u3:  db "CANCER", 0
u4:  db "LEO", 0
u5:  db "VIRGO", 0
u6:  db "LIBRA", 0
u7:  db "SCORPIO", 0
u8:  db "SAGITTARIUS", 0
u9:  db "CAPRICORN", 0
u10: db "AQUARIUS", 0
u11: db "PISCES", 0

e0:  db "Fire", 0
e1:  db "Earth", 0
e2:  db "Air", 0
e3:  db "Water", 0

s0:  db "Ram", 0
s1:  db "Bull", 0
s2:  db "Twins", 0
s3:  db "Crab", 0
s4:  db "Lion", 0
s5:  db "Maiden", 0
s6:  db "Scales", 0
s7:  db "Scorpion", 0
s8:  db "Archer", 0
s9:  db "Sea-Goat", 0
s10: db "Water Bearer", 0
s11: db "Fish", 0

p0:  db "Bold, energetic, determined.", 10, 0
p1:  db "Patient, reliable, devoted.", 10, 0
p2:  db "Curious, witty, adaptable.", 10, 0
p3:  db "Caring, intuitive, protective.", 10, 0
p4:  db "Confident, creative, courageous.", 10, 0
p5:  db "Analytical, modest, hardworking.", 10, 0
p6:  db "Charming, fair-minded, social.", 10, 0
p7:  db "Passionate, resourceful, loyal.", 10, 0
p8:  db "Adventurous, optimistic, honest.", 10, 0
p9:  db "Disciplined, ambitious, practical.", 10, 0
p10: db "Inventive, independent, friendly.", 10, 0
p11: db "Gentle, artistic, compassionate.", 10, 0

ln0:  db "9", 10, 0
ln1:  db "6", 10, 0
ln2:  db "5", 10, 0
ln3:  db "2", 10, 0
ln4:  db "1", 10, 0
ln5:  db "7", 10, 0
ln6:  db "8", 10, 0
ln7:  db "3", 10, 0
ln8:  db "4", 10, 0
ln9:  db "10", 10, 0
ln10: db "11", 10, 0
ln11: db "12", 10, 0

lc0:  db "Red", 10, 0
lc1:  db "Green", 10, 0
lc2:  db "Yellow", 10, 0
lc3:  db "Silver", 10, 0
lc4:  db "Gold", 10, 0
lc5:  db "Brown", 10, 0
lc6:  db "Pink", 10, 0
lc7:  db "Maroon", 10, 0
lc8:  db "Purple", 10, 0
lc9:  db "Black", 10, 0
lc10: db "Blue", 10, 0
lc11: db "Sea Green", 10, 0

; ------------------------- ASCII art per sign -------------------------
a0:  db "        \  /\  /", 10
     db "         \/  \/", 10
     db "         (o  o)", 10
     db "          \__/", 10, 0
a1:  db "       \_      _/", 10
     db "        (o____o)", 10
     db "        (      )", 10
     db "         ^^^^^^", 10, 0
a2:  db "         ___ ___", 10
     db "          | | |", 10
     db "          | | |", 10
     db "         _|_|_|_", 10, 0
a3:  db "         _     _", 10
     db "        (_)---(_)", 10
     db "        ,-'-'-'-.", 10
     db "         \_____/", 10, 0
a4:  db "              /\_/\", 10
     db "             ( o.o )", 10
     db "              > ^ <", 10, 0
a5:  db "              .-.", 10
     db "             (o o)", 10
     db "             | V |", 10
     db "            /|___|\", 10, 0
a6:  db "           ___|___", 10
     db "          /   |   \", 10
     db "         /_\  |  /_\", 10
     db "              |", 10, 0
a7:  db "        ~~~~~~~>", 10
     db "       /        \", 10
     db "      (  o  o  )~~/", 10
     db "       \______/", 10, 0
a8:  db "              /|", 10
     db "       ------/-|------>", 10
     db "              \|", 10, 0
a9:  db "           /\/\", 10
     db "          ( ..)_", 10
     db "           \  _/", 10
     db "            \/\/", 10, 0
a10: db "        .-~-.-~-.-~-.", 10
     db "       ~   ~   ~   ~", 10
     db "        '-~-'-~-'-~-'", 10, 0
a11: db "          ><(((('>", 10
     db "             <')))><", 10, 0

; --------------------- horoscope text (by element) --------------------
love0:   db "your passion draws someone special", 10
         db "closer. Speak from the heart today!", 10, 0
love1:   db "steady and loyal, you will find comfort", 10
         db "in a quiet moment with someone dear.", 10, 0
love2:   db "a lively conversation sparks a new", 10
         db "connection. Keep your words kind!", 10, 0
love3:   db "your intuition guides you to an", 10
         db "honest, tender talk with a loved one.", 10, 0

career0: db "your creativity will help you", 10
         db "solve a difficult problem today.", 10
         db "Stay focused and confident!", 10, 0
career1: db "patient effort pays off. Finish the", 10
         db "task you have been postponing.", 10, 0
career2: db "share your ideas with your group;", 10
         db "teamwork opens a new opportunity.", 10, 0
career3: db "trust your instincts on a tough choice.", 10
         db "A mentor offers helpful advice.", 10, 0

health0: db "channel your energy into exercise,", 10
         db "but remember to rest and drink water.", 10, 0
health1: db "keep a steady routine. A walk outdoors", 10
         db "and regular meals will lift your mood.", 10, 0
health2: db "clear your mind with deep breaths and", 10
         db "less screen time before bed.", 10, 0
health3: db "stay hydrated and give yourself time", 10
         db "to relax. A calm evening restores you.", 10, 0

; ----------------------- pointer tables (dwords) ----------------------
names_tbl: dd n0, n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11
upper_tbl: dd u0, u1, u2, u3, u4, u5, u6, u7, u8, u9, u10, u11
elem_tbl:  dd e0, e1, e2, e3
symb_tbl:  dd s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11
pers_tbl:  dd p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11
lnum_tbl:  dd ln0, ln1, ln2, ln3, ln4, ln5, ln6, ln7, ln8, ln9, ln10, ln11
lcol_tbl:  dd lc0, lc1, lc2, lc3, lc4, lc5, lc6, lc7, lc8, lc9, lc10, lc11
art_tbl:   dd a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11
love_tbl:   dd love0, love1, love2, love3
career_tbl: dd career0, career1, career2, career3
health_tbl: dd health0, health1, health2, health3

section .bss
name:    resb 32        ; user name (NUL-terminated)
inbuf:   resb 16        ; numeric / Y-N input line
charbuf: resb 1         ; single-byte read buffer
month:   resd 1
day:     resd 1
sign:    resd 1         ; 0..11

section .text
global _start

; ======================================================================
; MAIN PROGRAM
; ======================================================================
_start:
    call display_welcome
    call get_user_info          ; name + validated birth date
    call determine_zodiac       ; fills [sign]
    call display_zodiac_info    ; sign, element, symbol, personality, art

menu_loop:
    call display_menu
    mov  esi, prompt_choice
    call print_z
    call read_int               ; eax = choice or -1

    cmp  eax, 6
    je   do_exit
    cmp  eax, 5
    je   do_info
    cmp  eax, 4
    je   do_lucky
    cmp  eax, 1
    jl   bad_choice
    cmp  eax, 3
    jg   bad_choice

    call show_horoscope         ; eax = 1, 2 or 3
    jmp  after_item

do_info:
    call display_zodiac_info
    jmp  after_item

do_lucky:
    call show_lucky
    jmp  after_item

bad_choice:
    mov  esi, err_choice
    call print_z
    jmp  menu_loop

after_item:
    call ask_return             ; eax = 1 (yes) / 0 (no)
    cmp  eax, 1
    je   menu_loop

do_exit:
    call exit_program

; ======================================================================
; PROCEDURES
; ======================================================================

; ---- display_welcome : welcome ASCII art -----------------------------
display_welcome:
    push esi
    mov  esi, welcome_art
    call print_z
    pop  esi
    ret

; ---- get_user_info : read name, month, day (re-prompts until valid) --
get_user_info:
    push esi
    push edi
    push ecx
.name_loop:
    mov  esi, prompt_name
    call print_z
    mov  edi, name
    mov  ecx, 32
    call read_line
    cmp  eax, 0
    jne  .date_loop
    mov  esi, err_name
    call print_z
    jmp  .name_loop

.date_loop:
    mov  esi, prompt_month
    call print_z
    call read_int
    mov  [month], eax
    mov  esi, prompt_day
    call print_z
    call read_int
    mov  [day], eax

    call validate_birthdate     ; eax: 0 ok, 1 bad month, 2 bad day
    cmp  eax, 0
    je   .ok
    cmp  eax, 1
    je   .bad_month
    mov  esi, err_day
    call print_z
    jmp  .date_loop
.bad_month:
    mov  esi, err_month
    call print_z
    jmp  .date_loop

.ok:
    mov  esi, msg_welcome1
    call print_z
    mov  esi, name
    call print_z
    mov  esi, msg_welcome2
    call print_z
    pop  ecx
    pop  edi
    pop  esi
    ret

; ---- validate_birthdate : checks [month],[day] -----------------------
; returns eax = 0 valid, 1 invalid month, 2 invalid day
validate_birthdate:
    push ebx
    push edx
    mov  ebx, [month]
    mov  edx, [day]
    cmp  ebx, 1
    jl   .bad_month
    cmp  ebx, 12
    jg   .bad_month
    movzx eax, byte [days_tbl + ebx - 1]   ; max day for this month
    cmp  edx, 1
    jl   .bad_day
    cmp  edx, eax
    jg   .bad_day
    xor  eax, eax
    jmp  .done
.bad_month:
    mov  eax, 1
    jmp  .done
.bad_day:
    mov  eax, 2
.done:
    pop  edx
    pop  ebx
    ret

; ---- determine_zodiac : month/day -> [sign] --------------------------
; cutoff_tbl holds the last day of the earlier sign in each month.
determine_zodiac:
    push ebx
    push edx
    mov  ebx, [month]
    mov  edx, [day]
    movzx eax, byte [cutoff_tbl + ebx - 1]
    cmp  edx, eax
    jle  .before_cutoff
    movzx eax, byte [after_tbl + ebx - 1]   ; day > cutoff -> later sign
    jmp  .store
.before_cutoff:
    movzx eax, byte [before_tbl + ebx - 1]  ; day <= cutoff -> earlier sign
.store:
    mov  [sign], eax
    pop  edx
    pop  ebx
    ret

; ---- display_zodiac_art : art for the current sign -------------------
display_zodiac_art:
    push esi
    push ebx
    mov  ebx, [sign]
    mov  esi, [art_tbl + ebx*4]
    call print_z
    pop  ebx
    pop  esi
    ret

; ---- display_zodiac_info : full sign card ----------------------------
display_zodiac_info:
    push esi
    push ebx
    push eax
    mov  ebx, [sign]

    mov  esi, hdr_sign
    call print_z
    call display_zodiac_art

    mov  esi, lbl_sign
    call print_z
    mov  esi, [upper_tbl + ebx*4]
    call print_z
    mov  esi, nl
    call print_z

    mov  esi, lbl_elem
    call print_z
    mov  eax, ebx
    and  eax, 3                 ; element = sign mod 4
    mov  esi, [elem_tbl + eax*4]
    call print_z
    mov  esi, nl
    call print_z

    mov  esi, lbl_symbol
    call print_z
    mov  esi, [symb_tbl + ebx*4]
    call print_z
    mov  esi, nl
    call print_z

    mov  esi, lbl_pers
    call print_z
    mov  esi, [pers_tbl + ebx*4]
    call print_z
    pop  eax
    pop  ebx
    pop  esi
    ret

; ---- display_menu ----------------------------------------------------
display_menu:
    push esi
    mov  esi, menu_text
    call print_z
    pop  esi
    ret

; ---- show_horoscope : eax = 1 love, 2 career, 3 health ---------------
show_horoscope:
    push esi
    push ebx
    push ecx
    mov  ebx, [sign]
    mov  ecx, ebx
    and  ecx, 3                 ; ecx = element index

    cmp  eax, 1
    je   .love
    cmp  eax, 2
    je   .career

    mov  esi, hdr_health
    call print_z
    mov  esi, [health_tbl + ecx*4]
    jmp  .body
.love:
    mov  esi, hdr_love
    call print_z
    mov  esi, [love_tbl + ecx*4]
    jmp  .body
.career:
    mov  esi, hdr_career
    call print_z
    mov  esi, [career_tbl + ecx*4]

.body:
    push esi                    ; save prediction text
    mov  esi, [names_tbl + ebx*4]
    call print_z                ; "Leo"
    mov  esi, comma_sp
    call print_z                ; ", "
    pop  esi
    call print_z                ; prediction
    pop  ecx
    pop  ebx
    pop  esi
    ret

; ---- show_lucky : lucky number and color -----------------------------
show_lucky:
    push esi
    push ebx
    mov  ebx, [sign]
    mov  esi, hdr_lucky
    call print_z
    mov  esi, lbl_lucknum
    call print_z
    mov  esi, [lnum_tbl + ebx*4]
    call print_z
    mov  esi, lbl_luckcol
    call print_z
    mov  esi, [lcol_tbl + ebx*4]
    call print_z
    pop  ebx
    pop  esi
    ret

; ---- ask_return : "Return to menu? (Y/N)" ----------------------------
; returns eax = 1 for Y/y, 0 for N/n; re-asks on anything else
ask_return:
    push esi
    push edi
    push ecx
.ask:
    mov  esi, prompt_return
    call print_z
    mov  edi, inbuf
    mov  ecx, 16
    call read_line
    cmp  eax, 1                 ; must be exactly one character
    jne  .invalid
    mov  al, [inbuf]
    cmp  al, 'Y'
    je   .yes
    cmp  al, 'y'
    je   .yes
    cmp  al, 'N'
    je   .no
    cmp  al, 'n'
    je   .no
.invalid:
    mov  esi, err_yn
    call print_z
    jmp  .ask
.yes:
    mov  eax, 1
    jmp  .done
.no:
    xor  eax, eax
.done:
    pop  ecx
    pop  edi
    pop  esi
    ret

; ---- exit_program : goodbye art, then sys_exit(0) --------------------
exit_program:
    mov  esi, bye_art
    call print_z
    mov  eax, 1                 ; sys_exit
    xor  ebx, ebx
    int  0x80

; ======================================================================
; HELPER PROCEDURES
; ======================================================================

; ---- print_z : print NUL-terminated string at esi --------------------
print_z:
    push eax
    push ebx
    push ecx
    push edx
    xor  edx, edx
.len:
    cmp  byte [esi + edx], 0
    je   .write
    inc  edx
    jmp  .len
.write:
    mov  eax, 4                 ; sys_write
    mov  ebx, 1                 ; stdout
    mov  ecx, esi
    int  0x80
    pop  edx
    pop  ecx
    pop  ebx
    pop  eax
    ret

; ---- read_line : edi = buffer, ecx = buffer size -----------------------
; Reads one line, stores at most size-1 chars (extra chars are discarded
; so they cannot leak into the next prompt), NUL-terminates.
; returns eax = number of characters stored. Exits cleanly on EOF.
read_line:
    push ebx
    push esi
    push ebp
    xor  esi, esi               ; characters stored
    lea  ebp, [ecx - 1]         ; max characters
.next:
    mov  eax, 3                 ; sys_read
    xor  ebx, ebx               ; stdin
    mov  ecx, charbuf
    mov  edx, 1
    int  0x80
    cmp  eax, 1
    jl   .eof
    mov  al, [charbuf]
    cmp  al, 10
    je   .done
    cmp  esi, ebp
    jge  .next                  ; buffer full: discard
    mov  [edi + esi], al
    inc  esi
    jmp  .next
.eof:
    cmp  esi, 0
    jne  .done
    call exit_program           ; input closed: quit gracefully
.done:
    mov  byte [edi + esi], 0
    mov  eax, esi
    pop  ebp
    pop  esi
    pop  ebx
    ret

; ---- read_int : read a line, return decimal value in eax -------------
; returns -1 if empty, non-numeric, or too large.
read_int:
    push ebx
    push ecx
    push edx
    push edi
    mov  edi, inbuf
    mov  ecx, 16
    call read_line
    test eax, eax
    jz   .bad
    xor  eax, eax               ; accumulated value
    xor  ebx, ebx               ; index
.digit:
    movzx ecx, byte [inbuf + ebx]
    cmp  ecx, 0
    je   .done
    cmp  ecx, '0'
    jl   .bad
    cmp  ecx, '9'
    jg   .bad
    sub  ecx, '0'
    imul eax, eax, 10
    add  eax, ecx
    cmp  eax, 100000
    jg   .bad
    inc  ebx
    jmp  .digit
.bad:
    mov  eax, -1
.done:
    pop  edi
    pop  edx
    pop  ecx
    pop  ebx
    ret
