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
