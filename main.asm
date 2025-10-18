.data
    colunas:        .space 4    #espaço para guardar o numero de colunas
    final:          .asciiz "\nFinal do programa"
    tamanho_matriz: .asciiz "Digite o tamanho da sua matriz quadrática:"
    numero:         .asciiz "\nNumero "
    matriz_lida:    .asciiz "\nMatriz lida:\n"
    matriz_iden:    .asciiz "\nMatriz Identidade:\n"
    matriz_inver:   .asciiz "\nMatriz Inversa:\n"
    matriz_recons:  .asciiz "\nMatriz Reconstruida:\n"
    posicao_matriz: .asciiz "posição "
    erro1:          .asciiz "\nPara uma matriz possuir uma inversa, é necessário que sua diagonal não possua zero!\n"
    erro2:          .asciiz "\nA matriz deve ter um tamanho maior que 1\n"
    erro3:          .asciiz "\n A matriz digitada não possui uma matriz inversa \n"
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

    jal Construir_Identidade  

    li   $v0,4
    la   $a0,matriz_inver
    syscall

    jal Gauss_Jordan

    li    $v0,4
    la    $a0,matriz_recons
    syscall

    move  $a2,$s1
    move  $a1,$s0

    jal   Reconstroi_matriz

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

    lw    $t0,colunas
    move  $a1,$s0
    and   $t3,$zero,$zero
    and   $t4,$zero,$zero

    inicio_le_entrada:
        
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

    
    le_entrada:
        s.s   $f0,0($a1)

        addi  $a1,$a1,4
        addi  $t4,$t4,1

        beq   $t4,$t0,end_for2_leitura
        j     inicio_le_entrada

    end_for2_leitura:

        and   $t4,$zero,$zero
        addi  $t3,$t3,1
        beq   $t3,$t0,end_for1_leitura
        j     inicio_le_entrada

    end_for1_leitura:

        addi  $sp,$sp,-4
        sw    $ra,0($sp)

        move    $a1,$s0

        li    $v0,4
        la    $a0,matriz_lida
        syscall

        jal   Imprimir_matriz

        lw    $ra,0($sp)
        addi  $sp,$sp,4

        jr    $ra   
#-----------------------------------------------------------------------------------------------
Imprimir_matriz:

    lw    $t0,colunas
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

        beq   $t4,$t0,end_loop_matriz
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
        beq   $t3,$t0,end_for_impressao
        j     inicio_matriz

    end_for_impressao:

        jr    $ra    
#-----------------------------------------------------------------------------------------------
Construir_Identidade:

    lw    $t0,colunas
    move  $a1,$s1
    and   $t3,$zero,$zero
    and   $t4,$zero,$zero
    and   $t5,$zero,$zero
    addi  $t5,$t5,1

    loop_identidade:

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

            beq   $t4,$t0,end_for2_identidade
            j     loop_identidade

    end_for2_identidade:

        and   $t4,$zero,$zero
        addi  $t3,$t3,1
        beq   $t3,$t0,end_for1_identidade
        j     loop_identidade

    end_for1_identidade:

        addi  $sp,$sp,-4
        sw    $ra,0($sp)

        move    $a1,$s1

        jal   Imprimir_matriz

        lw    $ra,0($sp)
        addi  $sp,$sp,4

        jr    $ra    

