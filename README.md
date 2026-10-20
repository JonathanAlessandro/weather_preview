# Weather Preview

Aplicativo Flutter Android para consultar o clima da localização atual pela API Open-Meteo.

## Executar

Com Flutter instalado e um dispositivo Android conectado:

```sh
flutter pub get
flutter run
```

## Dados reais

Ao abrir o aplicativo, são consultadas temperatura, sensação térmica, umidade,
vento, condição meteorológica, mínima/máxima e chance máxima de chuva do dia.
O botão Atualizar e o gesto de puxar a tela para baixo fazem uma nova consulta.
O horário exibido e a iluminação do cenário seguem o fuso retornado pela previsão
para as coordenadas consultadas (timezone=auto).
Em falhas de conexão, a última consulta permanece visível com aviso de dados
possivelmente desatualizados. Não há valores meteorológicos fictícios como fallback.

## Localização do usuário (Android)

Ao abrir o aplicativo, o Android solicita acesso à localização durante o uso.
A localização aproximada também é aceita. A previsão usa as coordenadas obtidas;
o Geocoder do Android tenta identificar cidade e estado. Se o nome não estiver
disponível, a tela mostra as coordenadas e consulta o clima normalmente.

O botão **Usar minha localização** permite tentar novamente após ativar o GPS ou
liberar a permissão nas configurações do aplicativo. Atualizar e puxar a tela
consultam novamente a posição quando esse modo está ativo. Não há rastreamento
em segundo plano nem armazenamento do histórico de posições. O listener é
removido após obter a posição, após 20 segundos ou ao sair da tela do aplicativo.
A busca do nome do local tem espera máxima de 3 segundos.

Se o usuário negar acesso, desligar a localização ou ocorrer uma falha, a tela
avisa e mantém a cidade anterior; na primeira consulta, usa Santo André, SP.
Cidade e previsão só são trocadas juntas após uma consulta meteorológica bem-sucedida.
As coordenadas são enviadas à Open-Meteo para obter a previsão; o nome do local
é consultado pelo serviço Geocoder do Android e pode exigir internet.

A integração usa LocationManager e MethodChannel nativos, sem novas dependências
Flutter. Suporte de localização implementado para Android; não inclui iOS ou Web.
Após baixar a atualização, é necessário recompilar e reinstalar o aplicativo;
hot reload não atualiza o código Kotlin nem as permissões do manifesto.

Fonte: [Open-Meteo](https://open-meteo.com/), dados de modelos meteorológicos,
[CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).
O endpoint público não precisa de chave para uso não comercial. Para uso comercial,
consulte as condições e planos do fornecedor.

## Verificar

```sh
flutter analyze
flutter test
flutter build apk --debug
```

Os testes usam respostas simuladas para verificar parsing, atualização e falhas
de conexão sem depender da disponibilidade da API.

## Cenário animado

O ciclista agora é uma imagem PNG transparente com oito quadros em uma grade
4x2, em `assets/animations/cyclist-pedaling.png`. O Flutter exibe os quadros
em sequência a 8 fps, com um ciclo de pedalada por segundo. A imagem é local,
registrada no pubspec.yaml, e não depende de download durante o uso do app.
O cenário continua dinâmico por CustomPainter: cores de frio abaixo de 15°C
e calor a partir de 28°C, amanhecer, dia, entardecer e noite pelo horário de
local; chuva, neve e nevoeiro seguem a condição meteorológica da API.
A animação respeita a configuração do sistema para reduzir animações.

Após adicionar o asset, execute `flutter pub get` e reinicie o app completamente;
apenas hot reload pode não incluir o arquivo novo no bundle.

O cachorro Terra Nova usa oito sprites transparentes em
assets/animations/newfoundland-running.png, reproduzidos a 16 fps ao lado
do ciclista. Os dois assets são carregados separadamente e compartilham
o relógio de animação da cena; reduzir animações pausa ambos.

## Paisagem urbana

Todos os cenários são urbanos, desenhados em camadas por CustomPainter:
Centro (prédios e comércio), Bairro residencial (casas e árvores) e Avenida
arborizada (edifícios, lojas e vegetação). O seletor permite escolher uma
variação; no Automático, o bairro aparece antes das 7h e após as 17h,
o centro das 7h às 12h e a avenida das 12h às 17h.
A temperatura altera o tom do céu, sem trocar a cidade por praia ou floresta.

O relógio do fuso da previsão é atualizado a cada minuto, independentemente de uma
nova consulta à previsão. Amanhecer (5h–7h), dia (7h–17h), entardecer
(17h–19h) e noite (19h–5h) mudam a iluminação: céu e fachadas têm cores
interpoladas, janelas e postes se iluminam à noite. As faixas de horário
são ilustrativas; não calculam o nascer e o pôr do sol astronômicos.
Chuva, neve e nevoeiro continuam seguindo o código meteorológico da API.

Os fundos usam desenho vetorial local, dispensando o atlas anterior de
ambientes. Ciclista e cachorro mantêm seus sprites e a opção de reduzir
animações do sistema pausa o movimento, preservando a atualização do horário.
