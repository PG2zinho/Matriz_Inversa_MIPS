.data
    colunas:        .space 4    #espaço para guardar o numero de colunas
    final:          .asciiz "\nFinal do programa"
    tamanho_matriz: .asciiz "Digite o tamanho da sua matriz quadrática:"
    numero:         .asciiz "\nNumero "
    matriz_lida:    .asciiz "\nMatriz lida:\n"
    matriz_iden:    .asciiz "\nMatriz Identidade:\n"
    matriz_inver:   .asciiz "\nMatriz Inversa:\n"
    posicao_matriz: .asciiz "posição "
    erro1:          .asciiz "\nPara uma matriz possuir uma inversa, é necessário que sua diagonal não possua zero!\n"
    erro2:          .asciiz "\nA matriz deve ter um tamanho maior que 1\n"
.text 
.globl main

main:

    li    $v0,4
    la    $a0,tamanho_matriz
    syscall

    li    $v0,5
    syscall

    slti  $t0,$v0,2
    bne   $t0,$zero,tamanho_invalido

    sw    $v0, colunas

    mul   $v0,$v0,$v0
    sll   $a0,$v0,2

    li    $v0,9
    syscall
    move  $s0,$v0

    li    $v0,9
    syscall
    move  $s1,$v0

    jal Ler_matriz

    li    $v0,4
    la    $a0,matriz_iden
    syscall

    jal Construir_Inversa   

    jal Gauss_Jordan

    li   $v0, 4
    la   $a0, final
    syscall


    li   $v0,10
    syscall

#-----------------------------------------------------------------------------------------------

tamanho_invalido:

    li    $v0,4
    la    $a0,erro2
    syscall

    j    main



#-----------------------------------------------------------------------------------------------
Ler_matriz:

    lw    $t1,colunas
    move  $a1,$s0
    and   $t3,$zero,$zero
    and   $t4,$zero,$zero

    le_entrada:
        
        li    $v0,4
        la    $a0,posicao_matriz
        syscall

        li    $v0,1
        add   $a0,$zero,$t3
        addi  $a0,$a0,1
        syscall

        add   $a0,$zero,$t4
        addi  $a0,$a0,1
        syscall

        li    $v0,11
        addi  $a0,$zero,58
        syscall

        li    $v0,6
        syscall

    
    le_entrada2:
        s.s   $f0,0($a1)

        addi  $a1,$a1,4
        addi  $t4,$t4,1

        beq   $t4,$t1,end_loop_leitura
        j     le_entrada

    end_loop_leitura:

        and   $t4,$zero,$zero
        addi  $t3,$t3,1
        beq   $t3,$t1,end_for_leitura
        j     le_entrada

    end_for_leitura:

        addi  $sp,$sp,-4
        sw    $ra,0($sp)

        move    $a1,$s0

        li    $v0,4
        la    $a0,matriz_lida
        syscall

        jal   Imprimir_matriz

        lw    $ra,0($sp)
        addi  $sp,$sp,4

        and   $a1,$zero,$zero

        jr    $ra   
    
    verifica:
        li.s    $f2,0.0
        c.eq.s  $f0,$f2
        bc1f    le_entrada2

        li    $v0,4
        la    $a0,erro1
        syscall 

        j     le_entrada
#-----------------------------------------------------------------------------------------------
Imprimir_matriz:

    lw    $t1,colunas
    and   $t3,$zero,$zero
    and   $t4,$zero,$zero

    inicio_matriz:

        li    $v0,11
        addi  $a0,$zero,124
        syscall

        li    $v0,11
        addi  $a0,$zero,32
        syscall

    le_matriz:

        li    $v0,2
        l.s   $f12,0($a1)
        syscall

        li    $v0,11
        addi  $a0,$zero,32
        syscall


        addi  $a1,$a1,4
        addi  $t4,$t4,1

        beq   $t4,$t1,end_loop_matriz
        j     le_matriz

    end_loop_matriz:

        li    $v0,11
        addi  $a0,$zero,124
        syscall

        li    $v0,11
        addi  $a0,$zero,10
        syscall

        and   $t4,$zero,$zero
        addi  $t3,$t3,1
        beq   $t3,$t1,end_for_impressao
        j     inicio_matriz

    end_for_impressao:

        jr    $ra    
