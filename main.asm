.data
    colunas:        .space 4    #espaço para guardar o numero de colunas
    final:          .asciiz "\nFinal do programa\n"
    tamanho_matriz: .asciiz "Digite o tamanho da sua matriz quadrática:"
    numero:         .asciiz "\nNumero "
    matriz_lida:    .asciiz "\nMatriz lida:\n"
    matriz_iden:    .asciiz "\nMatriz Identidade:\n"
    matriz_inver:   .asciiz "\nMatriz Inversa:\n"
    matriz_recons:  .asciiz "\nMatriz A vezes sua Inversa:\n"
    posicao_matriz: .asciiz "posição "
    erro2:          .asciiz "\nA matriz deve ter um tamanho valido! (N > 1)\n"
    erro3:          .asciiz "\n A matriz digitada não possui uma matriz inversa \n"
.text 
.globl main

main:

    li    $v0,4                 #imprimo mensagem na tela de qual será o tamanho  da matriz
    la    $a0,tamanho_matriz
    syscall

    li    $v0,5                #leio o numeor digitado pelo usuário no console
    syscall

    slti  $t0,$v0,2           #caso o usuário digitar um tamanho inválido, ele vai cair em um erro e terá que digitar denovo o tamanho da matriz
    bne   $t0,$zero,tamanho_invalido

    sw    $v0, colunas        #guardo em memória o tamanho da matriz

    mul   $v0,$v0,$v0         #multilplico o valor digitado por ele mesmo, para fazer uma matriz quadrática
    sll   $a0,$v0,2           #multiplico o conteudo de $v0 por 4 e guardo em $a0

    li    $v0,9               #carrego 9 em $v0 para chamar um syscall para alocar dinamicamente um espaço de memória
    syscall
    move  $s0,$v0             #aloco um espaço de memória equivalente ao valor em bytes que está armazenado em $a0 e guardo o endereço do começo deste bloco de memória em $s0

    li    $v0,9               #aloco novamente mais um espaço de memória para construir a matriz identidade e depois novamente para fazer uma copia da matriz digitada
    syscall
    move  $s1,$v0

    li    $v0,9               #Bloco de memória em que vou fazer a cópia da Matriz A
    syscall
    move  $s2,$v0

    move  $a1,$s0             #movo os endereços dos blocos de memória para os registradores $a1 e $a2 para passa-los como parametro
    move  $a2,$s2

    jal Ler_matriz            #chamo a função de ler matriz

    li    $v0,4               #imprimo a mensagem para mostrar a matriz identidade montada
    la    $a0,matriz_iden
    syscall

    move  $a1,$s1              #passo o endereço do bloco de memória que vai ficar minha matriz identidade

    jal Construir_Identidade   #chamo a função para construir a matriz identidade

    li   $v0,4                 # imprimo a mensagem para mostrar a matriz inversa
    la   $a0,matriz_inver       
    syscall

    move  $a1,$s0           #Carrego o endereço da matriz A por referencia (sem acessar ela diretamente por $s0)
    move  $a2,$s1           #Carrego o endereço da matriz I por referencia (sem acessar ela diretamente por $s1)

    jal Gauss_Jordan           #chamo a função que calcula a matriz inversa               

final_programa:
    li   $v0, 4                #imprimo a mensagem de final do programa
    la   $a0, final
    syscall

    li   $v0,10                 #encerro o programa
    syscall

#-----------------------------------------------------------------------------------------------

tamanho_invalido:           #tratamento de erro para quando o usuário digitar um tamanho inválido

    li    $v0,4             # imprime mensagem de erro
    la    $a0,erro2
    syscall

    j    main               #pula novamente para o começo da main, para reiniciar o processo de criar a matriz