#-----------------------------------------------------------------------------------------------
Gauss_Jordan:
    lw    $t0, colunas      #Carrego a quantidade de colunas que a matriz tem
    move  $a1,$s0           #Carrego o endereço da matriz A por referencia (sem acessar ela diretamente por $s0)
    move  $a2,$s1           #Carrego o endereço da matriz I por referencia (sem acessar ela diretamente por $s1)
    and   $t1,$zero,$zero   #Registrador responsavel por monter o controle do looping principal 
    and   $t2,$zero,$zero
    and   $t3,$zero,$zero
    and   $t4,$zero,$zero
    and   $t5,$zero,$zero
    and   $t6,$zero,$zero
    and   $t7,$zero,$zero
    and   $t8,$zero,$zero
    li.s  $f1,0.0           #registrador reservado para fazer compações de c.eq.s com zero
    
    loop_linha_gauss:
        bge     $t1, $t0,end_gauss # Se i >= N, o processo terminou. Pula para imprimir.

        # --- Encontrar o maior pivô na coluna i (a partir da linha i) ---
        mul     $t2,$t1, $t0    
        add     $t2,$t2, $t1
        sll     $t2,$t2, 2
        add     $t2,$a1, $t2       #calcula o pivo A[i][i]
        
        l.s     $f9,0($t2)

        abs.s   $f9, $f9

        add     $t8, $t1,$zero
        add     $t2, $t1,$zero

    loop_pivo:

        bge     $t2, $t0, pivot_maior

        mul     $t4, $t2, $t0
        add     $t4, $t4, $t1
        sll     $t4, $t4, 2
        add     $t4, $a1, $t4       #calcula o proximo pivo, se ele for diferente de 0, substitui a linha

        l.s     $f10, 0($t4)
        abs.s   $f10, $f10

        c.lt.s  $f9, $f10
        bc1f    skip_piv

        mov.s   $f9, $f10
        add     $t8, $t2,$zero

    skip_piv:

        addi    $t2, $t2, 1
        j       loop_pivo

    pivot_maior:
        # --- Troca de linhas ---
        beq     $t8, $t1, sem_troca_linha   #verifica se a linha que possui o maior pivo é na mesma linha inicial, caso for, não irá ter troca de linnha 

        c.eq.s  $f9, $f1
        bc1t    Matriz_nao_invertivel

        and     $t2,$zero,$zero

    troca_linha_loop:

        bge     $t2, $t0, sem_troca_linha
        
        mul     $t3, $t1, $t0
        add     $t3, $t3, $t2
        sll     $t3, $t3, 2
        add     $t4, $a1, $t3       # MODIFICADO: Usa $a1
        
        l.s     $f2, 0($t4)

        mul     $t5, $t8, $t0
        add     $t5, $t5, $t2
        sll     $t5, $t5, 2
        add     $t6, $a1, $t5       # MODIFICADO: Usa $a1

        l.s     $f3, 0($t6)

        s.s     $f3, 0($t4)
        s.s     $f2, 0($t6)

        # Troca em I
        add     $t4, $a2, $t3       # MODIFICADO: Usa $a2 (Matriz I) em vez de $s1
        l.s     $f2, 0($t4)

        add     $t6, $a2, $t5       # MODIFICADO: Usa $a2
        l.s     $f3, 0($t6)

        s.s     $f3, 0($t4)
        s.s     $f2, 0($t6)

        addi    $t2, $t2, 1
        j       troca_linha_loop

    sem_troca_linha:
    ###
        c.eq.s  $f9, $f1
        bc1t    Matriz_nao_invertivel

        and   $t2,$zero,$zero

    norm_loop:
        bge     $t2, $t0, norm_done
        
        mul     $t3, $t1, $t0
        add     $t3, $t3, $t2
        sll     $t3, $t3, 2
        # Normaliza A
        add     $t4, $a1, $t3       # MODIFICADO: Usa $a1
        
        l.s     $f2, 0($t4)
        div.s   $f2, $f2, $f9
        s.s     $f2, 0($t4)

        # Normaliza I
        add     $t4, $a2, $t3       # MODIFICADO: Usa $a2
        
        l.s     $f2, 0($t4)
        div.s   $f2, $f2, $f9
        s.s     $f2, 0($t4)

        addi    $t2, $t2, 1
        j       norm_loop

    norm_done:
        # --- Eliminar os outros elementos da coluna ---
        li      $t6, 0

    elim_k:
        bge     $t6, $t0, next_i
        
        beq     $t6, $t1, skip_line

        mul     $t2, $t6, $t0
        add     $t2, $t2, $t1
        sll     $t2, $t2, 2
        add     $t3, $a1, $t2       # MODIFICADO: Usa $a1
        
        l.s     $f3, 0($t3)
        li      $t2, 0

    elim_j:
        bge     $t2, $t0, elim_done

        mul     $t4, $t6, $t0
        add     $t4, $t4, $t2
        sll     $t4, $t4, 2
        add     $t5, $a1, $t4       # MODIFICADO: Usa $a1
        
        l.s     $f2, 0($t5)
        mul     $t9, $t1, $t0
        add     $t9, $t9, $t2
        sll     $t9, $t9, 2
        add     $t8, $a1, $t9       # MODIFICADO: Usa $a1
        
        l.s     $f4, 0($t8)
        mul.s   $f5, $f3, $f4
        sub.s   $f2, $f2, $f5

        s.s     $f2, 0($t5)

        add     $t5, $a2, $t4       # MODIFICADO: Usa $a2
        l.s     $f2, 0($t5)
        add     $t8, $a2, $t9       # MODIFICADO: Usa $a2
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

    # --- Rotinas de finalização da função ---
    end_gauss:

        addi  $sp,$sp,-4
        sw    $ra,0($sp)

        move  $a1,$s1

        jal   Imprimir_matriz

        move  $a1,$s0

        li    $v0,4
        la    $a0,matriz_iden
        syscall 

        jal   Imprimir_matriz

        lw    $ra,0($sp)
        addi  $sp,$sp,4

        jr    $ra

    Matriz_nao_invertivel:
        li      $v0, 4
        la      $a0, erro3
        syscall
        jr      $ra

