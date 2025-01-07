from flask import Flask
from routes import model_summary_bp, db_select_bp

app = Flask(__name__)

app.register_blueprint(model_summary_bp, url_prefix='/api')  # URL Prefix 설정
app.register_blueprint(db_select_bp, url_prefix='/api')

if __name__ == '__main__':
    app.run(debug=True)