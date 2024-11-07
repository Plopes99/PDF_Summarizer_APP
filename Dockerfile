FROM python:3.9-slim

# Instala as dependências do sistema
RUN apt-get update && apt-get install -y \
    default-jre \
    ghostscript \
    poppler-utils \
    && apt-get clean

# Define o diretório de trabalho
WORKDIR /app

# Copia o arquivo requirements.txt e instala as dependências do Python
COPY backend/requirements.txt requirements.txt
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

# Copia o restante do código da aplicação
COPY /backend .

# Comando para iniciar a aplicação
CMD ["python", "app.py"]
