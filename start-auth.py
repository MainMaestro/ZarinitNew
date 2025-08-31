#!/usr/bin/env python3
"""
Скрипт запуска для cloud-auth с поддержкой переменных окружения
"""
import os
import sys
import time

# Добавляем путь к cloud-auth в PYTHONPATH
sys.path.insert(0, '/cloud-auth')

# Ждем, пока база данных станет доступной
def wait_for_db():
    import psycopg2
    max_retries = 30
    retry_count = 0
    
    # Формируем параметры подключения
    db_host = 'auth-db'  # Имя сервиса в Docker Compose
    db_port = 5432
    db_name = os.getenv('POSTGRES_DB', 'adminka')
    db_user = os.getenv('POSTGRES_USER', 'postgres')
    db_password = os.getenv('POSTGRES_PASSWORD', '1')
    
    while retry_count < max_retries:
        try:
            # Пытаемся подключиться к базе данных
            conn = psycopg2.connect(
                host=db_host,
                port=db_port,
                database=db_name,
                user=db_user,
                password=db_password
            )
            conn.close()
            print("База данных доступна!")
            return True
        except psycopg2.OperationalError as e:
            retry_count += 1
            print(f"Ожидание базы данных... попытка {retry_count}/{max_retries}: {e}")
            time.sleep(2)
    
    print("Не удалось подключиться к базе данных")
    return False

# Ждём базу
if not wait_for_db():
    sys.exit(1)

# Сформируем итоговый URI (если не пришёл извне)
db_host = 'auth-db'
db_port = '5432'
db_name = os.getenv('POSTGRES_DB', 'adminka')
db_user = os.getenv('POSTGRES_USER', 'postgres')
db_password = os.getenv('POSTGRES_PASSWORD', '1')

effective_db_url = os.getenv('DATABASE_URL') or f'postgresql+psycopg2://{db_user}:{db_password}@{db_host}:{db_port}/{db_name}'

# Проставим переменные окружения ДО импорта приложения
os.environ['DATABASE_URL'] = effective_db_url
os.environ['SQLALCHEMY_DATABASE_URI'] = effective_db_url
print(f"[*] Using DATABASE_URL: {effective_db_url}", flush=True)

# Дальше без изменений:
os.chdir('/cloud-auth')
try:
    import flask
except ImportError:
    os.system('pip install -r requirements.txt')

from app import app, db
from app import *

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
        ROOT_USER_EMAIL = os.environ.get('ROOT_USER_EMAIL', 'root@admin.com')
        if not User.query.filter_by(email=ROOT_USER_EMAIL).first():
            from app import create_admin
            create_admin()
    APP_DEBUG = os.environ.get('FLASK_ENV') == 'development'
    app.run(debug=APP_DEBUG, host='0.0.0.0', port=5001)