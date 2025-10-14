.data
    colunas:        .space 4    #espaço para guardar o numero de colunas
    final:          .asciiz "\nFinal do programa"
    tamanho_matriz: .asciiz "\nDigite o tamanho da matriz:"
    numero:         .asciiz "\nNumero "
    matriz_lida:    .asciiz "\nMatriz lida:\n"
    matriz_iden:    .asciiz "\nMatriz Identidade:\n"
.text 
.globl main

main:

    li    $v0,4
    la    $a0,tamanho_matriz
    syscall

    li    $v0,5
    syscall
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

    li   $v0, 4
    la   $a0, final
    syscall


    li   $v0,10
    syscall


#-----------------------------------------------------------------------------------------------
Ler_matriz:

    lw    $t1,colunas
    move   $a1,$s0
    and   $t3,$zero,$zero
    and   $t4,$zero,$zero

    le_entrada:

        li    $v0,6
        syscall
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

        li    $v0,1
        l.s    $a0,0($a1)
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

        sw    $zero,0($a1)

        j     CONTINUA

        UM:
            sw    $t5,0($a1)

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

Gauss_Jordan:

    lw    $t1,colunas
    move  $a1,$s0
    move  $a2,$s1
    and   $t3,$zero,$zero
    and   $t4,$zero,$zero