#-----------------------------------------------------------------------------------------------
Ler_matriz:

    lw    $t0,colunas       #Carrega da memoria o numero de colunas/linhas que a matriz possui
    and   $t3,$zero,$zero   #zero os constadores $t3 e $t4
    and   $t4,$zero,$zero

    inicio_le_entrada:
        
        li    $v0,4         #imprimo a mensagem de posicao
        la    $a0,posicao_matriz   
        syscall

        li    $v0,1         #Movo 1 para $v0, para fazer um syscall para imprimir o valor que está dentro dos contadores
        add   $a0,$zero,$t3 #Movo o valor que esta no contador i ($t3) para $a0
        addi  $a0,$a0,1     #incremento 1 em $a1 para sinalizar certo a posição do valor que está sendo inserido na posição da matriz
        syscall             #imprimo o conteudo de $a0 no console

        add   $a0,$zero,$t4 #Mesma estratégia acima, porem para o contador j ($t4)
        addi  $a0,$a0,1
        syscall             #imprimo o conteudo de $a0 no console

        li    $v0,11        #Imprimo um dois pontos usando a tabela ascii, para isso movo 11 para $v0, sinalizando que vou imprimir um char da tabela ascii
        addi  $a0,$zero,58  #Coloco 58 dentro de $a0, utilizando a tabela ascii que é (":")
        syscall             #Imprimo os "dois pontos"

        li    $v0,6         #Movo 6 para $v0, para indicar que vou ler do console 
        syscall             #leio o valor que o usuario digitar após ele apertar um enter

    
    le_entrada:
        s.s   $f0,0($a1)    #Guardo a entrada no endereço de memória apontado por $a1
        s.s   $f0,0($a2)    #Copia a entrada para o endereço de memória apontado para $a2 (Fazendo uma copia da matriz original)

        addi  $a1,$a1,4     #Passo o bloco de memória em $a1 e $a2
        addi  $a2,$a2,4
        addi  $t4,$t4,1     #Adiciono 1 no contador 

        beq   $t4,$t0,end_for2_leitura      #Caso o valor que está no contador for igual ao valor que está em $t0 ir para o label end_for2_leitura
        j     inicio_le_entrada             #Pulo automaticamente para o label inicio_le_entrada

    end_for2_leitura:   

        and   $t4,$zero,$zero           #Zero meu contador j ($t4)
        addi  $t3,$t3,1                 #Adiciono 1 em i ($t3)
        beq   $t3,$t0,end_for1_leitura  #pulo para o label end_for1_leitura caso i seja igual ao valor em $t0
        j     inicio_le_entrada         #pulo para o label inicio_le_entrada incondicionalmente

    end_for1_leitura:

        addi  $sp,$sp,-4                #Crio espaço na pilha para guardar o valor de $ra
        sw    $ra,0($sp)                #Guardo o valor de $ra na pilha

        move    $a1,$s0                 #Passo o endereço de bloco de memória onde está a matriz lida

        li    $v0,4                     #imprimo a mensagem de matriz lida
        la    $a0,matriz_lida
        syscall

        jal   Imprimir_matriz           #chamo a função para imprimir a matriz lida

        lw    $ra,0($sp)                #Recupero o valor de $ra da pilha
        addi  $sp,$sp,4

        jr    $ra                       #retorno da para a main
#-----------------------------------------------------------------------------------------------
Imprimir_matriz:

    lw    $t0,colunas                   #Carrega o numero  de colunas/linhas da matriz
    and   $t3,$zero,$zero
    and   $t4,$zero,$zero

    inicio_matriz:

        li    $v0,11                     #imprimo o caractere de barra "|"
        addi  $a0,$zero,124
        syscall

        li    $v0,11                     #imprimo um espaço em branco, para deixar a matriz bem formatada
        addi  $a0,$zero,32
        syscall

    le_matriz:

        li    $v0,2                       #imprimo o valor que no endereço de memória que está sendo apontado por $a1
        l.s   $f12,0($a1)
        syscall

        li    $v0,11                      #imprimo mais um espaço em branco
        addi  $a0,$zero,32
        syscall


        addi  $a1,$a1,4                  #passo para o proximo elemento da matriz
        addi  $t4,$t4,1                  #incremento o contador j ($t4)

        beq   $t4,$t0,end_loop_matriz    #caso j seja igual ao valor em $t0, pulo para o label end_loop_matriz
        j     le_matriz                  #pulo incondicionalmente para o label le_matriz

    end_loop_matriz:

        li    $v0,11                     #imprimo o caractere de barra "|"
        addi  $a0,$zero,124
        syscall

        li    $v0,11                     #imprimo uma nova linha
        addi  $a0,$zero,10
        syscall

        and   $t4,$zero,$zero             #zero o contador j ($t4)
        addi  $t3,$t3,1                   #incremento o contador i ($t3)
        beq   $t3,$t0,end_for_impressao   #pulo para o label end_for_impressao caso i seja igual ao valor em $t0
        j     inicio_matriz               #pulo incondicionalmente para o label inicio_matriz

    end_for_impressao:

        jr    $ra                         #retorno da função para a main ou para a função que a chamou