#-----------------------------------------------------------------------------------------------
Construir_Inversa:

    lw    $t1,colunas
    move  $a1,$s1
    and   $t3,$zero,$zero
    and   $t4,$zero,$zero
    and   $t5,$zero,$zero
    addi  $t5,$t5,1

    loop_inversa:

        beq   $t3,$t4,UM

        li.s  $f0,0.0
        s.s   $f0,0($a1)

        j     CONTINUA

        UM:
            li.s  $f0,1.0
            s.s   $f0,0($a1)

        CONTINUA:
            addi  $a1,$a1,4
            addi  $t4,$t4,1

            beq   $t4,$t1,end_loop_inversa
            j     loop_inversa

    end_loop_inversa:

        and   $t4,$zero,$zero
        addi  $t3,$t3,1
        beq   $t3,$t1,end_for_inversa
        j     loop_inversa

    end_for_inversa:
        addi  $sp,$sp,-4
        sw    $ra,0($sp)

        move    $a1,$s1

        jal   Imprimir_matriz

        lw    $ra,0($sp)
        addi  $sp,$sp,4

        and   $a1,$zero,$zero

        jr    $ra    

#-----------------------------------------------------------------------------------------------
Gauss_Jordan:

    lw      $t0, colunas        # $t0 = N (ordem da matriz)
    move    $a1, $s0            # $a1 -> endereço base da matriz A
    move    $a2, $s1            # $a2 -> endereço base da matriz identidade (I)
    li      $t1, 0              # i = 0 (linha/coluna do pivô)

loop_linha_gauss:
    bge     $t1, $t0, final_inversa   # Se i >= N, terminou

    # --- Carregar o pivô A[i][i] ---
    mul     $t3, $t1, $t0       # t3 = i * N
    add     $t3, $t3, $t1       # t3 = i*N + i (índice do pivô)
    sll     $t3, $t3, 2         # *4 (float = 4 bytes)
    add     $t4, $a1, $t3
    l.s     $f7, 0($t4)         # f7 = A[i][i] (pivô)

    # --- Normalizar linha i ---
    li      $t2, 0
norm_loop:
    bge     $t2, $t0, norm_done

    # Normaliza A
    mul     $t5, $t1, $t0
    add     $t5, $t5, $t2
    sll     $t5, $t5, 2
    add     $t6, $a1, $t5
    l.s     $f2, 0($t6)
    div.s   $f2, $f2, $f7
    s.s     $f2, 0($t6)

    # Normaliza I
    add     $t6, $a2, $t5
    l.s     $f2, 0($t6)
    div.s   $f2, $f2, $f7
    s.s     $f2, 0($t6)

    addi    $t2, $t2, 1
    j       norm_loop

norm_done:
    # --- Eliminar os outros elementos da coluna i ---
    li      $t6, 0
elim_k:
    bge     $t6, $t0, next_i
    beq     $t6, $t1, skip_line

    # Fator = A[k][i]
    mul     $t2, $t6, $t0
    add     $t2, $t2, $t1
    sll     $t2, $t2, 2
    add     $t3, $a1, $t2
    l.s     $f3, 0($t3)         # f3 = A[k][i]

    li      $t2, 0
elim_j:
    bge     $t2, $t0, elim_done

    # Atualiza A[k][j] -= Fator * A[i][j]
    mul     $t4, $t6, $t0
    add     $t4, $t4, $t2
    sll     $t4, $t4, 2
    add     $t5, $a1, $t4
    l.s     $f2, 0($t5)

    mul     $t9, $t1, $t0
    add     $t9, $t9, $t2
    sll     $t9, $t9, 2
    add     $t8, $a1, $t9
    l.s     $f4, 0($t8)

    mul.s   $f5, $f3, $f4
    sub.s   $f2, $f2, $f5
    s.s     $f2, 0($t5)

    # Atualiza I[k][j] -= Fator * I[i][j]
    add     $t5, $a2, $t4
    l.s     $f2, 0($t5)

    add     $t8, $a2, $t9
    l.s     $f4, 0($t8)

    mul.s   $f5, $f3, $f4
    sub.s   $f2, $f2, $f5
    s.s     $f2, 0($t5)

    addi    $t2, $t2, 1
    j       elim_j

elim_done:
    addi    $t6, $t6, 1
    j       elim_k

skip_line:
    addi    $t6, $t6, 1
    j       elim_k

next_i:
    addi    $t1, $t1, 1
    j       loop_linha_gauss

# --- Imprimir matriz inversa ---
final_inversa:
    li      $v0, 4
    la      $a0, matriz_inver
    syscall

    addi    $sp, $sp, -4
    sw      $ra, 0($sp)

    move    $a1, $a2            # endereço da inversa (I final)
    jal     Imprimir_matriz

    lw      $ra, 0($sp)
    addi    $sp, $sp, 4
    jr      $ra



