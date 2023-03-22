.data                                                                            # diretiva para o início do segmento de dados
    ordem:                 .word 0                                               #inicio da posicao na linha 0 e coluna 0
    vetor:                 .word -15, -15, -15, -15, -15, -15, -15, -15, -15     #criacao do vetor de 9 posicoea
    fileira:                 .asciiz  "   |   |   \n"                            # indicador 1, 5, 9 sao modificados 
    separadores:             .asciiz  "---+---+---\n"                            #separador dos vetores
    jogador1:               .byte  'x'                                           #sinalizacao do Xis do jogo
    jogador2:               .byte  'o'                                           #sinalizacao da O - bolinha do jogo
    vazio:                 .byte  ' '                                            #sinalizacao do vazio entre os separadores
    insira_linha:          .asciiz  "\n\nInsira o numero para a linha:"          #usuario digitsr a posicao na linha (0,1,2)
    insira_coluna:         .asciiz  "\nInsira o numero para a coluna:"         #usuario digitsr a posicao na coluna (0,1,2)
    imp_jogador1_ganhou: .asciiz  "\nX (xis) ganhou! PARABÉNS X!\n"              #mensagem caso tenha ganhado do play1
    imp_jogador2_ganhou: .asciiz  "\nO (bolinha) ganhou! PARABENS O!\n"          #mensagem caso tenha ganhado do play2
    imp_empate:          .asciiz  "Poxa empatou!\n"                              #mensagem de empate do jogo
    imp_jogada_invalida: .asciiz  "\nJogada invalida! Tente novamente...\n"      #mensagem caso a linha e coluna tenha sido incorretamente

.text                            # diretiva para o início do segmento de texto
.globl main                      # diretiva p/ usar rotulo global 
    main:
    
inicio:
        jal imp_jogo            #jump para print da estrutura do jogo
        jal jogada              #jump para a questão da coleta de dados do jogador para o jogo da velha
        j   verifica            #jump condicionado para a verificacao das posicoes do jogo
        
        #O primeiro byte a iniciar e o X, depois o 0
   
imp_jogo:
        la $s2, vetor           # armazena o endereco no $s2 o vetor
        la $s0, fileira         #armazena em linha no $s0 
        li $s1, 1               # print o indiciador no $s1
       
desenho:
        lw   $t1, ($s2)         # armazena no $t1 o vetor[i]
        bltz $t1, desenho_vazio # vazio sendo ele considerado menor que zero (if t1 <  0)
        bgtz $t1, desenho_o     # vai desenha a bolinha (desenho_o) em maior que zero ( if t1 >  0)
        bgez $t1, desenho_x     # vai desenhar o  xis (desenha_x) em maior ou igual a zero if t1 >= 0
        
desenho_o:
        lb  $t2, jogador2       # print do caracter = 'o' (bolinha)
        
        j next                  #jump para a parte do next assim que passar pela formacao do desenho O
        
desenho_x:
        lb  $t2, jogador1       # print do caracter = 'x' (xis)
        
        j next                  #jump para a parte do next assim que passar pela formacao do desenho X
        
desenho_vazio:
        lb  $t2, vazio         # print do caracter = ' ' (vazio)
        
        j next                 #jump para a parte do next assim que passar pela formacao do vazio
        
next:
        add $t1, $s0, $s1      # adiciona o t1 para a formação da linha[indicador]
        sb  $t2, ($t1)         # armazena a linha[indicador] = pelo caracter
        addi $s2, $s2, 4       # i++/incremento
        addi $s1, $s1, 4       # valor do indicador seja a soma igual a 4
        li   $t1, 13           # no t1 sendo igual a 13 (indicador 13 nao existe em linha)
        beq  $t1, $s1, imp_linha   # redefini a linha com (if s1 == 13) 
        
        j desenho              #jump para a parte do desenho
        
