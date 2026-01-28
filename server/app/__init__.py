from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from flask_migrate import Migrate
import os

# Khởi tạo DB nhưng chưa kết nối
db = SQLAlchemy()
migrate = Migrate()

def create_app():
    app = Flask(__name__)
    
    # Cấu hình CORS (Cho phép Flutter gọi vào)
    CORS(app)

    # Cấu hình Database
    db_user = os.environ.get('MYSQL_USER', 'root')
    db_pass = os.environ.get('MYSQL_ROOT_PASSWORD', '123456')
    db_host = os.environ.get('MYSQL_HOST', 'db') # Tên service trong Docker
    db_name = os.environ.get('MYSQL_DATABASE', 'pharmacy_db')
    
    app.config['SQLALCHEMY_DATABASE_URI'] = f'mysql+mysqlconnector://{db_user}:{db_pass}@{db_host}/{db_name}'
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

    # Kết nối DB với App
    db.init_app(app)
    migrate.init_app(app, db)

    # Đăng ký các Route (API)
    from .routes import main
    app.register_blueprint(main)

    # Tự động tạo bảng nếu chưa có (Lệnh này chạy mỗi khi bật server)
    # with app.app_context():
    #    db.create_all()

    return app