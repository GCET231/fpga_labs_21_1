# Lab 4: Projeto Sequencial - Contadores

<p align="center">
Prof. João Carlos Bittencourt
</p>
<p align="center">
Centro de Ciências Exatas e Tecnológicas
</p>
<p align="center">
Universidade Federal do Recôncavo da Bahia, Cruz das Almas
</p>

## Introdução

Este laboratório consiste de várias etapas, cada qual construída com base na anterior. Ao longo do roteiro serão fornecidas instruções e capturas de tela referentes às respectivas etapas. Apesar de termos fornecidos a você quase todo o código SystemVerilog, partes deles foram sublimadas de propósito -- Nesses casos, sua tarefa será completar e testar seu código com bastante cuidado.

Nesta atividade prática, você aprenderá:

- Como especificar circuitos sequenciais em SystemVerilog;
- Estratégias diferentes para desenvolvimento de contadores; 
- Incluir funcionalidades de reset síncrono;
- Como incluir funcionalidades de \textit{start/stop} no seus contadores;
- Como trabalhar com *testbench* para simulação de clocks em SystemVerilog;
- Alguns construtores novos em SystemVerilog;

## Leitura

Caso tenha dificuldade nos assuntos referentes à lógica sequencial, segue abaixo uma lista de seções relevantes do livro texto Digital Design and Computer Architecture (David & Sarah Harris).

- **Seções 3.2.3 -- 3.2.6**: Flip-flops e Registradores
- **Seções 4.4.1 -- 4.4.3**: Verilog para Flip-flops e Registradores
- **Seção 5.4.1**: Contadores  

