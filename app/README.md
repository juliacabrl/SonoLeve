# SonoLeve — aplicativo (Flutter)

Protótipo de **baixa fidelidade funcional**: todas as telas e fluxos do SonoLeve
funcionando com **dados mockados**, já organizados na arquitetura final
(`docs/arquitetura.md`). A evolução para a alta fidelidade e o produto final
troca apenas a camada de dados — telas e controllers não mudam.

## Como rodar

Pré-requisito: Flutter 3.19 ou superior (`flutter --version`).

```bash
cd app

# 1ª vez: gera as pastas de plataforma (android/, ios/).
# Não sobrescreve lib/, test/ nem pubspec.yaml — arquivos existentes são mantidos.
flutter create . --project-name sonoleve --org br.edu.unit --platforms android,ios

flutter pub get
flutter analyze      # deve terminar sem erros
flutter test         # regras de negócio + fluxos principais
flutter run
```

Depois do `flutter create`, **commitem as pastas `android/` e `ios/`**: sem elas a
correção não consegue compilar o app.

**Conta de demonstração** (já preenchida no login): `jennifer@sonoleve.app` · `123456`.
Também é possível criar uma conta nova pela própria tela.

## O que dá para testar no protótipo

| Fluxo | Onde | Requisitos |
|---|---|---|
| Login, cadastro, erros de credencial e de conexão | Tela inicial | Auth, a.iv |
| Ritual noturno: marcar hábitos e ver o progresso | Hoje → Meu ritual | F01, RF01, RF02 |
| Sons do catálogo, player em loop e desligamento automático | Relaxar | F03, RF04, RF05 |
| Som novo publicado no catálogo: download e aviso offline | Relaxar → "Lareira acesa" | RN09, RNF04 |
| Respiração 4-7-8 guiada, com anéis animados | Hoje → Respirar / Relaxar | F02, RF03 |
| Diário: gráfico semanal, média e lista de noites | Diário | F04–F06, RF11 |
| CRUD de registros com validações (1–5 ★, 0–24 h, 1 por dia) | Diário → Registrar / tocar numa noite | RF06–RF10, RN01–RN04 |
| Preferências, sair e excluir meus dados | Hoje → ⚙ | RF13, RNF09 |
| **Simular modo offline** | Preferências | RNF04, a.iv |

## Estrutura (`lib/`)

```
lib/
├── main.dart                 # escolhe a fonte de dados (hoje: mock)
├── app.dart                  # Provider + MaterialApp (tema, pt-BR, rotas)
├── core/
│   ├── tema/                 # tokens do Figma: cores, tipografia, dimensões, tema
│   ├── rotas/                # nomes das rotas e abas
│   └── utils/                # datas e formatação em português
├── dominio/                  # 🟩 sem dependência de Firebase
│   ├── modelos/              # Usuario, RegistroSono, ChecklistDiario, Som, ...
│   ├── repositorios/         # contratos (interfaces) da camada de dados
│   ├── servicos/             # Conectividade
│   └── erros.dart            # falhas com mensagens prontas para o usuário
├── dados/
│   └── mock/                 # 🟥 implementações em memória + dados de exemplo
├── injecao/dependencias.dart # ÚNICO ponto que liga contratos a implementações
├── estado/                   # 🟨 controllers (ChangeNotifier + Provider)
└── apresentacao/             # 🟦 UI
    ├── componentes/          # design system (botões, cartões, anéis, gráfico...)
    ├── telas/                # login, hoje, ritual, relaxar, player, respiração,
    │                         # diário, histórico, registrar, preferências
    └── rotas_app.dart        # geração das rotas (transição suave)
```

### Design system

Cores, fontes, tamanhos e raios foram extraídos de `prototype/figma/*.svg`:

- **Cores** (`core/tema/cores.dart`): fundo `#101827`, superfície `#1B2A41`, borda
  `#2B3B54`, texto `#EEF1F7` / `#AEB8C8`, primária `#7C8DB5`, lavanda `#A9A4C9`,
  sálvia `#86A99A` (concluído/offline), âmbar `#D7A17B` (dicas e erros — sem vermelho
  à noite).
- **Fonte**: Manrope 400/500/600/700, **embarcada** em `assets/fonts/` (funciona
  offline; licença OFL incluída).
- **Componentes** (`apresentacao/componentes/`): cada elemento visual repetido nas
  telas do Figma virou um widget reutilizável. Para a alta fidelidade, ajustes visuais
  são feitos ali e se propagam para todas as telas.

## Da baixa para a alta fidelidade / produto final

1. **Visual**: refinar os componentes e os tokens de `core/tema` (animações, ícones
   próprios, tema diurno do RF13).
2. **Dados reais**: criar `lib/dados/firebase/` com uma implementação para cada
   contrato de `dominio/repositorios/repositorios.dart`:

   | Contrato | Implementação real |
   |---|---|
   | `AuthRepository` | `firebase_auth` (e-mail e senha) |
   | `RegistroSonoRepository` | `cloud_firestore` — `usuarios/{uid}/registrosSono` |
   | `ConteudoRepository` | `cloud_firestore` (`conteudo_*`, `config/catalogo`) + `firebase_storage` + `path_provider` |
   | `ChecklistRepository` | `shared_preferences` |
   | `PreferenciasRepository` | `cloud_firestore` — mapa `preferencias` em `usuarios/{uid}` |
   | `Conectividade` | `connectivity_plus` |

3. Criar `Dependencias.firebase()` em `injecao/dependencias.dart` e trocar a chamada
   em `main.dart`. Os modelos já têm `toMap()`/`fromMap()` compatíveis com o Firestore
   (aceitam `Timestamp`), conforme `docs/modelagem-banco-dados.md`.
4. **Áudio**: o `PlayerController` hoje simula a reprodução; basta delegar ao
   `just_audio`, usando `Som.caminhoLocal`.

## Diferenças em relação ao Figma

- **Login/cadastro e histórico** não existem no Figma. Foram criados com os mesmos
  componentes, porque a autenticação é obrigatória e o RF08 pede o histórico.
- **Textos de privacidade ajustados.** O Figma diz "Seus registros ficam neste
  dispositivo" e "Sem conta". Com o Firebase Auth e o Firestore, isso não é mais
  verdade, então os textos passaram a ser "Seus registros ficam protegidos na sua
  conta" e "Sem microfone ou sensores".
- **Preferências** ganharam "Sair da conta", "Excluir meus dados" (RNF09) e, só no
  protótipo, "Simular modo offline".
