FROM nginx:latest

# nginxuser を作成
RUN adduser --system --uid 1000 --no-create-home --disabled-login --group web

EXPOSE 8080

ENTRYPOINT ["nginx", "-g", "daemon off;"]
