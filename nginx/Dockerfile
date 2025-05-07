FROM nginx:latest

# nginxuser を作成
RUN adduser --system --uid 1000 --no-create-home --disabled-login --group nginxuser

# nginxuser に最高権限を与える
# RUN mkdir -p /var/cache/nginx /var/log/nginx /etc/nginx /var/run /var/cache/nginx/client_temp /var/cache/nginx/proxy_temp /var/cache/nginx/fastcgi_temp /var/cache/nginx/uwsgi_temp \
#     && chown -R nginxuser:nginxuser /var/cache/nginx /var/log/nginx /etc/nginx /var/run /var/cache/nginx/client_temp /var/cache/nginx/proxy_temp /var/cache/nginx/fastcgi_temp /var/cache/nginx/uwsgi_temp \
#     && chmod -R 755 /var/cache/nginx /var/log/nginx /etc/nginx /var/run /var/cache/nginx/client_temp


# ユーザーを nginxuser に設定して作業
# USER nginxuser

# 処理が終わった後に権限を戻す
# USER root
# RUN chmod -R 755 /var/cache/nginx /var/log/nginx /etc/nginx /var/run /var/cache/nginx/client_temp \
#     && chown -R root:root /var/cache/nginx /var/log/nginx /etc/nginx /var/run /var/cache/nginx/client_temp

# # 最終的に再度 nginxuser に戻して実行
# USER nginxuser

EXPOSE 8080

ENTRYPOINT ["nginx", "-g", "daemon off;"]
