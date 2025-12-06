Video apresentação - https://youtu.be/TH23yrfM5YQ

# 🚀 EML Processor: Processamento de E-mails (Teste C2S)

Este projeto é a solução para o Teste Técnico de Desenvolvedor Ruby on Rails (Pleno), focado no desenvolvimento de uma aplicação que processa arquivos `.eml` (e-mails), extrai dados estruturados e os armazena no banco de dados.

A aplicação utiliza uma **Arquitetura Limpa** baseada no **Padrão Strategy** para o processamento, garantindo escalabilidade e facilidade na adição de novos parsers.

---

## 1. ⚙️ Requisitos de Tecnologia e Ambiente

O projeto é configurado para ser executado integralmente via **VS Code Dev Containers**, garantindo um ambiente de desenvolvimento e teste consistente.

**Tecnologias utilizadas:**

- **Linguagem/Framework:** Ruby 3.4.7 + Rails 8.1.1  
- **Banco de Dados:** PostgreSQL (via Docker)  
- **Background Jobs:** Sidekiq + Redis (via Docker)  
- **Armazenamento de Arquivos:** Active Storage  

---

## 2. 🏁 Guia de Instalação, Execução e Testes

O ambiente de trabalho é totalmente isolado.  
Siga os passos abaixo para clonar o repositório e iniciar a aplicação.

---

### 2.1. 🔽 Clonagem e Abertura

Clone o repositório:

```bash
git clone git@github.com:oAddson/eml_processor.git
cd eml_processor
````

Abra o projeto no VS Code:

```bash
code .
```

**Abra na Dev Container:**
Quando o VS Code abrir, ele perguntará se deseja reabrir o projeto no contêiner.
Clique em **Reopen in Container**.

Se necessário, force a reconstrução:

```
Dev Containers: Reopen and Rebuild
```

---

### 2.2. 🗄️ Setup Inicial (Criação do DB)

O Dev Container executa automaticamente `bundle install` e `db:migrate`, mas você pode rodar manualmente:

```bash
bin/rails db:create db:migrate
```

---

### 2.3. ▶️ Iniciar Servidores (Execução)

Abra **dois terminais** dentro do VS Code Dev Container.

---

#### 🔸 Terminal 1: Servidor Rails (Interface Web)

```bash
bin/rails server -b 0.0.0.0
```

Acesse no navegador:

**[http://localhost:3000](http://localhost:3000)**

---

#### 🔸 Terminal 2: Sidekiq Worker (Processamento em Background)

```bash
sidekiq -C config/sidekiq.yml
```

* Processa a fila **default** (Extração de E-mails)
* E a fila **low_priority** (Limpeza de Logs)

---

### 2.4. 🧪 Execução dos Testes (Verificação)

Prepare o banco de testes:

```bash
bin/rails db:test:prepare
```

Execute os testes:

```bash
rspec spec
```