imp_linha:
        la   $a0, fileira      # armazena no $a0 = as linhas
        li   $v0, 4            # print a sring no $v0
        syscall                # chamada de sistema
        
        li   $s1, 1            # com o indicador = 1 
        li   $t2, 36           # definição de elementos sequenciais e comeca com 0 (array.length)
        la   $t3, vetor        # armazena no registrador t3  = vetor
        add  $t2, $t2, $t3     # adicao para o endereco do vetor + 36 (9 palavras/locais)
        beq  $s2, $t2, exit_imp_desenho    # saida da impressao do desenho ( if i == fim do vetor)
        la   $a0, separadores  # salva no $a0 = *separador
        li   $v0, 4            # print da string
        syscall                # chamada de sistema
        
        j desenho              #jump para a parte do desenho
         
exit_imp_desenho:              #saida da impressao do desenho
        jr $ra                 #jump para o endereco de retorno 

jogada:
        la $a0, insira_linha  #print string do numero da localizacao na linha 
        li $v0, 4             # print da linha
        syscall               # chamada de sistema
        
        li $v0, 5             #read  integer no $v0
        syscall               # chamada de sistema
        
        move $s1, $v0         #armazenamento da linha no registrador $s1
        la $a0, insira_coluna   #print string do numero da localizacao na coluna
        li $v0, 4               #print a coluna
        syscall               # chamada de sistema
        
        li $v0, 5             #read da linha e coluna 
        syscall               # chamada de sistema
        
        move $s2, $v0         # armazenamento da coluna no registrador $s2

        li   $t3, 3           #armazena  o tamanho da linha no  $t3 sendo igual a 3 
        mult $s1, $t3         # multiplicacao entre a linha * 3 
        mflo $s3              # movimenta para o $s3 na sasida para a linha
        add  $s4, $s3, $s2    # adiciona o $s4 para a saida da linha com a coluna em seu local do vetor
        la   $t0, vetor       # carrega o endereco no $t0 o vetor[0]
        li   $t5, 4           # print no $t1 = 4 a dimensao da palavra no vetor 
        mult $s4, $t5         # multiplicacao entre 4 * posicao do vetor
        mflo $s1              # armazena no $s1 a multiplicacao realizada anteriormente
        add  $t1, $t0, $s1    # adiciona no $t1 o endereco do vetor[0] com a posicao salva no $s1 
        lw   $t3, ordem       # armazena no $t3 a ordem do jogo
        li   $t2, 2           # no $t2 guarda dois valores a linha/coluna
        div  $t3, $t2         # divisao da ordem/ 2
        mfhi $t2              # move para o $t2 a ordem de divisao por 2
        li   $t6, 1           # armazena  no $t6 sendo igual a 1
        add  $t3, $t3, $t6    # adiciona no $t3 a soma sendo igual a 1
        beq  $t2, $zero, jogada_player_1 # se a ordem for par no jogador1 e se impar jogador2 
        li   $t5, 1           # armazena no $t5 a resposta do segundo jogador (jogador2)
        
        j verifica_jogada     # jump para a verificacao se foi certa ou errada
        
jogada_player_1:
        li   $t5, 0           # armazena a resposta do primeiro jogador (jogador1)
        
verifica_jogada:
        lw   $t6, ($t1)       #guarda no registrador $t6 a verificacao em comparacao com o registrador $t1
        bgez $t6,jogada_invalida  # Em diferenca ou igual a zero a questao da posicao dos numeros de linha/coluna
        
        j store_da_jogada     #jump para a parte do historico da jogada

jogada_invalida:
        la  $a0, imp_jogada_invalida      #armazena o endereco da jogada invalida
        li  $v0, 4            #print a mensagem da jogada invalida
        syscall               # chamada de sistema
        
        j jogada             #jump para a volta de jogar novamente e ver quem seria o vencedor

store_da_jogada:
        sw   $t3, ordem      # incremento da ordem++
        sw   $t5, ($t1)      #salvo no registrador $t5 no seu historico das jogadas
        
        jr   $ra             #jump para o endereco de retorno 

