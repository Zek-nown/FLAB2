; =============================================================================
; Module 5 - Machine Problem 2: Dungeon Adventure and Survival Game
; Architecture: x86 32-bit Linux (NASM) using int 0x80
; =============================================================================

section .data
    ; --- 1. Welcome Screen ASCII Art ---
    welcome_art db "=======================================", 10
                db "       DUNGEON OF THE LOST KING", 10
                db "=======================================", 10
                db "              |>>>>", 10
                db "              |", 10
                db "          _  _|_  _", 10
                db "         |;|_|;|_|;|", 10
                db "         \.    .  /", 10
                db "          \:  .  /", 10
                db "           ||:   |", 10
                db "           ||:.  |", 10
                db "           ||:  .|", 10
                db "       ENTER IF YOU DARE!", 10
                db "=======================================", 10, 0

    ; --- Registration Prompts ---
    prompt_hero     db 10, "Enter your hero name: ", 0
    prompt_class    db 10, "Choose your character:", 10
                    db "[1] Warrior (HP: 100, ATK: 20, Potions: 2)", 10
                    db "[2] Mage    (HP: 70,  ATK: 30, Potions: 3)", 10
                    db "[3] Archer  (HP: 85,  ATK: 25, Potions: 2)", 10
                    db "Enter choice: ", 0
    err_class       db "Error: Invalid class selection! Please choose 1, 2, or 3.", 10, 0

    msg_welcome_pre db 10, "Welcome, ", 0
    class_warrior   db "Warrior ", 0
    class_mage      db "Mage ", 0
    class_archer    db "Archer ", 0
    msg_excl        db "!", 10, 0

    class_names     dd 0, class_warrior, class_mage, class_archer

    ; --- Main Menu ---
    main_menu_str   db 10, "=======================================", 10
                    db "               MAIN MENU", 10
                    db "=======================================", 10
                    db "[1] Explore Dungeon", 10
                    db "[2] View Character Status", 10
                    db "[3] Use Health Potion", 10
                    db "[4] View Inventory", 10
                    db "[5] Exit Game", 10
                    db "Enter choice: ", 0
    err_menu        db "Error: Invalid menu option! Try again.", 10, 0

    ; --- Room 1: Goblin ASCII Art ---
    goblin_art      db 10, "=== ROOM 1: GOBLIN CHAMBER ===", 10
                    db "          ,      ,", 10
                    db "         /(.-", 34, "-.)\", 10
                    db "     |\  \/      \/  /|", 10
                    db "     | \ / =.  .= \ / |", 10
                    db "      \  \   ^    /  /", 10
                    db "       \  '-----'  /", 10
                    db "A GOBLIN APPEARS!", 10, 0

    ; --- Room 2: Treasure Chamber ASCII Art ---
    chest_art       db 10, "=== ROOM 2: TREASURE CHAMBER ===", 10
                    db "          __________", 10
                    db "         /_________/|", 10
                    db "        |  _____  | |", 10
                    db "        | |  ?  | | |", 10
                    db "        | |_____| | /", 10
                    db "        |_________|/", 10
                    db "[1] Open Chest  [2] Leave Chest", 10
                    db "Enter choice: ", 0
    msg_chest_open  db "You opened the chest and found 50 Gold!", 10, 0
    msg_chest_leave db "You cautiously leave the chest untouched and move on.", 10, 0

    ; --- Room 3: Dragon ASCII Art ---
    dragon_art      db 10, "=== ROOM 3: DRAGON'S LAIR ===", 10
                    db "               / \  //\", 10
                    db "      |\___/|      \", 10
                    db "      /0  0  \      |", 10
                    db "     /   ^    \    /", 10
                    db "    /  \___/   \  /", 10
                    db "    \___________\/", 10
                    db "THE DRAGON AWAKENS!", 10, 0

    ; --- Combat Menu & Messages ---
    combat_menu_str db 10, "[1] Attack  [2] Defend", 10
                    db "[3] Use Potion  [4] Run", 10
                    db "Enter action: ", 0
    msg_hero_hp     db "Your HP: ", 0
    msg_enemy_hp    db " | Enemy HP: ", 0
    msg_newline     db 10, 0

    msg_you_attack  db "You strike the enemy for ", 0
    msg_dmg_suffix  db " damage!", 10, 0
    msg_you_defend  db "You raise your guard! Incoming damage reduced by 5.", 10, 0
    msg_enemy_atk   db "The enemy attacks and deals ", 0
    msg_enemy_dead  db "The enemy has been defeated!", 10, 0
    msg_run_away    db "You fled back to the dungeon entrance!", 10, 0

    ; --- Potion Messages ---
    msg_potion_ok   db "You drank a health potion! Current Health: ", 0
    msg_potion_none db "Error: No health potions remaining!", 10, 0

    ; --- Status & Inventory Strings ---
    status_hdr      db 10, "--- CHARACTER STATUS ---", 10, 0
    lbl_name        db "Hero: ", 0
    lbl_class       db "Class: ", 0
    lbl_hp          db "Health: ", 0
    lbl_slash       db "/", 0
    lbl_atk         db "Attack: ", 0
    lbl_room        db "Current Dungeon Room: ", 0

    inv_hdr         db 10, "--- INVENTORY ---", 10, 0
    lbl_gold        db "Gold: ", 0
    lbl_potions     db "Health Potions: ", 0

    ; --- End Game Messages ---
    victory_hdr     db 10, "=======================================", 10
                    db "VICTORY!", 10
                    db "CONGRATULATIONS, ", 0
    victory_body    db "You defeated the dragon and escaped!", 10, 0
    lbl_final_gold  db "Final Gold: ", 0
    lbl_rem_hp      db "Remaining Health: ", 0
    victory_ftr     db "YOU ARE A HERO!", 10
                    db "=======================================", 10, 0

    gameover_str    db 10, "=======================================", 10
                    db "GAME OVER", 10
                    db "Your hero has fallen.", 10
                    db "The dungeon remains undefeated.", 10
                    db "BETTER LUCK NEXT TIME!", 10
                    db "=======================================", 10, 0

    msg_exit        db 10, "Exiting Dungeon of the Lost King. Farewell!", 10, 0

