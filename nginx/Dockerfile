FROM nginx:latest

# RUN apt-get update && apt-get install -y --no-install-recommends dumb-init

COPY ./default.conf /etc/nginx/nginx.conf

# RUN adduser --system --uid 1000 --no-create-home --disabled-login --group nginxuser

# RUN chown -R nginxuser:nginxuser /var/cache/nginx \
#     && chown -R nginxuser:nginxuser /var/log/nginx \
#     && chown -R nginxuser:nginxuser /etc/nginx/conf.d \
#     && touch /var/run/nginx.pid \
#     && chown -R nginxuser:nginxuser /var/run/nginx.pid

# USER nginxuser

EXPOSE 8080

ENTRYPOINT ["dumb-init", "nginx", "-g", "daemon off;"]