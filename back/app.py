from flask import Flask, request, jsonify
import ydb
import os
from dotenv import load_dotenv
import uuid
import socket
from flask_cors import CORS

load_dotenv()
TABLE_NAME = 'notes'
driver = ydb.Driver(endpoint=os.getenv("YDB_ENDPOINT"), database=os.getenv("YDB_DATABASE"))
driver.wait(fail_fast=True, timeout=5)
pool = ydb.SessionPool(driver)


def get_notes():
    def callee(session):
        notes = []
        result = session.transaction().execute(f'SELECT name, content FROM  {TABLE_NAME}')
        for row in result[0].rows:
            notes.append({
                'name': row.name.decode(),
                'content': row.content.decode()
            })
        
        return notes
    
    return pool.retry_operation_sync(callee)

def create_note(name, content):
    def callee(session):
        id = uuid.uuid4()
        session \
            .transaction() \
            .execute(
                f"INSERT INTO {TABLE_NAME} (id, name, content) VALUES ('{id}', '{name}', '{content}')",
                commit_tx=True
            )
        
        return {
            'id': id,
            'name': name,
            'content': content
        }
    return pool.retry_operation_sync(callee)
    

app = Flask(__name__)

CORS(app)

@app.route("/v", methods=['GET'])
def info():
    hostname = socket.gethostname()
    version = '0.0.0'

    with open('version.txt', 'r') as version_file:
        version = version_file.read().split("=")[1]
    
    return {
        'name': hostname,
        'version': version
    }

@app.route("/notes", methods=['GET', 'POST'])
def handle_notes_queries():
    if request.method == 'GET':
        return get_notes()
    
    json_data = request.get_json()
    created_note = create_note(json_data['name'], json_data['content'])
    
    return created_note


if __name__ == "__main__":
    port = int(os.environ.get('APP_PORT', 5000))
    app.run(debug=True, host='0.0.0.0', port=port)