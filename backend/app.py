from flask import Flask, request, jsonify, send_file
import os
from PyPDF2 import PdfReader
import tabula
from langchain.chains.summarize import load_summarize_chain
from langchain.chat_models import ChatOpenAI
from langchain.prompts import PromptTemplate
from langchain.docstore.document import Document
import json
import uuid

app = Flask(__name__)

OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
os.environ["OPENAI_API_KEY"] = OPENAI_API_KEY

# Armazenamento em memória para resumos de PDFs carregados
pdf_summaries = {}

def save_json(file_id, data):
    json_path = os.path.join('uploads', f'{file_id}.json')
    with open(json_path, 'w') as json_file:
        json.dump(data, json_file)
    return json_path

@app.route('/upload', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return "Ficheiro não encontrado", 400
    file = request.files['file']
    if file.filename == '':
        return "Nenhum ficheiro selecionado", 400
    if file:
        file_id = str(uuid.uuid4())
        file_path = os.path.join('uploads', file_id + '.pdf')
        file.save(file_path)
        summary = summarize_pdf(file_path)
        pdf_summaries[file_id] = {
            'file_path': file_path,
            'summary': summary,
            'questions': [],  # Inicializar a lista de perguntas
            'details': {}
        }
        save_json(file_id, pdf_summaries[file_id])
        return jsonify({'file_id': file_id, 'summary': summary})

@app.route('/questions', methods=['POST'])
def ask_questions():
    data = request.json
    file_id = data.get('file_id')
    questions = data.get('questions', [])
    
    if not file_id or file_id not in pdf_summaries:
        return jsonify({'error': 'ID de ficheiro inválido'}), 400

    file_info = pdf_summaries[file_id]
    file_path = file_info['file_path']
    detailed_info = answer_questions(file_path, questions)
    
    # Atualizar o dicionário com as perguntas e detalhes
    pdf_summaries[file_id]['questions'] = questions
    pdf_summaries[file_id]['details'] = detailed_info

    json_path = save_json(file_id, pdf_summaries[file_id])
    return jsonify({'file_id': file_id, 'details': detailed_info, 'json_path': json_path})

@app.route('/download/json/<file_id>', methods=['GET'])
def download_json(file_id):
    json_path = os.path.join('uploads', f'{file_id}.json')
    if os.path.exists(json_path):
        return send_file(json_path, as_attachment=True)
    else:
        return jsonify({'error': 'ID de ficheiro inválido'}), 400

def summarize_pdf(file_path):
    reader = PdfReader(file_path)
    raw_text = ''
    for page in reader.pages:
        text = page.extract_text()
        if text:
            raw_text += text
    
    # Extrair tabelas
    tables = tabula.read_pdf(file_path, pages='all', multiple_tables=True)
    table_texts = []
    for table in tables:
        table_texts.append(table.to_string())
    
    document = Document(page_content=raw_text + '\n' + '\n'.join(table_texts))
    
    prompt_template = PromptTemplate(
        input_variables=["text"],
        template="Escreva um resumo conciso do seguinte texto em português de Portugal:\n\n{text}\n\nRESUMO CONCISO:"
    )

    llm = ChatOpenAI(model_name="gpt-3.5-turbo-16k", temperature=0)
    chain = load_summarize_chain(llm, chain_type="stuff", prompt=prompt_template)
    
    summary = chain.run(input_documents=[document])
    return summary

def answer_questions(file_path, questions):
    reader = PdfReader(file_path)
    raw_text = ''
    for page in reader.pages:
        text = page.extract_text()
        if text:
            raw_text += text
    
    # Extrair tabelas
    tables = tabula.read_pdf(file_path, pages='all', multiple_tables=True)
    table_texts = []
    for table in tables:
        table_texts.append(table.to_string())

    combined_text = raw_text + '\n' + '\n'.join(table_texts)

    # Dividir o texto em partes menores
    max_chunk_size = 1000 
    chunks = [combined_text[i:i + max_chunk_size] for i in range(0, len(combined_text), max_chunk_size)]

    detailed_info = {}
    llm = ChatOpenAI(model_name="gpt-3.5-turbo-16k", temperature=0)
    
    for i, question in enumerate(questions):
        answers = []
        for chunk in chunks:
            prompt_template = PromptTemplate(
                input_variables=["text", "question"],
                template="Texto: {text}\n\nPergunta: {question}\n\nResponda à pergunta acima em português de Portugal:"
            )
            chain = load_summarize_chain(llm, chain_type="stuff", prompt=prompt_template)
            document = Document(page_content=chunk)
            answer = chain.run(input_documents=[document], question=question)
            answers.append(answer)
        
        # Concatenar todas as respostas para a pergunta em uma única resposta
        detailed_info[f'question_{i+1}'] = '\n'.join(answers)
    
    return detailed_info

if __name__ == '__main__':
    os.makedirs('uploads', exist_ok=True)
    app.run(host='0.0.0.0', port=3000)
