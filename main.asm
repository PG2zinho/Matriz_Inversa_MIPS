.data
    colunas:        .space 4    #espaço para guardar o numero de colunas
    linhas:         .space 4    #espaço para guardar o numero de linhas
    matriz:         .space 400
    matriz_inversa  .space 400 
    quebra_linha:   .asciiz "\n"
    espaco:         .asciiz " "
    barra_vertical: .asciiz "|"
    final:          .asciiz "\nFinal do programa"
    numero_colunas: .asciiz "\nDigite o numero de colunas da matriz:"
    numero_linhas:  .asciiz "\nDigite o numero de linha da matriz:"
    numero:         .asciiz "\nNumero "
.text 
.globl main

main:

    li    $v0,4
    la    $a0,numero_linhas
    syscall

    li    $v0,5
    syscall
    sw    $v0, linhas

    li    $v0,4
    la    $a0, numero_colunas
    syscall

    li    $v0,5
    syscall
    sw    $v0, colunas

    jal Ler_matriz

    jal Imprimir_matriz

    li   $v0, 4
    la   $a0, final
    syscall


    li   $v0,10
    syscall



Ler_matriz:

    lw    $t1,colunas
    la    $t2,matriz
    and   $t3,$zero,$zero
    and   $t4,$zero,$zero

    le_entrada:

        li    $v0,5
        syscall
        sw    $v0,0($t2)

        addi  $t2,$t2,4
        addi  $t4,$t4,1

        beq   $t4,$t1,end_loop_leitura
        j     le_entrada

    end_loop_leitura:

        and   $t4,$zero,$zero
        addi  $t3,$t3,1
        beq   $t3,$t1,end_for_leitura
        j     le_entrada

    end_for_leitura:
        jr    $ra


Imprimir_matriz:

    lw    $t1,colunas
    la    $t2, matriz
    and   $t3,$zero,$zero
    and   $t4,$zero,$zero

    inicio_matriz:

        li    $v0,4
        la    $a0,barra_vertical
        syscall

        li    $v0,4
        la    $a0,espaco
        syscall

    le_matriz:

        li    $v0,1
        lw    $a0,0($t2)
        syscall

        li    $v0,4
        la    $a0,espaco
        syscall


        addi  $t2,$t2,4
        addi  $t4,$t4,1

        beq   $t4,$t1,end_loop_matriz
        j     le_matriz

    end_loop_matriz:

        li    $v0,4
        la    $a0,barra_vertical
        syscall

        li    $v0,4
        la    $a0,quebra_linha
        syscall

        and   $t4,$zero,$zero
        addi  $t3,$t3,1
        beq   $t3,$t1,end_for_impressao
        j     inicio_matriz

    end_for_impressao:

        jr    $ra




