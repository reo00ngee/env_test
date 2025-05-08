FROM nginx:latest

# 非rootユーザー「web」を作成
RUN groupadd -r web && useradd -r -g web -m web

# NGINXの設定ファイルをコピー
COPY default.conf /etc/nginx/conf.d/default.conf

# 必要なディレクトリを作成（webユーザーに書き込み権限を付与）
RUN mkdir -p /tmp/client_temp /tmp/proxy_temp /tmp/fastcgi_temp /tmp/uwsgi_temp /tmp/scgi_temp \
    && mkdir -p /home/web/log /home/web/www \
    && chown -R web:web /tmp /home/web/log /home/web/www

# PIDファイルの場所を変更（webユーザー向け）
RUN sed -i 's|/var/run/nginx.pid|/tmp/nginx.pid|' /etc/nginx/nginx.conf

USER web

RUN mkdir -p /home/web/log && chown -R web:web /home/web/log


EXPOSE 8080

ENTRYPOINT ["nginx", "-g", "daemon off;"]