section .bss
    hero_name       resb 64
    input_buf       resb 32
    num_buf         resb 16

    hero_class      resd 1
    hero_hp         resd 1
    hero_max_hp     resd 1
    hero_atk        resd 1
    hero_potions    resd 1
    hero_gold       resd 1
    current_room    resd 1

    enemy_hp        resd 1
    enemy_atk       resd 1
    defend_bonus    resd 1
    game_status     resd 1      ; 0 = ongoing, 1 = victory, 2 = defeat

section .text
    global _start

_start:
    call display_welcome
    call get_player_info
    call initialize_character

.main_loop:
    call display_main_menu
    jmp .main_loop

; =============================================================================
; Procedure 1: display_welcome
; =============================================================================
display_welcome:
    push ebp
    mov ebp, esp

    mov ecx, welcome_art
    call print_string

    mov esp, ebp
    pop ebp
    ret

; =============================================================================
; Procedure 2: get_player_info
; Reads hero name and validates character class selection (1..3)
; =============================================================================
get_player_info:
    push ebp
    mov ebp, esp

    mov ecx, prompt_hero
    call print_string
    mov ecx, hero_name
    mov edx, 63
    call read_line

.class_loop:
    mov ecx, prompt_class
    call print_string
    mov ecx, input_buf
    mov edx, 16
    call read_line
    mov esi, input_buf
    call parse_int

    cmp eax, 1
    jl .invalid_class
    cmp eax, 3
    jg .invalid_class

    mov [hero_class], eax
    jmp .welcome_hero

.invalid_class:
    mov ecx, err_class
    call print_string
    jmp .class_loop

.welcome_hero:
    mov ecx, msg_welcome_pre
    call print_string
    mov eax, [hero_class]
    mov ecx, [class_names + eax*4]
    call print_string
    mov ecx, hero_name
    call print_string
    mov ecx, msg_excl
    call print_string

    mov esp, ebp
    pop ebp
    ret

