# Python 베이스 이미지 선택
FROM python:3.9

# 필요한 패키지 설치
RUN apt-get update && apt-get install -y \
    libpq-dev gcc 

RUN apt install -y openjdk-17-jdk


# 환경 변수 설정 (Java 경로 설정)
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"

# 작업 디렉토리 설정
WORKDIR /app

# 의존성 복사 및 설치
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install gunicorn

# 애플리케이션 코드 복사
COPY server /app/server

# Gunicorn으로 앱 실행
CMD ["gunicorn", "-w", "4", "-k", "sync", "-b", "0.0.0.0:5000", "server.app:app"]