#--------------------------------------------------------------------------------------------------------------------------
Reconstroi_matriz:

    lw    $t0,colunas
    and   $t1,$zero,$zero   #Meu i = 0
    and   $t2,$zero,$zero   #Meu j = 0
    and   $t3,$zero,$zero   #Meu k = 0
    and   $t4,$zero,$zero
    and   $t5,$zero,$zero
    and   $t6,$zero,$zero
    and   $t7,$zero,$zero
    and   $t8,$zero,$zero
    
    inicio_reconstroi:
        bge   $t1,$t0,end_reconstroi
        and   $t2,$zero,$zero

    loop_reconstroi:

        bge   $t2,$t0,prox_iteracao
        and   $t3,$zero,$zero
        li.s  $f4,0.0

        multiplica: 

            bge   $t3,$t0,end_multiplica
            
            mul   $t4,$t1,$t0
            add   $t4,$t4,$t3
            sll   $t4,$t4,2
            add   $t5,$a1,$t4

            l.s   $f2,0($t5)

            mul   $t6,$t3,$t0
            add   $t6,$t6,$t2
            sll   $t6,$t6,2
            add   $t7,$a2,$t6

            l.s   $f3,0($t7)

            mul.s $f3,$f2,$f3
            add.s $f4,$f4,$f3

            addi  $t3,$t3,1

            j     multiplica

        end_multiplica:

            addi  $sp,$sp,-4
            addi  $t8,$t8,1

            s.s   $f4,($sp)

            addi  $t2,$t2,1

            j     loop_reconstroi

    prox_iteracao:

        addi  $t1,$t1,1
        j     inicio_reconstroi

    end_reconstroi:

        move  $a1,$s0
        and   $t1,$zero,$zero
        and   $t2,$zero,$zero
        add   $t3,$t8,$zero

        addi  $t9,$t8,-1
        sll   $t9,$t9,2
        add   $a1,$a1,$t9

    insere_for1:
        bge   $t1,$t8,end_function
        and   $t2,$zero,$zero

        l.s   $f2,0($sp)

        s.s   $f2,0($a1)

        addi  $a1,$a1,-4
        addi  $sp,$sp,4
        addi  $t1,$t1,1

        j    insere_for1
    end_function:

        addi  $sp,$sp,-4
        sw    $ra,0($sp)

        move  $a1,$s1

        jal Imprimir_matriz

        lw   $ra,0($sp)
        addi $sp,$sp,4

        jr    $ra











        

    