; =============================================================================
; Procedure 3: initialize_character
; Assigns starting stats for Warrior (1), Mage (2), or Archer (3)
; =============================================================================
initialize_character:
    push ebp
    mov ebp, esp

    mov dword [hero_gold], 0
    mov dword [current_room], 1
    mov dword [game_status], 0

    mov eax, [hero_class]
    cmp eax, 1
    je .init_warrior
    cmp eax, 2
    je .init_mage
    jmp .init_archer

.init_warrior:
    mov dword [hero_hp], 100
    mov dword [hero_max_hp], 100
    mov dword [hero_atk], 20
    mov dword [hero_potions], 2
    jmp .init_done

.init_mage:
    mov dword [hero_hp], 70
    mov dword [hero_max_hp], 70
    mov dword [hero_atk], 30
    mov dword [hero_potions], 3
    jmp .init_done

.init_archer:
    mov dword [hero_hp], 85
    mov dword [hero_max_hp], 85
    mov dword [hero_atk], 25
    mov dword [hero_potions], 2

.init_done:
    mov esp, ebp
    pop ebp
    ret

; =============================================================================
; Procedure 4: display_main_menu
; Displays main menu and dispatches player selection
; =============================================================================
display_main_menu:
    push ebp
    mov ebp, esp

    mov ecx, main_menu_str
    call print_string
    mov ecx, input_buf
    mov edx, 16
    call read_line
    mov esi, input_buf
    call parse_int

    cmp eax, 1
    je .do_explore
    cmp eax, 2
    je .do_status
    cmp eax, 3
    je .do_potion
    cmp eax, 4
    je .do_inventory
    cmp eax, 5
    je .do_exit

    mov ecx, err_menu
    call print_string
    jmp .menu_done

.do_explore:
    call explore_dungeon
    jmp .menu_done
.do_status:
    call display_status
    jmp .menu_done
.do_potion:
    call use_potion
    jmp .menu_done
.do_inventory:
    call display_inventory
    jmp .menu_done
.do_exit:
    call exit_program

.menu_done:
    mov esp, ebp
    pop ebp
    ret

; =============================================================================
; Procedure 5: explore_dungeon
; Controls progression through Room 1 (Goblin), Room 2 (Treasure), Room 3 (Dragon)
; =============================================================================
explore_dungeon:
    push ebp
    mov ebp, esp

.room_dispatch:
    mov eax, [current_room]
    cmp eax, 1
    je .room_1
    cmp eax, 2
    je .room_2
    cmp eax, 3
    je .room_3
    jmp .explore_done

.room_1:
    mov ecx, goblin_art
    call print_string
    mov dword [enemy_hp], 30
    mov dword [enemy_atk], 10
    call battle_enemy
    ; If player ran away, current_room is still 1 -> return to main menu
    cmp dword [current_room], 2
    jne .explore_done
    jmp .room_dispatch

.room_2:
    mov ecx, chest_art
    call print_string
    mov ecx, input_buf
    mov edx, 16
    call read_line
    mov esi, input_buf
    call parse_int

    cmp eax, 1
    je .open_chest
    cmp eax, 2
    je .leave_chest

    mov ecx, err_menu
    call print_string
    jmp .room_2

.open_chest:
    add dword [hero_gold], 50
    mov ecx, msg_chest_open
    call print_string
    mov dword [current_room], 3
    jmp .room_dispatch

.leave_chest:
    mov ecx, msg_chest_leave
    call print_string
    mov dword [current_room], 3
    jmp .room_dispatch

.room_3:
    mov ecx, dragon_art
    call print_string
    mov dword [enemy_hp], 60
    mov dword [enemy_atk], 15
    call battle_enemy

.explore_done:
    mov esp, ebp
    pop ebp
    ret

; =============================================================================
; Procedure 6: battle_enemy
; Handles turn-based combat: [1] Attack, [2] Defend, [3] Use Potion, [4] Run
; =============================================================================
battle_enemy:
    push ebp
    mov ebp, esp

