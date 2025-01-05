from sklearn.feature_extraction.text import CountVectorizer
from sklearn.decomposition import LatentDirichletAllocation
from konlpy.tag import Okt
import re

with open('stop_word.txt', 'r', encoding='utf-8') as file:
    # 각 줄을 읽어서 줄바꿈 문자 제거 후 리스트에 저장
    stop_words = [line.strip() for line in file]

# 텍스트 전처리 함수
def preprocess_text(text):
    """
    1. 특수문자 제거
    2. 형태소 분석 및 명사 추출
    3. 불용어 제거
    """
    # 특수문자 제거
    text = re.sub(r'[^가-힣\s]', '', text)

    # 형태소 분석 (명사만 추출)
    okt = Okt()
    tokens = okt.nouns(text)

    # 불용어 제거
    tokens = [word for word in tokens if word not in stop_words]

    # 토큰을 공백으로 연결하여 반환
    return ' '.join(tokens)

# LDA 기반 주제 추출 함수
def extract_topic_lda(input_text, num_topics=1):
    # 입력 텍스트 전처리
    processed_text = preprocess_text(input_text)

    # 문서를 리스트 형태로 변환
    documents = [processed_text]

    # CountVectorizer로 텍스트 벡터화
    vectorizer = CountVectorizer(max_df=1.0, min_df=1, stop_words=None)
    dtm = vectorizer.fit_transform(documents)

    # LDA 모델 초기화
    lda = LatentDirichletAllocation(n_components=num_topics, random_state=0)
    lda.fit(dtm)

    # 주제 추출
    topics = []
    for idx, topic in enumerate(lda.components_):
        top_words = [vectorizer.get_feature_names_out()[i] for i in topic.argsort()[-5:]]
        topics.append("/".join(top_words))
    return topics

# 입력 예제
input_text = ""
topics = extract_topic_lda(input_text, num_topics=1)

print("출력:", topics)