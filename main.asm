.data
    colunas:        .space 4    #espaço para guardar o numero de colunas
    final:          .asciiz "\nFinal do programa"
    tamanho_matriz: .asciiz "Digite o tamanho da sua matriz quadrática:"
    numero:         .asciiz "\nNumero "
    matriz_lida:    .asciiz "\nMatriz lida:\n"
    matriz_iden:    .asciiz "\nMatriz Identidade:\n"
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

        beq   $t3,$t4,verifica
    
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

#----------------------------------------------------------------------------------------------------
Gauss_Jordan:

    lw    $t1,colunas
    move  $a1,$s0
    move  $a2,$s1
    and   $t3,$zero,$zero
    and   $t4,$zero,$zero
    and   $t5,$zero,$zero
    and   $t6,$zero,$zero
    and   $t7,$zero,$zero
    and   $t8,$zero,$zero


    inicio_gaus:
        l.s   $f2,0($a1)

    inicio:
        
    
        l.s   $f3,0($a1)
        l.s   $f4,0($a2)


        div.s $f5,$f3,$f2
        div.s $f6,$f4,$f2

        addi  $sp,$sp,-8
        addi  $t7,$t7,8

        s.s   $f5,0($sp)
        s.s   $f6,4($sp)

        s.s   $f5,0($a1)
        s.s   $f6,0($a2)

        beq   $t4,$t1,end_div

        addi  $t4,$t4,1
        addi  $a1,$a1,4
        addi  $a2,$a2,4

        j     inicio
    
    end_div:







    





