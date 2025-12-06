Video apresentação - https://youtu.be/TH23yrfM5YQ

🚀 EML Processor: Processamento de E-mails (Teste C2S)
Este projeto é a solução para o Teste Técnico de Desenvolvedor Ruby on Rails (Pleno), focado no desenvolvimento de uma aplicação que processa arquivos .eml (e-mails), extrai dados estruturados e os armazena no banco de dados.

A aplicação utiliza uma Arquitetura Limpa baseada no Padrão Strategy para o processamento, garantindo escalabilidade e facilidade na adição de novos parsers.

1. ⚙️ Requisitos de Tecnologia e Ambiente
O projeto é configurado para ser executado integralmente via VS Code Dev Containers, garantindo um ambiente de desenvolvimento e teste consistente.

Linguagem/Framework: Ruby 3.4.7 + Rails 8.1.1

Banco de Dados: PostgreSQL (via Docker)

Background Jobs: Sidekiq + Redis (via Docker)

Ambiente: Docker e Docker Compose (orquestrados pelo Dev Container)

2. 🏁 Guia de Instalação, Execução e Testes
O ambiente de trabalho é totalmente isolado. Siga os passos exatos para clonar o repositório e iniciar a aplicação.

2.1. Clonagem e Abertura
Clone o Repositório: Use o comando git clone para obter o código.

Bash

git clone git@github.com:oAddson/eml_processor.git
cd eml_processor
Abra o Projeto no VS Code:

Bash

code .
Abra na Dev Container: Quando o VS Code abrir, ele deverá perguntar se deseja reabrir o projeto no contêiner. Clique em "Reopen in Container".

2.2. Setup Inicial (Se necessário)
Se o contêiner não iniciar corretamente ou for a primeira vez, force a reconstrução para garantir que todas as dependências estejam instaladas.

Pressione Ctrl + P (ou Cmd + P no Mac).

Digite >devcontainer e selecione a opção:

> Dev Containers: Reopen and Rebuild
Execute o setup do banco de dados no Terminal do VS Code (o postCreateCommand já pode ter executado bundle install e db:migrate, mas é importante garantir a criação do DB de teste):

Bash

# (Dentro do terminal do contêiner)
bin/rails db:create db:migrate
2.3. Iniciar Servidores (Execução)
Abra dois novos terminais dentro do VS Code Dev Container para iniciar os processos.

🔸 Terminal 1: Servidor Rails (Interface Web)
Bash

bin/rails server -b 0.0.0.0
Acesse o sistema no seu navegador: http://localhost:3000

🔸 Terminal 2: Sidekiq Worker (Processamento em Background)
Bash

sidekiq -C config/sidekiq.yml
(Este worker irá processar a fila default (Extração de E-mails) e low_priority (Limpeza de Logs))

2.4. Execução dos Testes (Verificação)
Para validar a lógica e arquitetura do projeto (incluindo Service Objects e Parsers), utilize os seguintes comandos no terminal do contêiner:

Prepare o Banco de Dados de Teste:

Bash

bin/rails db:test:prepare
Execute os Specs:

Bash

rspec spec