# SonoLeve — versão de teste

Aplicativo Android em Flutter e Dart para testar a rotina de sono. Para a
execução local, use o Firebase Emulator Suite: Auth e Firestore ficam em
processos no computador e não exigem uma conta Firebase na nuvem.

## Pré-requisitos

Instale ou confirme os seguintes itens:

| Recurso | Versão recomendada | Como verificar |
|---|---|---|
| Windows 10/11 | - | - |
| Flutter SDK | 3.38.9 | `flutter --version` |
| Dart | Incluído no Flutter; 3.10.8 no Flutter 3.38.9 | `dart --version` |
| Git | Qualquer versão atual | `git --version` |
| Android Studio | Versão atual | - |
| Android SDK Platform | 36 | SDK Manager do Android Studio |
| Android SDK Build-Tools | 35 e 36 | SDK Manager do Android Studio |
| Android NDK | 28.2.13676358 | SDK Manager do Android Studio |
| JDK | 21 | `java -version` |
| Node.js | 20 ou posterior | `node --version` |
| npm | Incluído no Node.js | `npm --version` |

No Android Studio, abra **SDK Manager → SDK Platforms** e instale **Android
15/16**, incluindo a Platform 36. Em **SDK Tools**, marque **Android SDK
Build-Tools**, **NDK (Side by side) 28.2.13676358** e **CMake**. Crie um
emulador em **Device Manager** com API 36 ou compatível. Para executar no
computador com o projeto atual, use Android em vez de Windows; o projeto não
foi configurado para o destino Windows.

Se o Dart do sistema estiver diferente do Dart instalado pelo Flutter, coloque
`C:\caminho\para\flutter\bin` antes dos demais diretórios do `PATH`. Não use um
Dart separado para os comandos deste projeto.

## Preparar o SDK do Flutter

Abra o terminal na pasta do SDK do Flutter e selecione exatamente a versão
recomendada pelo projeto:

```sh
cd C:\caminho\para\flutter
git fetch --tags
git switch --detach 3.38.9
flutter --version
flutter doctor -v
```

Os SDKs podem ser gerenciados por uma ferramenta como FVM, mas esta versão
funciona diretamente na pasta apontada por `flutter.sdk` em
`android/local.properties`. No Windows, se a pasta estiver em outro local,
atualize esse arquivo local ou execute a configuração do Flutter.

Confirme pelo menos estas partes de `flutter doctor -v`:

- **Flutter** está na versão 3.38.9.
- **Android toolchain** está disponível e tem licenças aceitas.
- Um emulador Android aparece em **Connected device**.
- Se o Visual Studio não estiver instalado, ele não impede o app Android.

```sh
flutter doctor --android-licenses
```

Aceite todas as licenças solicitadas.

## Preparar o projeto

Abra o terminal na pasta que contém `pubspec.yaml` e `firebase.json`, depois
execute:

```sh
flutter clean
flutter pub get
```

Não é necessário criar `firebase.local.json` ou alterar `google-services.json`
para o modo de emulador. O projeto já possui os arquivos Android necessários
para iniciar o Firebase com o modo local.

## Rodar no Android com Firebase Emulator Suite

1. Abra o emulador pelo Android Studio ou inicie um emulador instalado:

```sh
flutter emulators
flutter emulators --launch <nome_do_emulador>
```

2. Em um primeiro terminal, na pasta do projeto, inicie os emuladores:

```sh
npx firebase-tools@15.9.0 emulators:start --project demo-sonoleve --only auth,firestore
```

Mantenha esse terminal aberto enquanto usar o app.

3. Em outro terminal, na mesma pasta, confirme o dispositivo e execute:

```sh
flutter devices
flutter run -d emulator-5554 --dart-define=FIREBASE_EMULADOR=true
```

Substitua `emulator-5554` pelo identificador mostrado por `flutter devices`.
Também é possível omitir `-d` e selecionar o emulador quando houver vários
dispositivos:

```sh
flutter run --dart-define=FIREBASE_EMULADOR=true
```

O app usa `10.0.2.2` para acessar os serviços executados no computador. A
interface dos emuladores fica em <http://localhost:4000>. Na primeira execução,
abra **Criar uma conta**, use um e-mail fictício e uma senha de pelo menos seis
caracteres.

Os dados locais são descartados quando os emuladores são encerrados. Para
preservá-los entre reinícios, crie uma exportação inicial:

```sh
npx firebase-tools@15.9.0 emulators:export ./dados-emulador --project demo-sonoleve
```

Depois, inicie os emuladores usando essa pasta:

```sh
npx firebase-tools@15.9.0 emulators:start --project demo-sonoleve --only auth,firestore --import=./dados-emulador --export-on-exit
```

## Rodar sem emuladores locais

O Android físico ou o emulador também pode se conectar ao computador se o
emulador mudar a configuração `FIREBASE_HOST`. Esse modo serve apenas ao host
personalizado dos serviços locais:

```sh
flutter run --dart-define=FIREBASE_EMULADOR=true --dart-define=FIREBASE_HOST=IP_DO_COMPUTADOR
```