#-----------------------------------------------------------------------------------------------
Construir_Identidade:

    #Inicialização de variáveis
    lw    $t0,colunas                     
    and   $t3,$zero,$zero
    and   $t4,$zero,$zero
    and   $t5,$zero,$zero
    addi  $t5,$t5,1
    li.s  $f0,0.0                  #registrador reservado para armazenar o valor 0.0
    li.s  $f1,1.0                  #registrador reservado para armazenar o valor 1.0

    #loop principal para construir a matriz identidade
    loop_identidade:

        beq   $t3,$t4,UM        #Se i == j, pula para a label "UM" para armazenar 1.0 na posição correspondente

        s.s   $f0,0($a1)        #Senão, armazeno 0.0

        j     CONTINUA          #Pula para o label "CONTINUA" incondicionalmente

        UM:
            s.s   $f1,0($a1)    #Armazeno 1.0 na posição correspondente

    CONTINUA:

        addi  $a1,$a1,4                     #Passo para o próximo elemento da matriz identidade
        addi  $t4,$t4,1                     #Incremento o contador j ($t4)
 
        beq   $t4,$t0,end_for2_identidade   #Se j == N, pula para o label end_for2_identidade
        j     loop_identidade               #Pula incondicionalmente para o label "loop_identidade"

    end_for2_identidade:

        and   $t4,$zero,$zero               #Zera o contador j ($t4)
        addi  $t3,$t3,1                     #Incremento o contador i ($t3)

        beq   $t3,$t0,end_for1_identidade   #Se i == N, pula para o label end_for1_identidade
        j     loop_identidade               #Pula incondicionalmente para o label "loop_identidade"

    end_for1_identidade:

        addi  $sp,$sp,-4                   #Crio espaço na pilha para guardar o retorno da main
        sw    $ra,0($sp)                   #Guardo o valor de $ra na pilha

        move    $a1,$s1                    #Passo o endereço do bloco de memória onde está a matriz identidade

        jal   Imprimir_matriz              #chamo a função para imprimir a matriz identidade

        lw    $ra,0($sp)                   #Recupero o valor de $ra da pilha
        addi  $sp,$sp,4                    #Libero o espaço da pilha

        jr    $ra                          #retorno da função para a main

