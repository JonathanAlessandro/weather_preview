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
  widgets/
    titulo_secao.dart           # TituloSecao (título de seção reutilizado)
```

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
