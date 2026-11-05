# Diagrama de Casos de Uso — SonoLeve

> Unidade II — Diagrama de Casos de Uso atualizado com as novas regras de
> negócio. Representa as interações entre o usuário e o sistema, considerando a
> autenticação e a persistência no Firebase.

**Ator principal:** Usuário (persona Jennifer Lopes).
**Ator secundário:** Firebase (Authentication + Cloud Firestore), que apoia os casos de uso
de autenticação e de persistência de dados.

---

## 1. Diagrama

```mermaid
flowchart LR
    U(["👤 Usuário"])
    FB(["☁️ Firebase<br/>Auth + Firestore"])

    subgraph SIS["🟦 Sistema SonoLeve"]
        direction TB

        subgraph ACESSO["Acesso"]
            UC1(["Cadastrar-se"])
            UC2(["Autenticar-se (login)"])
        end

        subgraph RITUAL["Ritual noturno"]
            UC3(["Visualizar checklist"])
            UC4(["Marcar / desmarcar hábito"])
        end

        subgraph RELAX["Relaxamento (offline)"]
            UC5(["Reproduzir som de relaxamento"])
            UC6(["Iniciar / parar som"])
            UC7(["Fazer respiração 4-7-8"])
        end

        subgraph DIARIO["Diário do sono (CRUD)"]
            UC8(["Registrar sono"])
            UC9(["Informar horas dormidas"])
            UC10(["Avaliar qualidade (1-5)"])
            UC11(["Consultar histórico"])
            UC12(["Editar registro"])
            UC13(["Excluir registro"])
            UC14(["Ver gráfico semanal"])
        end

        subgraph APOIO["Apoio e privacidade"]
            UC15(["Ver dicas de higiene do sono"])
            UC16(["Ajustar preferências / tema"])
            UC17(["Excluir meus dados (LGPD)"])
        end
    end

    U --- UC1 & UC2
    U --- UC3 & UC4
    U --- UC5 & UC7
    U --- UC8 & UC11 & UC12 & UC13 & UC14
    U --- UC15 & UC16 & UC17

    UC1 -. include .-> FB
    UC2 -. include .-> FB
    UC8 -. include .-> UC9
    UC8 -. include .-> UC10
    UC5 -. extend .-> UC6
    UC8 -. include .-> FB
    UC11 -. include .-> FB
    UC17 -. include .-> FB
```

> Legenda: linhas sólidas = associação ator↔caso de uso; `include` = o caso de uso sempre
> aciona o outro; `extend` = comportamento opcional/condicional.

---

## 2. Rastreabilidade (caso de uso → requisito)

| # | Caso de uso | Requisitos / Funcionalidades |
|---|---|---|
| UC1 | Cadastrar-se | Autenticação (Firebase Auth) |
| UC2 | Autenticar-se (login) | Autenticação (Firebase Auth) |
| UC3 | Visualizar checklist | F01, RF01 |
| UC4 | Marcar / desmarcar hábito | F01, RF02 |
| UC5 | Reproduzir som de relaxamento | F03, RF04, RNF04 |
| UC6 | Iniciar / parar som | RF05 |
| UC7 | Fazer respiração 4-7-8 | F02, RF03, RNF04 |
| UC8 | Registrar sono | F04, RF06, RF07 |
| UC9 | Informar horas dormidas | RF06 |
| UC10 | Avaliar qualidade (1-5) | RF07 |
| UC11 | Consultar histórico | F05, RF08 |
| UC12 | Editar registro | RF09 |
| UC13 | Excluir registro | RF10 |
| UC14 | Ver gráfico semanal | F06, RF11 |
| UC15 | Ver dicas de higiene do sono | F07, RF12 |
| UC16 | Ajustar preferências / tema | F08, RF13, RNF03 |
| UC17 | Excluir meus dados (LGPD) | RNF08, RNF09 |

---

## 3. Especificação dos casos de uso centrais

### UC2 — Autenticar-se (login)
- **Ator:** Usuário · **Pré-condição:** possuir conta.
- **Fluxo principal:** informar e-mail e senha → sistema valida no Firebase Auth → acessa a
  tela Hoje.
- **Fluxos de exceção:** credenciais inválidas ou sem conexão → exibir mensagem clara e
  permanecer na tela de login.

### UC8 — Registrar sono *(include UC9, UC10)*
- **Ator:** Usuário · **Pré-condição:** estar autenticado.
- **Fluxo principal:** abrir "Novo registro" → **informar horas dormidas (UC9)** → **avaliar
  qualidade de 1 a 5 (UC10)** → (observação opcional) → salvar.
- **Regras de negócio:** horas entre 0 e 24 (RN02); qualidade inteira de 1 a 5 (RN01); no
  máximo um registro por dia (RN03).
- **Fluxo de exceção:** dados inválidos → destacar o campo e bloquear o salvamento.

### UC13 — Excluir registro
- **Ator:** Usuário · **Pré-condição:** existir o registro.
- **Fluxo principal:** abrir o registro → excluir → confirmar → sistema remove do Firestore.

### UC17 — Excluir meus dados (LGPD)
- **Ator:** Usuário · **Pré-condição:** estar autenticado.
- **Fluxo principal:** Configurações → "Excluir meus dados" → confirmar → sistema apaga toda
  a árvore `usuarios/{uid}` (RNF09).

---

### Documentos relacionados
- `modelo-dominio.md` — entidades que suportam os casos de uso
- `modelagem-banco-dados.md` — regras de negócio (RN01–RN07) e persistência
- `fluxos-navegacao.md` — como os casos de uso se traduzem em navegação entre telas