verifica:                    #os blocos de verificacao da posicao dos vetores em matriz ate ser encontrado um resultado

     #Bloco de comparacao dos valores e posicoes 
     
        la  $s5, vetor       #armazena os vetores no registrador $s5
        lw  $s0, 4($s5)      #posicao   x1x
        lw  $s1, 16($s5)     #posicao    x1x
        lw  $s2, 24($s5)     #posicao     1x1 1+4+6+7 = 4 || 0
        lw  $s3, 32($s5)
        
        jal soma_empate      #jump para a´parte de analise de empate correlacionada com a soma 
        
        lw  $s0, 4($s5)      #posicao     x1x
        lw  $s1, 12($s5)     #posicao      11x
        lw  $s2, 16($s5)     #posicao     xx1 1+3+4+8 = 4 || 0
        lw  $s3, 32($s5)     #guardar em $s3 das posicoes optadas
        
        jal soma_empate      #jump para a´parte de analise de empate correlacionada com a soma 
        
        lw  $s0, 4($s5)      #posicao     x1x
        lw  $s1, 16($s5)     #posicao      x11
        lw  $s2, 20($s5)     #posicao     1xx 1+4+5+6 = 4 || 0
        lw  $s3, 24($s5)     #guardar em $s3 das posicoes optadas
        
        jal soma_empate      #jump para a´parte de analise de empate correlacionada com a soma 
        
        lw  $s0, 0($s5)      #posicao    1xx
        lw  $s1, 16($s5)     #posicao     x11
        lw  $s2, 20($s5)     #posicao final  x1x 0+4+5+7 = 4 || 0
        lw  $s3, 28($s5)     #guardar em $s3 das posicoes optadas
        
        jal soma_empate     #jump para a´parte de analise de empate correlacionada com a soma 
        
        lw  $s0, 8($s5)      # posicao     xx1
        lw  $s1, 12($s5)     # posicao     11x
        lw  $s2, 16($s5)     # posicao  final   x1x 2+3+4+7 = 4 || 0
        lw  $s3, 28($s5)     #guardar em $s3 das posicoes optadas
        
        jal soma_empate     #jump para a´parte de analise de empate correlacionada com a soma 
        
        lw  $s0, 0($s5)      #posicao      1x1
        lw  $s1, 8($s5)      #posicao     x1x
        lw  $s2, 16($s5)     #posicao final     x1x 0+2+4+7 = 4 || 0
        lw  $s3, 28($s5)     #guardar em $s3 das posicoes optadas
        
        jal soma_empate     #jump para a´parte de analise de empate correlacionada com a soma 
        
        lw  $s0, 0($s5)      #posicao    1xx
        lw  $s1, 16($s5)     #posicao     x11
        lw  $s2, 20($s5)     #posicao  final    1xx 0+4+5+6 = 4 || 0
        lw  $s3, 24($s5)     #guardar em $s3 das posicoes optadas
        
        jal soma_empate     #jump para a´parte de analise de empate correlacionada com a soma 
        
        lw  $s0, 8($s5)      #posicao      xx1
        lw  $s1, 12($s5)     #posicao     11x
        lw  $s2, 16($s5)     #posicao final   xx1 2+3+4+8 = 4 || 0
        lw  $s3, 32($s5)     #guardar em $s3 das posicoes optadas
        
        jal soma_empate     #jump para a´parte de analise de empate correlacionada com a soma 

        lw  $s0, 0($s5)      #posicao      111 
        lw  $s1, 4($s5)      #posicao     xxx 
        lw  $s2, 8($s5)      #posicao   final  xxx (0 + 1 + 2) = 3 || 0
        
        jal soma_ganha       #jump para a´parte de analise do ganhador  correlacionada com a soma de cada jogada
        
        lw  $s0, 12($s5)     #posicao      xxx 
        lw  $s1, 16($s5)     #posicao      111 
        lw  $s2, 20($s5)     #posicao   final   xxx (3 + 4 + 5) = 3 || 0
        
        jal soma_ganha      #jump para a´parte de analise do ganhador  correlacionada com a soma de cada jogada
        
        lw  $s0, 24($s5)     #posicao     xxx 
        lw  $s1, 28($s5)     #posicao     xxx 
        lw  $s2, 32($s5)     #posicao  final   111 (6 + 7 + 8) = 3 || 0
        
        jal soma_ganha       #jump para a´parte de analise do ganhador  correlacionada com a soma de cada jogada
        
        lw  $s0, 0($s5)       #posicao    1xx
        lw  $s1, 12($s5)      #posicao    1xx
        lw  $s2, 24($s5)      #posicao  final   1xx (0 + 3 + 6) = 3 || 0
        
        jal soma_ganha       #jump para a´parte de analise do ganhador  correlacionada com a soma de cada jogada
        
        lw  $s0, 4($s5)       #posicao    x1x
        lw  $s1, 16($s5)      #posicao    x1x
        lw  $s2, 28($s5)      #posicao  final x1x (1 + 4 + 7) = 3 || 0
        
        jal soma_ganha        #jump para a´parte de analise do ganhador  correlacionada com a soma de cada jogada
        
        lw  $s0, 8($s5)       #posicao     xx1 
        lw  $s1, 20($s5)      #posicao    xx1 
        lw  $s2, 32($s5)      #posicao  final   xx1 (2 + 5 + 8) = 3 || 0
        
        jal soma_ganha        #jump para a´parte de analise do ganhador  correlacionada com a soma de cada jogada
        
        lw  $s0, 0($s5)       #posicao     1xx
        lw  $s1, 16($s5)      #posicao     x1x
        lw  $s2, 32($s5)      #posicao  final  xx1 (0 + 4 + 8) = 3 || 0
        
        jal soma_ganha        #jump para a´parte de analise do ganhador  correlacionada com a soma de cada jogada
        
        lw  $s0, 8($s5)       #posicao     xx1
        lw  $s1, 16($s5)      #posicao    x1x
        lw  $s2, 24($s5)      #posicao final    1xx (2 + 4 + 6) = 3 || 0
        
        jal soma_ganha        #jump para a´parte de analise do ganhador  correlacionada com a soma de cada jogada

        j   inicio            # se não empatou nem ganhou continua o jogo voltando novamente para uma proxima partida 

