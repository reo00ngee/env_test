FROM nginx:latest

# nginxuser を作成
# RUN adduser --system --uid 1000 --no-create-home --disabled-login --group web
RUN adduser --uid 1000 --disabled-password --gecos '' web

# root で一時ディレクトリ作成 → 所有権を web に変更
RUN mkdir -p /var/cache/nginx/client_temp \
  && chown -R web:web /var/cache/nginx

# 最後にユーザーを切り替える
# USER web


EXPOSE 8080

ENTRYPOINT ["nginx", "-g", "daemon off;"]