.combat_loop:
    mov dword [defend_bonus], 0

    ; Display current HP of Hero and Enemy
    mov ecx, msg_hero_hp
    call print_string
    mov eax, [hero_hp]
    call print_int
    mov ecx, msg_enemy_hp
    call print_string
    mov eax, [enemy_hp]
    call print_int
    mov ecx, msg_newline
    call print_string

    ; Prompt combat choice
    mov ecx, combat_menu_str
    call print_string
    mov ecx, input_buf
    mov edx, 16
    call read_line
    mov esi, input_buf
    call parse_int

    cmp eax, 1
    je .act_attack
    cmp eax, 2
    je .act_defend
    cmp eax, 3
    je .act_potion
    cmp eax, 4
    je .act_run

    mov ecx, err_menu
    call print_string
    jmp .combat_loop

.act_attack:
    mov ecx, msg_you_attack
    call print_string
    mov eax, [hero_atk]
    call print_int
    mov ecx, msg_dmg_suffix
    call print_string

    mov eax, [hero_atk]
    sub [enemy_hp], eax
    cmp dword [enemy_hp], 0
    jle .enemy_defeated
    jmp .enemy_turn

.act_defend:
    mov dword [defend_bonus], 5
    mov ecx, msg_you_defend
    call print_string
    jmp .enemy_turn

.act_potion:
    call use_potion
    jmp .combat_loop

.act_run:
    mov ecx, msg_run_away
    call print_string
    jmp .battle_end

.enemy_turn:
    ; Calculate enemy damage = max(0, enemy_atk - defend_bonus)
    mov eax, [enemy_atk]
    sub eax, [defend_bonus]
    cmp eax, 0
    jge .apply_enemy_dmg
    xor eax, eax

.apply_enemy_dmg:
    push eax
    mov ecx, msg_enemy_atk
    call print_string
    pop eax
    push eax
    call print_int
    mov ecx, msg_dmg_suffix
    call print_string
    pop eax

    sub [hero_hp], eax
    cmp dword [hero_hp], 0
    jle .hero_defeated
    jmp .combat_loop

.hero_defeated:
    mov dword [hero_hp], 0
    mov dword [game_status], 2
    call display_game_result
    jmp .battle_end

.enemy_defeated:
    mov dword [enemy_hp], 0
    mov ecx, msg_enemy_dead
    call print_string

    ; Check if this was Room 3 (Dragon) -> Victory!
    cmp dword [current_room], 3
    je .dragon_slain

    ; Otherwise advance to next room
    inc dword [current_room]
    jmp .battle_end

.dragon_slain:
    mov dword [game_status], 1
    call display_game_result

.battle_end:
    mov esp, ebp
    pop ebp
    ret

; =============================================================================
; Procedure 7: use_potion
; Restores 20 HP capped at hero_max_hp; prevents usage when hero_potions == 0
; =============================================================================
use_potion:
    push ebp
    mov ebp, esp

    cmp dword [hero_potions], 0
    jle .no_potions

    dec dword [hero_potions]
    add dword [hero_hp], 20

    ; Cap hero_hp at hero_max_hp
    mov eax, [hero_hp]
    cmp eax, [hero_max_hp]
    jle .hp_capped
    mov eax, [hero_max_hp]
    mov [hero_hp], eax

.hp_capped:
    mov ecx, msg_potion_ok
    call print_string
    mov eax, [hero_hp]
    call print_int
    mov ecx, msg_newline
    call print_string
    jmp .potion_done

.no_potions:
    mov ecx, msg_potion_none
    call print_string

.potion_done:
    mov esp, ebp
    pop ebp
    ret

; =============================================================================
; Procedure 8: display_status
; Displays Hero Name, Class, HP/MaxHP, Attack, and Current Room
; =============================================================================
display_status:
    push ebp
    mov ebp, esp

    mov ecx, status_hdr
    call print_string

    mov ecx, lbl_name
    call print_string
    mov ecx, hero_name
    call print_string
    mov ecx, msg_newline
    call print_string

    mov ecx, lbl_class
    call print_string
    mov eax, [hero_class]
    mov ecx, [class_names + eax*4]
    call print_string
    mov ecx, msg_newline
    call print_string

    mov ecx, lbl_hp
    call print_string
    mov eax, [hero_hp]
    call print_int
    mov ecx, lbl_slash
    call print_string
    mov eax, [hero_max_hp]
    call print_int
    mov ecx, msg_newline
    call print_string

    mov ecx, lbl_atk
    call print_string
    mov eax, [hero_atk]
    call print_int
    mov ecx, msg_newline
    call print_string

    mov ecx, lbl_room
    call print_string
    mov eax, [current_room]
    call print_int
    mov ecx, msg_newline
    call print_string

    mov esp, ebp
    pop ebp
    ret