#----------------------------------------------------------------------------q-------------------
Gauss_Jordan:
    lw    $t0, colunas      #Carrego a quantidade de colunas que a matriz tem
    and   $t1,$zero,$zero   #Registrador responsavel por monter o controle do looping principal i

    # Inicialização dos registradores temporários
    and   $t2,$zero,$zero   
    and   $t3,$zero,$zero
    and   $t4,$zero,$zero
    and   $t5,$zero,$zero
    and   $t6,$zero,$zero
    and   $t7,$zero,$zero
    and   $t8,$zero,$zero
    li.s  $f1,1.0e-6                    #registrador reservado para fazer compações de c.lt.s com numeros muitos proximos de zero
    
    loop_linha_gauss:
        bge    $t1, $t0,end_gauss       #Se i >= N, o processo terminou. Pula para imprimir.

       #Calcula o endereço do pivo A[i][i]
        mul    $t2,$t1, $t0    #$t2 = i * N
        add    $t2,$t2, $t1    #$t2 = i * N + i
        sll    $t2,$t2, 2      #$t2 = (i * N + i) * 4
        add    $t2,$a1, $t2    #pega o endereço do pivo A[i][i]
        
        l.s    $f7,0($t2)      #Armazena o pivo em $f7     

        abs.s  $f8, $f7        #Armazena o valor absoluto do pivo em $f8

        add    $t8, $t1,$zero  #guarda a coluuna em que foi encontrado o pivo
        add    $t2, $t1,$zero  #Reinicia o contador para fazer o loop de pivo

    loop_pivo:

        bge    $t2, $t0, pivo_maior  #caso o contador for mairo que o tamanho da N da matriz, ir para o label pivo_maior

        #Calcula o endereço do proximo pivo A[k][i]
        mul    $t4, $t2, $t0    #$t4 = k * N
        add    $t4, $t4, $t1    #$t4 = (k * N) + i
        sll    $t4, $t4, 2      #$t4 = (k * N + i) * 4
        add    $t4, $a1, $t4    #Calcula o endereço do proximo pivo

        l.s    $f9, 0($t4)      #guarda o proximo pivo em $f9
        abs.s  $f10, $f9        #calcula o valor absoluto desse pivo

        c.lt.s  $f8, $f10       #verifica se o pivo inicial guardado em $f8 é menor que o proximo pivo
        bc1f    pula_pivo       #caso a afirmação for falsa, pula para o label pula_pivo, que vai apenas passar o contador

        mov.s  $f8,$f10         #caso a condição acima for verdadeira, o proximo pivo (que é maior) entra no lugar do pivo inicial, para fazer uma proxima comparação
        mov.s  $f7,$f9          #armazeno o proximo pivo no lugar do pivo inicial, sem seu valor absoluto
        add    $t8, $t2,$zero   #armazeno a linha em que se encontra esse pivo maior

    pula_pivo:

        addi    $t2, $t2, 1   #apenas vai para a proxima iteração 
        j       loop_pivo     #pula para o começo do loop_pivo

    pivo_maior:
        beq     $t8, $t1, sem_troca_linha   #verifica se a linha que possui o maior pivo é na mesma linha inicial, caso for, não irá ter troca de linnha 

        c.lt.s  $f8, $f1                    #verifico se o valor do meu maior pivo é muito proximo de zero, caso for, quer dizer que a matriz não possui inversa
        bc1t    Matriz_nao_invertivel       #pulo para o rotulo de erro

        and     $t2,$zero,$zero             #reinicio meu contador

    troca_linha_loop:   #processo responsavel por trocar duas linhas de lugar

        bge     $t2, $t0, sem_troca_linha   #Se j >= N, quer dizer que a linha inteira foi trocada
        
        #calcula o endereço da linha A[i][j] que será trocada
        mul     $t3, $t1, $t0       #$t3 = i * N
        add     $t3, $t3, $t2       #$t3 = (i * N) + j
        sll     $t3, $t3, 2         #$t3 = ((i * N ) + j) * 4
        add     $t4, $a1, $t3       #$t4 recebe o endereço de A[i][j]
        
        l.s     $f2, 0($t4)         #Armazena o valor que está no endereço apontado por $t4

        #Calcula o endereço da linha A[maior_pivo][j] que será trocada
        mul     $t5, $t8, $t0       #$t5 = i (do maior pivo) * N
        add     $t5, $t5, $t2       #$t5 = (i * N) + j
        sll     $t5, $t5, 2         #$t5 = ((i * N) + j) * 4
        add     $t6, $a1, $t5       #$t6 recebe o endereço A[i][j] da linha do maior pivo

        l.s     $f3, 0($t6)         #Guarda o valor no endereço apontado por $t6 em $f3

        s.s     $f3, 0($t4)         #Faz a troca de valores entre as linhas
        s.s     $f2, 0($t6)

        # Troca em I
        add     $t4, $a2, $t3       #Faz o mesmo processo de troca na matriz identidade
        l.s     $f2, 0($t4)         #utilizamos os offsets ja calculados em $t3 e $t5 

        add     $t6, $a2, $t5       
        l.s     $f3, 0($t6)

        s.s     $f3, 0($t4)        #Faz o mesmo processo de troca, de valores entre linhas 
        s.s     $f2, 0($t6)

        addi    $t2, $t2, 1         #adiciona 1 no contador 
        j       troca_linha_loop    #volta ao começo do rotulo

    sem_troca_linha:
    ###
        abs.s   $f8,$f7                 #Armazena o valor absoluto do pivo em $f8, para fazer a verificação de se a matriz possui inversa ou não
        c.lt.s  $f8, $f1                #faz uma nova verificação, por  segurança, se a matriz irá possuir uma inversa
        bc1t    Matriz_nao_invertivel   #caso a condição for verdadeira, pula para o tratamento de erro

        and   $t2,$zero,$zero           #zera o meu contador, para ser reutilizado

    norm_loop:
        bge     $t2, $t0, end_norm   #vejo se o contador $t2 está maior que $t0, caso estiver, quer dizer que o looping de normalização acabou e pula para o termino do loop
        
        #Calcula o endereço de A[i][j]
        mul     $t3, $t1, $t0       #i*N
        add     $t3, $t3, $t2       #i*N + j
        sll     $t3, $t3, 2         #Multiplico o resultado que está em $t3 por 4, para obter a posição do elemento que quero dividir na matriz 
        add     $t4, $a1, $t3       #Coloco o endereço do valor na memória em um registrador temporário
        
        l.s     $f2, 0($t4)         #Acesso o elemento e guardo o valor dele em $f2
        div.s   $f2, $f2, $f7       #divido o elemento pelo meu pivo armazenado no registrador $f9
        s.s     $f2, 0($t4)         #coloco o elemento dividido na sua posição original denovo

      
        add     $t4, $a2, $t3       #Agora faço o mesmo processo, porém na matriz identidade
        
        l.s     $f2, 0($t4)         #Acesso o elemento e guardo o valor em $f2
        div.s   $f2, $f2, $f7       #divido o elemento pelo meu pivo armazenado no registrador $f9 
        s.s     $f2, 0($t4)         #coloco o elemento dividido na sua posição original denovo

        addi    $t2, $t2, 1         #incremento meu contador
        j       norm_loop           #pulo para o rotulo norm_loop, para passar para o proximo elemento que é necessário normalizar

    end_norm:
        
        and   $t6,$zero,$zero           #inicio meu contador k ($t6)

    loop_linha_eliminacao:
        bge     $t6, $t0, next_i        #Se k >= N, terminou de eliminar a coluna i
        
        beq     $t6, $t1, end_elim    # Se k == i, quer dizer que k está na mesma linha do pivo, portanto deve pular a linha

        #Calcula o fator = A[k][i] / pivo
        mul     $t2, $t6, $t0           #$t2 = k * N
        add     $t2, $t2, $t1           #$t2 = (k * N) + i
        sll     $t2, $t2, 2             #$t2 = ((k * N) + i) * 4
        add     $t3, $a1, $t2           #$t3 = endereço do valor A[k][i]
        
        l.s     $f3, 0($t3)             #Guardo o valor apontado pelo endereço dentro de $t3
        and     $t2,$zero,$zero         #Zero meu cotador j ($t2)

    loop_coluna_subtracao:  
        bge     $t2, $t0, end_elim      #Se j >= N, significa que a linha k foi processada

        #Calcular endereço de A[k][j]
        mul     $t4, $t6, $t0         #$t4 = k * N        
        add     $t4, $t4, $t2         #$t4 = (k * N) + j
        sll     $t4, $t4, 2           #$t4 = ((k * N) + j) * 4
        add     $t5, $a1, $t4         #$t5 = endereço do valor de A[k][j]
        
        l.s     $f2, 0($t5)           #Guardo o valor apontado pelo endereço dentro de $t5

        #Calcular endereço de A[i][j]
        mul     $t9, $t1, $t0         #$t9 = i * N  
        add     $t9, $t9, $t2         #$t9 = (i * N) + j
        sll     $t9, $t9, 2           #$t9 = ((i * N) + j) * 4
        add     $t8, $a1, $t9         #$t8 = endereço do valor de A[i][j]
        
        l.s     $f4, 0($t8)           #carrega o valor que está no endereço apontado por $t8 em $f4

        #Calcular o novo valor de A[k][j] = A[k][j] - fator * A[i][j]
        mul.s   $f5, $f3, $f4       #$f5 = fator * A[i][j]
        sub.s   $f2, $f2, $f5       #f2 = A [k][j]
        s.s     $f2, 0($t5)         #Salva novo valor em A[k][j]

        add     $t5, $a2, $t4      #reutiliza os offset ja calculados anteriormente em $t4 e $t9, para fazer a mesma operação na matriz identidade
        l.s     $f2, 0($t5)        #$f2 = I[k][j]

        add     $t8, $a2, $t9     #offset $t9, ja calculado anteriormente 
        l.s     $f4, 0($t8)       #$f4 = I[i][j]

        #Calcular o novo valor de I[k][j] = I[k][j] - fator * I[i][j]
        mul.s   $f5, $f3, $f4     #$f5 = fator * I[i][j]
        sub.s   $f2, $f2, $f5     #$f2 = I[k][j] - (fator * I[i][j])
        s.s     $f2, 0($t5)       #Guarda no endereço de I[k][j]

        addi    $t2, $t2, 1       #Adiciona o contador e vai para a proxima iteração
        j       loop_coluna_subtracao

    end_elim:                     #Rotulo que sinaliza que o loop interno acabou ou que o algoritmo está na mesma linha do pivo
        addi    $t6, $t6, 1       #passa o contador k ($t6) e vai para o começo do rotulo loop_linha_eliminacao novamente
        j       loop_linha_eliminacao

    next_i:                         #rotulo que sinaiza o final do loop externo e incrementa o contador i
        addi    $t1, $t1, 1         #incrementa o contador i
        j       loop_linha_gauss    #pula para o começo do algoritmo 

    end_gauss:

        addi  $sp,$sp,-4            #Abro espaço para guardar o valor de $ra (retorno para a main)
        sw    $ra,0($sp)            #Guardo o valor de $ra na pilha

        move  $a1,$s1               #Passo o endereço do bloco de memória onde está a matriz inversa

        jal   Imprimir_matriz       #chamo a função para imprimir a matriz inversa

        move  $a1,$s1               #Passo o endereço do bloco de memória onde está a matriz lida                         
        move  $a2,$s2               #Passo o endereço do bloco de memória onde está a cópia da matriz lida

        li    $v0,4                 #imprimo a mensagem de matriz A vezes sua inversa
        la    $a0,matriz_recons
        syscall      

        jal   Reconstroi_matriz     #chamo a função para reconstruir a matriz

        lw    $ra,0($sp)            #Recupero o valor de $ra da pilha
        addi  $sp,$sp,4

        jr    $ra                   #retorno da função para a main

    Matriz_nao_invertivel:
        li      $v0, 4              #imprimo a mensagem de erro de matriz não invertivel
        la      $a0, erro3
        syscall

        jr      $ra                 #retorno da função para a main

