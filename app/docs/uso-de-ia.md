# Registro de uso de IA — versão de teste

## Pedidos usados nesta etapa

- “Faça uma análise desse conteúdo e dos requisitos”. A análise confrontou
  o enunciado, os requisitos, os protótipos exportados e a branch principal.
- “Com base em tudo que foi feito e dito. usando o flutter, dart e firebase.
  Crie o uma versão simples, sem muita firula no código - irei querer ele
  documentado, para testar os requisitos princiapais.” O pedido orientou o
  reaproveitamento das telas e a implementação de uma versão testável.

## Problemas identificados e ajustes

- O ponto de entrada usava apenas repositórios simulados. Foi ligado a
  Firebase Auth e Firestore, mantendo os mocks disponíveis nos testes.
- O player alterava o texto para “Tocando” sem emitir som. Foram acrescentados
  MP3 embarcados e reprodução pelo `just_audio`.
- O tema era fixo. O tema da interface passou a ler as preferências e a hora.
- Na primeira implementação do armazenamento local, checklist e preferências
  tinham métodos com o mesmo nome e assinaturas incompatíveis. A implementação
  foi corrigida em duas classes que usam a mesma instância de armazenamento.

## Bibliotecas escolhidas

| Biblioteca | Motivo |
|---|---|
| `firebase_core` | Inicializa o projeto Firebase selecionado. |
| `firebase_auth` | Faz login e cadastro por e-mail e senha. |
| `cloud_firestore` | Salva as noites do usuário e oferece transações. |
| `shared_preferences` | Guarda as marcações e configurações de interface no aparelho. |
| `connectivity_plus` | Indica quando o aparelho fica sem interface de rede. |
| `just_audio` | Reproduz os MP3 locais em loop, com pausa e ajuste de volume. |
| `provider` | Mantém o gerenciamento de estado que o aplicativo já usava. |

Este registro cobre a interação que gerou a versão de teste. O histórico de
uso de IA anterior deve ser complementado pelos integrantes que o realizaram.
