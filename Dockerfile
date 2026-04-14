FROM nginx:latest

# 로컬의 html 폴더 내용을 컨테이너 안으로 복사
COPY html /usr/share/nginx/html

# 80번 포트 개방
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
