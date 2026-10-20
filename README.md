# Weather Preview

Aplicativo Flutter para consultar o clima de Santo André, SP, pela API Open-Meteo.

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
O horário exibido é o horário dos dados retornados para America/Sao_Paulo.
Em falhas de conexão, a última consulta permanece visível com aviso de dados
possivelmente desatualizados. Não há valores meteorológicos fictícios como fallback.

A localização continua fixa em Santo André (latitude -23.6639, longitude -46.5383),
definida em lib/weather_service.dart; não utiliza GPS nem pede permissão de localização.
A integração usa dart:io, direcionada ao app mobile/Android deste projeto, sem
dependências novas. Para Flutter Web seria necessário substituir o cliente HTTP.

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
Brasília; chuva, neve e nevoeiro seguem a condição meteorológica da API.
A animação respeita a configuração do sistema para reduzir animações.

Após adicionar o asset, execute `flutter pub get` e reinicie o app completamente;
apenas hot reload pode não incluir o arquivo novo no bundle.
