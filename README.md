# Eodirok 어디록 - 협업 중간 산출물 자동 아카이빙 프로그램
<p align="center"><img width="400" alt="ㄴㅇㄹ자산 3@2x" src="https://github.com/user-attachments/assets/eeee66a8-b436-453d-8749-d852a2500df3" /></p>

 <p align="center">${\textsf{\color{#31937B}어디록(Eodirok)}}$은 회사 메신저 등 단체 메신저 내용(txt 형식)을 입력받으면 업무 내용, 업무 카테고리, 날짜 등을 테이블 형태로 저장해주는 협업 중간 산출물 자동 아카이빙 프로그램입니다.</p>

 
## 문제 설정
- 프로젝트 마감일이 다가올 수록 중간 산출물을 아카이빙할 시간이 부족해 메신저 기록을 검색해야 하는 불편함과 협업 정보의 체계적 관리 부족 <br/>
=> 팀즈 대화 내용을 txt 형식으로 입력받으면, 업무 기록을 요약해서 저장해주는 '어디록'



## 🔧주요 기능

### (1) 팀즈 대화 기록 저장

- 사용자로부터 프로젝트 이름과 프로젝트 단체 메신저 내용을 입력받으면 그 내용을 DB에 저장한다.
- 이때 DB내에 프로젝트마다 테이블을 생성한다
    - (EX: 프로젝트1 테이블, 프로젝트2 테이블, …)
    - 테이블은 사용자가 새로 입력할 때마다 업데이트 된다.

### (2) 팀즈 대화 기록 아카이빙

- DB에 저장된 대화 기록을 바탕으로, 업무 내용을 요약한 테이블을 생성한다.
    - 이때 토픽 모델링 or Text Classification 등을 통해 업무 카테고리 지정
    - 이 내용은 (1)에서 기록한 테이블과 다른 테이블에 저장된다
 
### (3) 요약 결과 CSV 저장
- 업무 내용을 요약한 결과를 csv 파일로 저장할 수 있다.

## 🖼️ Architecture
![image](https://github.com/user-attachments/assets/fb87357a-122d-4bdf-aeaa-86ce77a08b50)

## 🧰 기술 스택
### Client
<img src="https://img.shields.io/badge/flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white">

### Server
<img src="https://img.shields.io/badge/nginx-009639?style=for-the-badge&logo=nginx&logoColor=white"> <img src="https://img.shields.io/badge/ginuciorn-499848?style=for-the-badge&logo=gunicorn&logoColor=white"> <img src="https://img.shields.io/badge/flask-000000?style=for-the-badge&logo=flask&logoColor=white">



### DB & Microservices & Cloud Service
<img src="https://img.shields.io/badge/postgres-4169E1?style=for-the-badge&logo=postgresql&logoColor=white"> <img src="https://img.shields.io/badge/docker-2496ED?style=for-the-badge&logo=docker&logoColor=white"> <img src="https://img.shields.io/badge/gcp-4285F4?style=for-the-badge&logo=googlecloud&logoColor=white">


