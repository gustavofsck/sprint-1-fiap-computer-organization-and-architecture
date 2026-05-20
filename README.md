# Módulo de controle otimizado em baixo nível (Assembly) para eletropostos

**Integrantes:** Gustavo Martins da Silva **RM:** 570584

**Problema:**
  Sistemas de eletropostos frequentemente utilizam software de alto nível e hardware genérico,    o que pode gerar:

  * Consumo desnecessário de energia
  * Baixa eficiência no processamento de dados (ex: autenticação, controle de carga)
  * Desperdício de recursos computacionais

**Justificativa:**
  A implementação em Assembly reduz consumo e latência ao controlar diretamente o hardware,       melhora determinismo e segurança (menos dependências), e otimiza uso de memória/timers em
  microcontroladores, resultando em menor custo operacional e maior confiabilidade dos  
  eletropostos.

**Proposta de solução:**
  Módulo de controle em assembly nasm (i386), projetado para rodar em diversas placas x86 que 
  suportam i386, como: UDOO x86 / UDOO x86 II | Intel NUC (ex: NUC8i3BEH) | AAEON UP Xtreme

  
**Arquitetua utilizada:**
  32-bit x86 (IA-32)

**Trechos de código & Impactos esperados:**

No código assembly usamos uma função 'print' para mostrar ao usuário o que está acontecendo, como mostrado nos trechos de código abaixo:


    msg db 'Por favor digite seu ID: ', 0Ah, 0
	  msg_len equ $ - msg

    ; prints on screen
    print:
	    mov eax, 4
	    mov ebx, 1
	    int 80h

	    ret

	  ; prints a message prompting the user to type in their id 
	  mov edx, msg_len 
	  mov ecx, msg 
	  call print

  
  
No código em C usamos o printf para realizar a mesma tarefa, como mostram os trechos de código abaixo:


    const char* msg = "Por favor digite seu ID: \n";
    printf("%s", msg);


Isolando essa tarefa (imprimir uma mensagem na tela) e executando-a tanto em assembly quanto em C, 10.000 vezes com o 'perf stat' em uma distro Linux, obtivemos os seguintes resultados:
  
    *C:*
  
      Performance counter stats for './print_c' (10000 runs):

           199,377      cycles:u                ( +-  0.02% )
           115,255      instructions:u          ( +-  0.00% )
            12,290      cache-references:u      ( +-  0.04% )
               112      cache-misses:u          ( +-  0.77% )
             2,016      branch-misses:u         ( +-  0.05% )

       0.000336468 +- 0.000000149 seconds time elapsed  ( +-  0.04% )

    *Assembly:*

      Performance counter stats for './print_a' (10000 runs):

             1,826      cycles:u                ( +-  0.12% )
                12      instructions:u          ( +-  0.01% )
                43      cache-references:u      ( +-  0.18% )
                 0      cache-misses:u
                 1      branch-misses:u

       0.000160483 +- 0.000000111 seconds time elapsed  ( +-  0.07% )
  

Como pode-se ver, realizar a mesma tarefa em C levou 197.551 ciclos a mais quando comparado 
ao assembly. O código C executou 115.243 instruções a mais, 12.247 acessos ao cache a mais,
112 faltas de cache a mais e 2.015 mispredições de ramo a mais.
