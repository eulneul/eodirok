from flask import Blueprint

# 블루프린트 생성
model_summary_bp = Blueprint('model_summary', __name__)
db_select_bp = Blueprint('db_select', __name__)

# 각 모듈에서 라우트를 가져옴
from .model_summary import *
from .db_select import *