#--------------------------------------------------------------------------------------------------------------------------
Reconstroi_matriz:

    #Inicialização de variáveis
    lw    $t0,colunas
    and   $t1,$zero,$zero   #Meu i = 0
    and   $t2,$zero,$zero   #Meu j = 0
    and   $t3,$zero,$zero   #Meu k = 0
    and   $t4,$zero,$zero
    and   $t5,$zero,$zero
    and   $t6,$zero,$zero
    and   $t7,$zero,$zero
    and   $t8,$zero,$zero
    and   $t9,$zero,$zero
    
    #Loop principal para reconstruir a matriz
    inicio_reconstroi:                
        bge   $t1,$t0,end_reconstroi   #Se i >= N, termina o processo de reconstrução da matriz
        and   $t2,$zero,$zero          #Zera o contador j ($t2)

    loop_reconstroi:

        bge   $t2,$t0,prox_iteracao   #Se j >= N, vai para a próxima iteração do loop principal
        and   $t3,$zero,$zero         #Zera o contador k ($t3)
        li.s  $f4,0.0                 #Zera o acumulador de soma

        multiplica: 

            bge   $t3,$t0,end_multiplica   #Se k >= N, termina o processo de multiplicação
            
            #Calculo o endereço de A[i][k]
            mul   $t4,$t1,$t0          #$t4 = i * N
            add   $t4,$t4,$t3          #$t4 = (i * N) + k
            sll   $t4,$t4,2            #$t4 = ((i * N) + k) * 4
            add   $t5,$a1,$t4          #$t5 = endereço do valor A[i][k]

            l.s   $f2,0($t5)           #Carrego o valor de A[i][k] em $f2

            #Calculo o endereço de B[k][j]
            mul   $t6,$t3,$t0         #$t6 = k * N
            add   $t6,$t6,$t2         #$t6 = (k * N) + j
            sll   $t6,$t6,2           #$t6 = ((k * N) + j) * 4
            add   $t7,$a2,$t6         #$t7 = endereço do valor B[k][j]

            l.s   $f3,0($t7)          #Carrego o valor de B[k][j] em $f3

            mul.s $f3,$f2,$f3         #Multiplico A[i][k] por B[k][j]
            add.s $f4,$f4,$f3         #Acumulo a soma na variável $f4

            addi  $t3,$t3,1          #Incremento o contador k

            j     multiplica         #pulo para o começo do rotulo multiplica

        end_multiplica:

            #Armazeno o valor calculado na pilha temporariamente
            addi  $sp,$sp,-4
            addi  $t8,$t8,1

            
            s.s   $f4,($sp)          #Guardo o valor da soma na pilha

            addi  $t2,$t2,1          #Incremento o contador j

            j     loop_reconstroi    #pulo para o começo do rotulo loop_reconstroi

    prox_iteracao:

        addi  $t1,$t1,1              #Incremento o contador i
        j     inicio_reconstroi

    end_reconstroi:
        
        #Mover os valores da pilha para o bloco de memória da matriz reconstruida
        move  $a1,$s0                #Passo o endereço do bloco de memória onde ficará a matriz reconstruida
        and   $t1,$zero,$zero        #zero o contador i ($t1)
        and   $t2,$zero,$zero        #zero o contador j ($t2)    

        addi  $t9,$t8,-1             #Diminua um do contador total de elementos para usar como offset
        sll   $t9,$t9,2              #multiplico por 4 para usar como offset
        add   $a1,$a1,$t9            #Ajusto o ponteiro $a1 para o fim do bloco de memória da matriz reconstruida

    insere_for1:
        bge   $t1,$t8,end_function  #Se i >= total de elementos, termina o processo de inserção
        and   $t2,$zero,$zero       #zero o contador j ($t2)

        l.s   $f2,0($sp)            #Carrego o valor da pilha para o registrador $f2

        s.s   $f2,0($a1)           #Insiro o valor no bloco de memória da matriz reconstruida

        #Atualização dos ponteiros e contadores
        addi  $a1,$a1,-4
        addi  $sp,$sp,4
        addi  $t1,$t1,1

        j    insere_for1

    end_function:
 
        addi  $sp,$sp,-4            #Crio espaço na pilha para guardar o valor de $ra
        sw    $ra,0($sp)            #Guardo o valor de $ra na pilha

        move  $a1,$s0               #Passo o endereço do bloco de memória onde está a matriz reconstruida

        jal Imprimir_matriz         #chamo a função para imprimir a matriz reconstruida

        lw   $ra,0($sp)             #Recupero o valor de $ra da pilha
        addi $sp,$sp,4              #Libero o espaço da pilha

        jr    $ra                   #retorno da função para a main ou para a função que a chamou