Antes de seguir com o laboratório, é recomendado ainda que você realize o [Tutorial de Simulação Utilizando o ModelSim](https://github.com/GCET231/tutorial3-simulacao-hdl/tree/main/ModelSim), uma vez que os procedimentos à seguir não envolvem síntese do circuito no Quartus Prime.

## Parte 1 - Contador Módulo-4

Vamos começar nossos trabalhos projetando um contador módulo-4 (**Mod-4**). Ou seja, um circuito digital que conta de acordo com a sequência: \(0, 1, 2, 3, 0, 1, 2, 3, 0, ...).

O módulo contador precisará de um registrador de 2-bits para armazenar o valor atual, uma entrada de *clock* para controlar a atualização o contador, e uma entrada de *reset* para redefinir o contador para (0), de forma síncrona.

Todas as mudanças no valor do contador -- seja ela contando ou redefinindo -- devem ser realizada durante a transição da **borda de subida** do sinal de *clock*.

Use o código à seguir para projetar o contador:

```verilog
`timescale 1ns / 1ps
`default_nettype none

module countermod4 (
	input  wire clock, 
	input  wire reset,
	output logic [1:0] value = 2'b00
);

   always @(posedge clock) begin : proc_value
      value <= reset ? 2'b00 : (value + 1'b1);
	end

endmodule
```

O código acima utiliza construtores que não estão presentes no padrão Verilog, mas estão no SystemVerilog: `logic` e `always_ff`. Portanto, quando você criar um novo arquivo de projeto, **garanta que ele é do tipo SystemVerilog**. Chame seu novo arquivo como `countermod4.sv`.

Note o seguinte:

- A primeira linha determina as unidades de tempo para todos os atrasos (semelhante ao que definimos no *testbench*) como nanosegundos com resolução de picossegundos. A segunda linha diz para o compilador para *não* assumir que sinais não declarados são do tipo padrão `wire`. Ao suprimir o valor padrão, nós estamos forçando que sinais não declarados disparem erros de compilação. Isso ajuda a identificar vários erros de código e *será muito útil!* **Utilize essa diretiva em qualquer projeto que dizer a partir de agora!**
- As entradas são declaradas como do tipo `wire` (uma vez que elas estão simplesmente vindo de um módulo externo), mas a saída aqui é do tipo `logic`, e não do tipo `wire`. O tipo `logic` é único da SystemVerilog, e representa diferentes tipos de implementações estruturais, dependendo da descrição do circuito. Especificamente, uma variável do tipo `logic` será mapeado para `wire` se sua descrição indicar uma função combinacional. Por outro lado, uma variável do tipo `logic` resultará em um *flip-flop* sendo instanciado se sua descrição indicar a necessidade de um elemento de estado ou memória. Portanto, o tipo `logic` é usado para indicar que uma variável *pode* (mas não necessariamente) precisa de *flip-flops* em sua implementação.
- O tipo `logic` era chamado de `reg` em Verilog. Entretanto, sua expressão era por vezes erroneamente confundida com o termo `register`. Em SystemVerilog, nós simplesmente usamos o tipo `logic` para a maioria das nossas instâncias, deixando que o compilador determine se a lógica é combinacional ou sequencial, a partir da descrição. Entretanto, se você tem certeza de que está tentando descrever uma parte de lógica combinatória, é melhor declarar sua saída como do tipo `wire`. Isso fará com que o compilador indique um erro se a implementação não for combinatória.
- O comando `always_ff` é um novo tipo de construtor de atribuição não-contínua da linguagem SystemVerilog. Ele é usado para determinar como o valor de um *flip-flop* (registrador) deve ser atualizado. No exemplo acima, dizemos que sempre que houver uma borda positiva do clock (`always_ff@(posedge clock)`), `value` é atualizado para `value + 1` (se estiver contando) ou `0` (se acionado o sinal de `reset`). Deste modo, uma vez que `value` é atualizado dentro da atribuição não-contínua `always_ff`, ela irá implementar uma lógica sequencial usando *flip-flops*, ao invés de lógica combinacional, visto que o `value` é atualizado somente entre os pulsos periódicos do *clock*.
- No código acima, o operador de atribuição utiliza a chamada atribuição **não-bloqueante**, representado pelo símbolo `<=`. Não confunda com a operação "menor que ou igual"! Considere este símbolo como uma seta para a esquerda.
- Por ser declarado como um vetor de 2-bits, o sinal `value` retornará para `0` ao incrementar o somador, quando `value` for igual a `3`.

Para testar o código acima, utilize o *testbench* fornecido junto com os arquivos de laboratório, dentro da pasta `sim` (`countermod4testbench.sv`). Essa rotina de teste realiza o seguinte fluxo de operações:

- Aguarda 5 ns;
- Inicializa o *clock* (borda positiva em 6 ns, com período de 2 ns);
- Simula o contador por 5 pulsos de clock;
- Aciona o sinal de *reset* para redefinir o contador de volta para 0; e
- Libera o contador por mais 3 pulsos de clock;

Certifique-se de ter analisado o *testbench*, linha por linha, e entenda o que cada comando faz! Se você formatar as formas de onda de modo a visualizar os sinais em decimal, você deve visualizar a representação exatamente como apresentada na figura a seguir.

![Simulação do Contador Módulo-4](img/captura_mod4.png)

## Parte 2 - Contador Módulo-7

Nesta parte do laboratório, você deverá projetar um contador de módulo-7 (com *reset* síncrono), e testá-lo usando o ambiente de simulação fornecido. 

Use o contador de módulo-4 da **Parte 1** como ponto de partida, copiando ele dentro de um novo arquivo, chamado `countermod7.sv`, e fazendo as devidas modificações. Note que o contador de módulo-7 será diferente em dois aspectos:

- Ele precisa de um registrador de 3-bits para o sinal `value`, no lugar do registrador de 2-bits usado na Parte I.
- Ele conta de acordo com a sequência 0, 1, 2, 3, 4, 5, 6, 0, 1, 2, 3, 4, 5, 6, 0, ... 
  - Note que esta sequência **não** é uma potência de dois, e que você não poderá partir do pressuposto de que o contador irá zerar por você após chegar em 6!

Use o código a seguir para implementar este contador, completando as regiões comentadas.

```verilog
`timescale 1ns / 1ps
`default_nettype none

module countermod7 (
	input  wire clock, 
	input  wire reset,
	output logic [2:0] value // Observe como esta linha difere da Part I
);

	always @(posedge clock) begin
		value <= reset ? 3'b000 : /* Complete o codigo aqui */;
	end

endmodule
```

Simule o seu novo contador usando o *testbench* fornecido junto aos arquivos de laboratório (`countermod7testbench.v`). 

**Certifique-se de entender todas as linhas do arquivo de teste!** Defina o formato de exibição dos dados (Radix) como **Unsigned** para todas as saídas. Se tudo der certo, sua saída deve reproduzir a sequência apresentada na descrição.

> ***Agora Responda***
>
> - Por que o valor no *waveform* é apresentado como `X` para os primeiros dois nanosegundos de sua simulação?
> - Por que ele é atualizado para `0` em 2 ns? 
> - Ao contrário, na Parte 1, o valor do *waveform* inicia em `0`; Por que?

## Parte 3 - Contador Módulo-7 com sinal de habilitação

Copie a especificação do contador módulo-7 da Parte 2 para um novo arquivo e salve-o com o nome `countermod7enable.v`. 

Sua tarefa agora consiste em modificar o contador módulo-7 de forma a incorporar um sinal de habilitação. Este novo sinal deve inibir o contador até o próxima (uma ou várias) transição da borda de subida do *clock*. Ou seja, se o sinal de habilitação for igual a `0`, na próxima borda positiva do *clock*, o valor do contador não deve mudar. 

Este comportamento deve se manter enquanto o habilitador estiver em nível lógico baixo, proporcionando assim um mecanismo que permita "congelar'' o contador por quanto tempo você desejar. 

De forma semelhante, quando o sinal habilitador (`enable`) é modificado para `1`, o contador volta a contar novamente de onde parou.

Algumas observações:

- Se o sinal `enable` é `0` e `reset` é `1`, o contador deve ser redefinido. Ou seja, o `reset` tem prioridade maior frente ao sinal de `enable`;
- A atribuição ao valor deve ainda ser realizada usando um único comando (`value <= ...`). Você pode ainda dividir o comando em múltiplas linhas por questões de legibilidade, mas ainda assim, deve usar **somente um comando**.

Utilize o *testbench* fornecido junto aos arquivos de laboratório (`countermod7enabletestbench.v`). 

Mais uma vez, analise o *testbench* com cautela e garanta que compreendeu cada linha do código. 

## Parte 4 - Projetando um contador de duas dimensões

Projete um contador de duas dimensões (chamado também de **contador-xy**). Este contador percorre uma matriz 2-D, uma linha de cada vez. O tamanho da matriz é definido como `[0..WIDTH-1,0..HEIGHT-1]`.

A especificação funcional do seu módulo deve seguir as seguintes regras:

- O contador começa em $(x,y) = (0,0)$ e incrementa $x$ de $(0,0)$ até $(WIDTH-1,0)$;
- Em seguida, ele retorna para o início da próxima linha $(0,1)$;
- Da mesma forma, o contador retorna do o final da da última linha $(WIDTH-1, HEIGHT-1)$ para o topo, $(0,0)$;
- O contador também possui uma entrada chamada `enable`. Essa entrada informa para o contador quando continuar a contar ou permanecer inativo. Portanto, se `enable` é 0, o contador não incrementa na próxima borda positiva do *clock*.

Um esboço do código para o módulo `xycounter` é fornecido à seguir. 

```verilog
`timescale 1ns / 1ps
`default_nettype none

module xycounter #(
	parameter WIDTH=2, 
	parameter HEIGHT=2
	)(
	input  wire clock,   
	input  wire enable,  
	output logic [$clog2(WIDTH)-1:0]  x = 0,
	output logic [$clog2(HEIGHT)-1:0] y = 0
);

	always_ff @(posedge clock) begin
		if (enable) begin
			/* Coloque seu código aqui */
		end	
	end
endmodule
```

Certifique-se de entender todo o código que está presente no modelo acima, especialmente a função `clog2()`, e o seu papel na parametrização do módulo contador.

O *testbench* para seu módulo foi fornecido junto com os arquivos de projeto como `xycountertestbench.sv`.

Complete o código com as funcionalidades apresentadas acima, e simule usando este *testbench* para verificar se o seu contador se comporta exatamente como esperado.

Você pode experimentar conjuntos de valores diferentes para largura (`WIDTH`) e altura (`HEIGHT`). Entretanto, você só precisa enviar os resultados para o *testbench* fornecido.

## Entregáveis do Laboratório

### Acompanhamento (entrega: sexta-feira 10 de dezembro, 2021)

Em um documento associado à sua entrega no Google Sala de Aula, submeta o que se pede:

- Uma captura de tela do simulador, mostrando **claramente** o resultado final da simulação para a Parte 2 (não envie o código). 
- Suas respostas para as perguntas no final da Parte 2.
- Seu código para o contador da Parte 2 (`countermod7enable.v`), e uma captura de tela da janela de simulação mostrando **claramente** o resultado final da simulação para a Parte 3.
- Seu código do módulo contador-xy especificado na Parte 4 (`xycounter.v`), devidamente formatado, e uma captura de tela da janela de simulação mostrando **claramente** o resultado final da simulação para a Parte 4.

Apresente uma descrição dos procedimentos realizados neste laboratório, de acordo com o modelo.