soma_ganha:
        add $t1, $s0, $s1     #adicao do $s0 com o $s2 e guardado no $t1
        add $t1, $t1, $s2     #adicao do $s2 com o $s1 e guardado no $t1
        li  $t2, 3            #print o double do $t2
        beq $t1, $t2,   imp_jogador2_ganhou  #comparacao se o jogador 2 ganho tanto no $t1/$t2
        beq $t1, $zero, imp_jogador1_ganhou  #comparacao se o jogador no $t1
        
        jr  $ra               #jump para o endereco de retorno 
        
soma_empate:
        add $t1, $s0, $s1     #adicao do $s1 com $s2 ($s1+$s2=$t1)
        add $t1, $t1, $s2     #adicao do $s2 com $t1 ($s2+$t1=$t1)
        add $t1, $t1, $s3     #adicao do $s3 com $t1 ($s3+$t1=$t1)
        li  $t2, 4            #print do t2 caso tenha empate 
        beq $t2, $t1, empate  #difernca entre ao comparar o $t1 com $t2 na medidad de haver empate entre os jogadores
        
        jr  $ra               #jump para o endereco de retorno 

jogador1_ganhou:
        jal imp_jogo          #jumper condicionado para o modo do decorrer do jogo 
        la  $a0, imp_jogador1_ganhou   #armazena o endereco da mensagem do jogador1 de vencedor
        li  $v0, 4            #print a mensagem do jogador 1 tenha ganhado a partida
        syscall               # chamada de sistema
        
        j   exit              #jump de saida caso o jogadro 1 ganhe a partida 
        
jogador2_ganhou:
        jal imp_jogo          #jump para a impressao do local de resposta
        la  $a0, imp_jogador2_ganhou   #armazena o endereco se o jogador 2 ganho a partida
        li  $v0, 4            #print a mensagem do jogador 2 tenha ganhado
        syscall               #chamada de sistema
        
        j   exit              #jump para caso ja tenha um vencedor 
        
empate:
        la $a0, imp_empate   #armazena a resposta de empate entre eles
        li $v0, 4            #print da mensagem de impate entre os jogadores
        syscall              #chamada de sistema
        
        j exit               #jump para ir para a saida do programa

exit:
        li  $v0, 10          #print da saida 
        syscall              #chamada de sistema e fim do programa 
