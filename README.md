# ClimaApp

App Flutter de previsão do tempo desenvolvido nas aulas. Nesta etapa o projeto foi
refatorado para ter uma tela inicial com navegação e duas telas: **Clima atual** e
**Previsão da semana**.

## Estrutura

```
lib/
  main.dart                     # MyApp + HomeScreen (navegação)
  screens/
    clima_atual.dart            # ClimaAtualScreen
    previsao_semana.dart        # PrevisaoSemanaScreen
    detalhes_avancados.dart     # DetalhesAvancadosScreen
  widgets/
    titulo_secao.dart           # TituloSecao (título de seção reutilizado)
```

## Atividade de pesquisa: novos widgets

Widgets pesquisados na documentação oficial e usados na tela **Detalhes avançados**:

| Widget | Para que serve (com minhas palavras) | 2 propriedades usadas e o que fazem | Link da documentação |
| --- | --- | --- | --- |
| `Card` | É uma "caixinha" com cantos arredondados e sombra, usada para agrupar um conteúdo e destacá-lo do fundo. | `child`: recebe o widget que fica dentro do card. `elevation`: controla a altura da sombra (quanto maior, mais "flutuando" o card parece). | https://api.flutter.dev/flutter/material/Card-class.html |
| `ListTile` | É a linha padrão de lista: já vem com espaços prontos para um elemento à esquerda, o texto no meio e um elemento à direita. | `leading`: widget colocado no início da linha (usei um `Icon`). `trailing`: widget colocado no fim da linha (usei `Icons.chevron_right`). O texto fica em `title` e `subtitle`. | https://api.flutter.dev/flutter/material/ListTile-class.html |
| `GridView.count` | Monta uma grade com um número fixo de colunas, distribuindo os filhos em linhas e colunas. | `crossAxisCount`: quantas colunas a grade tem (usei 2). `shrinkWrap`: faz o grid ocupar apenas a altura do conteúdo, em vez de tentar rolar sozinho. Também usei `physics: NeverScrollableScrollPhysics()` para o grid não competir com o scroll do `ListView`. | https://api.flutter.dev/flutter/widgets/GridView/GridView.count.html |
| `Stack` | Sobrepõe os filhos na mesma área, um em cima do outro, como camadas. O tamanho é definido pelos filhos que não são `Positioned`. | `children`: a lista de camadas, desenhadas na ordem (a última fica por cima). `alignment`: ancora os filhos que **não** são `Positioned` (no código ficou no padrão, `Alignment.topStart`). | https://api.flutter.dev/flutter/widgets/Stack-class.html |
| `Positioned` | Só funciona dentro de um `Stack`: tira o filho do fluxo e o coloca a uma distância das bordas do Stack. | `bottom` e `left`: distância do filho até a borda inferior e a esquerda (usei para o "26°C"). `top` e `right`: mesma ideia para as bordas superior e direita (usei no ícone do sol). | https://api.flutter.dev/flutter/widgets/Positioned-class.html |
| `Wrap` | Organiza os filhos em sequência, mas, quando não cabe mais na linha, joga o próximo para a linha de baixo (diferente da `Row`, que estoura). | `spacing`: espaço horizontal entre os filhos. `runSpacing`: espaço vertical entre uma linha e a de baixo. | https://api.flutter.dev/flutter/widgets/Wrap-class.html |
| `Chip` | É uma etiqueta compacta com texto, usada para tags, filtros e categorias. | `label`: o widget de texto/conteúdo do chip. `avatar`: widget pequeno à esquerda do label (usei `Icon` em 2 dos chips). | https://api.flutter.dev/flutter/material/Chip-class.html |

### Row/Column x Stack

`Row` e `Column` distribuem os filhos **em sequência**, um ao lado do outro ou um embaixo
do outro, e o tamanho do conjunto vem da soma desse fluxo. O `Stack` coloca os filhos
**na mesma área**, sobrepostos em camadas (o último desenhado fica por cima) e precisa de
um filho que defina o tamanho ou de `Positioned` para posicioná-los. Use `Row`/`Column`
para listas, formulários e barras de itens; use `Stack` quando precisar escrever algo em
cima de outro elemento, como texto sobre uma foto ou um selo sobre um card.

## Expanded x Flexible

Os dois widgets são usados dentro de `Row` ou `Column` para dividir o espaço que
sobra depois que os filhos "fixos" já ocuparam o que precisavam. A diferença está
em quanto de espaço o filho é obrigado a ocupar:

- **Expanded** é um `Flexible` com `fit: FlexFit.tight`. O filho é **obrigado** a
  ocupar exatamente todo o espaço que o `flex` dele reservou. Se sobrar espaço na
  linha/coluna, ele estica; não tem como ficar menor.
- **Flexible** usa `fit: FlexFit.loose` por padrão. O filho é **limitado** ao
  espaço reservado pelo `flex`, mas pode ocupar menos que isso — o tamanho máximo
  é aquele espaço, e o widget decide se usa tudo ou só o quanto precisa.

Exemplo: numa `Row` com `Expanded` (flex 1) + `Flexible(flex: 2)`, o segundo recebe
até dois terços do espaço livre, mas pode ficar menor que isso se o conteúdo dele
for pequeno.

## E quando os `flex` são diferentes?

O espaço livre é dividido em partes proporcionais ao valor de `flex`. Somando todos
os `flex` da `Row`/`Column`, cada filho recebe `flex do filho / soma dos flex`.

- Todos com flex 1 → divisão igual (metade, um terço, etc.).
- `Expanded` (flex 1) + `Flexible(flex: 2)` → o primeiro fica com 1/3 e o segundo
  com 2/3 do espaço livre.

Ou seja: quanto maior o `flex`, maior a fatia do espaço. E como `Expanded` força o
preenchimento total enquanto `Flexible` só limita o máximo, dois filhos podem ter
`flex` diferentes mas terminar com tamanhos parecidos se o conteúdo do `Flexible`
for pequeno.

## Como rodar

```bash
flutter pub get
flutter run
```
