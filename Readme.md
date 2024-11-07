# Instruções para Execução do Projeto

Este documento fornece um guia passo a passo sobre como configurar e executar este projeto em seu ambiente local.

## Pré-requisitos

Antes de iniciar, certifique-se de que você tem os seguintes pré-requisitos:
* Docker
* Flutter
  
## Pré-requisitos

- Docker
- Docker Compose
- Flutter

## Configuração e Execução

### Passo 1: Configurar Variáveis de Ambiente

Certifique-se de que você tenha a variável de ambiente `OPENAI_API_KEY` configurada com sua chave de API do OpenAI.

### Passo 2: Construir e Iniciar os Contêineres

No diretório raiz do projeto, execute os seguintes comandos:

1. **Construa os contêineres:**

```sh
docker-compose build
```

O backend Flask será inciado na porta 30000 com os seguitnes endpoints:

### POST /upload
Carrega um arquivo PDF e retorna um resumo do conteúdo.

+ **Request:** Multipart/form-data com o arquivo PDF.

+ **Response:** JSON com o file_id e summary.

### POST /questions
Recebe perguntas sobre um arquivo PDF previamente carregado e retorna as respostas.

+ **Request:** JSON com file_id e questions.
+ **Response:** JSON com file_id e details contendo as respostas.

### GET /download/jason/<file_id>
Baixa o arquivo PDF original carregado.

+ **Request:** Parâmetro file_id na URL.
+ **Response:** Arquivo JSON para download.


Para o frontend deve ser acedido o repostorio raiz e correr o comando:

```sh
flutter run
```


## Uso

### Carregar um PDF:
Clique no botão "Carregar PDF" e selecione um arquivo PDF o resumo do pdf deverá ser exibido.


### Adicionar Perguntas:
Adicine uma pergunta no campo de texto. Clique em "Adicionar Pergunta". As perguntas adicionadas serão exibidas abaixo.

### Fazer Perguntas
Após adicionar perguntas, clique no botão "Fazer Perguntas". As respostas serão exibidas abaixo das perguntas.

### Criar Novo Chat
Clique no ícone de chat no canto superior direito para limpar todos os campos e iniciar um novo chat.