No emulador Android padrão, mantenha `10.0.2.2`.

## Usar o Firebase na nuvem

1. No [Console do Firebase](https://console.firebase.google.com/), registre um
   app Android com o pacote `br.edu.unit.sonoleve`. Ative **E-mail/senha** no
   Authentication e crie o banco padrão do Cloud Firestore.
2. Copie `firebase.local.example.json` para `firebase.local.json`. Use os
   quatro valores do `google-services.json` do **app Android** correspondente:

   | Campo do exemplo | Campo do arquivo baixado |
   |---|---|
   | `FIREBASE_API_KEY` | `client[].api_key[].current_key` |
   | `FIREBASE_APP_ID` | `client[].client_info.mobilesdk_app_id` |
   | `FIREBASE_SENDER_ID` | `project_info.project_number` |
   | `FIREBASE_PROJECT_ID` | `project_info.project_id` |

3. Aplique `firestore.rules` a um **projeto de teste**. Para um projeto que já
   hospeda outros dados, incorpore o bloco do diário às regras existentes.
   Em um projeto de teste dedicado, a CLI permite publicá-las com
   `npx firebase-tools@15.9.0 deploy --only firestore:rules --project SEU_ID`.
4. Execute `flutter run --dart-define-from-file=firebase.local.json`. O app
   lê as opções em Dart. O JSON de configuração local fica fora do Git.

## Roteiro de teste

| Requisito | Caminho | Resultado esperado |
|---|---|---|
| Login e cadastro | Crie uma conta, saia em **Preferências** e tente entrar com senha errada | Exibe uma mensagem. Com a senha correta, abre a aba **Hoje**. |
| RF01–RF02 · Checklist | **Hoje → Meu ritual**. Marque e desmarque itens. Feche e reabra o app no mesmo dia | O progresso acompanha as marcações e permanece gravado para a conta naquele dispositivo. |
| RF03 · Respiração | **Hoje → Respirar → Começar** | Alterna 4 s para inspirar, 7 s para segurar e 8 s para expirar. |
| RF04–RF05 · Sons | **Relaxar → Chuva suave → Tocar**. Pause ou troque de som | O áudio toca em loop e responde aos controles. Repita com a conexão desligada após o primeiro login. |
| RF06–RF07 · Criar noite | **Diário → Registrar minha noite**. Ajuste duração e estrelas, salve e reabra o app | O registro continua no diário. Uma segunda criação para a mesma data exibe um aviso. |
| RF08–RF10 · Histórico, edição e exclusão | **Diário → Ver histórico**. Abra um registro, edite e salve. Abra novamente e exclua | A lista mostra os dados atualizados. Após confirmar a exclusão, a noite sai do histórico. |
| RF11–RF12 · Gráfico e dicas | Registre datas diferentes nos últimos sete dias e volte ao **Diário** | O gráfico e a média refletem as noites registradas. A dica do dia aparece no diário. |
| RF13 · Paleta | Na engrenagem da home, escolha **Automática**. Compare com **Sempre noturna** durante o dia | Automática usa acentos quentes de dia e paleta azul no intervalo noturno configurado. |
| Isolamento | Saia, cadastre uma segunda conta e abra **Diário** | Os registros da primeira conta ficam fora da segunda conta. |

## Como o código funciona

- `lib/main.dart` inicializa o Firebase e abre a interface.
- `lib/injecao/dependencias.dart` conecta as telas às implementações reais.
  Os mocks servem aos testes automatizados existentes.
- `lib/dados/firebase/repositorios_firebase.dart` concentra login, cadastro e
  CRUD. O Firestore guarda as noites em
  `usuarios/{uid}/registrosSono/{AAAA-MM-DD}`. A data é texto de calendário,
  para manter o mesmo dia em fusos diferentes. Os demais horários são
  timestamps. Uma transação protege a criação duplicada e move o registro
  inteiro quando a data é editada.
- `lib/dados/local/repositorios_locais.dart` grava checklist e preferências
  no dispositivo, separados por conta. O catálogo e os três MP3 de teste
  são embarcados. Os MP3 foram sintetizados para o projeto.
- `firestore.rules` limita o acesso aos registros ao dono da conta e valida
  campos, duração, estrelas e tamanho da observação.

A versão requer conexão para o primeiro login e para salvar, editar ou excluir
noites. Uma sessão aberta pode acessar respiração, checklist e sons sem internet.
O diário pode consultar o cache disponível. Sons com tela bloqueada, exclusão
da conta, login social, sincronização do catálogo e personalização por histórico
ficam fora do escopo desta versão de teste. A exclusão de **cada registro** está
no próprio diário.

Para verificar o código localmente:

```sh
flutter analyze
flutter test
```

Na revisão desta versão, a análise estática passou sem avisos e os 20 testes
automatizados passaram. Uma verificação separada, pela API dos emuladores
Firebase, confirmou cadastro, login, CRUD e isolamento entre contas. A
execução da interface e do som no Android faz parte do roteiro manual acima.

O [registro de uso de IA](docs/uso-de-ia.md) descreve o apoio usado nesta versão.