; =============================================================================
; Procedure 9: display_inventory
; Displays Gold and remaining Health Potions
; =============================================================================
display_inventory:
    push ebp
    mov ebp, esp

    mov ecx, inv_hdr
    call print_string

    mov ecx, lbl_gold
    call print_string
    mov eax, [hero_gold]
    call print_int
    mov ecx, msg_newline
    call print_string

    mov ecx, lbl_potions
    call print_string
    mov eax, [hero_potions]
    call print_int
    mov ecx, msg_newline
    call print_string

    mov esp, ebp
    pop ebp
    ret

; =============================================================================
; Procedure 10: display_game_result
; Shows Victory or Game Over screen and exits program
; =============================================================================
display_game_result:
    push ebp
    mov ebp, esp

    cmp dword [game_status], 1
    je .show_victory

    ; Otherwise Game Over
    mov ecx, gameover_str
    call print_string
    call exit_program

.show_victory:
    mov ecx, victory_hdr
    call print_string
    mov ecx, hero_name
    call print_string
    mov ecx, msg_excl
    call print_string

    mov ecx, victory_body
    call print_string

    mov ecx, lbl_final_gold
    call print_string
    mov eax, [hero_gold]
    call print_int
    mov ecx, msg_newline
    call print_string

    mov ecx, lbl_rem_hp
    call print_string
    mov eax, [hero_hp]
    call print_int
    mov ecx, msg_newline
    call print_string

    mov ecx, victory_ftr
    call print_string
    call exit_program

    mov esp, ebp
    pop ebp
    ret

; =============================================================================
; Procedure 11: exit_program
; =============================================================================
exit_program:
    mov ecx, msg_exit
    call print_string

    mov eax, 1          ; sys_exit
    xor ebx, ebx        ; status 0
    int 0x80

; =============================================================================
; Utility Procedures: print_string, print_int, read_line, parse_int
; =============================================================================
print_string:
    push eax
    push ebx
    push ecx
    push edx

    mov edx, ecx
.len_loop:
    cmp byte [edx], 0
    je .len_done
    inc edx
    jmp .len_loop
.len_done:
    sub edx, ecx
    mov eax, 4
    mov ebx, 1
    int 0x80

    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

print_int:
    ; Converts integer in EAX to string and prints it
    push eax
    push ebx
    push ecx
    push edx
    push esi

    mov esi, num_buf + 15
    mov byte [esi], 0
    mov ebx, 10

    cmp eax, 0
    jne .conv_loop
    dec esi
    mov byte [esi], '0'
    jmp .print_it

.conv_loop:
    cmp eax, 0
    je .print_it
    xor edx, edx
    div ebx
    add dl, '0'
    dec esi
    mov [esi], dl
    jmp .conv_loop

.print_it:
    mov ecx, esi
    call print_string

    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

read_line:
    push ebx
    push ecx
    push edx

    mov eax, 3
    mov ebx, 0
    int 0x80

    pop edx
    pop ecx
    pop ebx
    cmp eax, 0
    jle .empty
    dec eax
    cmp byte [ecx + eax], 10
    jne .no_nl
    mov byte [ecx + eax], 0
    ret
.no_nl:
    inc eax
    mov byte [ecx + eax], 0
    ret
.empty:
    mov byte [ecx], 0
    ret

parse_int:
    xor eax, eax
    xor ecx, ecx
    mov cl, [esi]
    cmp cl, 0
    je .bad_int
.p_loop:
    mov cl, [esi]
    cmp cl, 0
    je .p_done
    cmp cl, '0'
    jl .bad_int
    cmp cl, '9'
    jg .bad_int
    sub cl, '0'
    imul eax, eax, 10
    add eax, ecx
    inc esi
    jmp .p_loop
.bad_int:
    mov eax, -1
.p_done:
    ret