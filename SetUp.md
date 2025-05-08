# Table of Contents

- [Table of Contents](#table-of-contents)
  - [1. Overview](#1-overview)
  - [2. Prerequisites](#2-prerequisites)
  - [3. Set up](#3-set-up)
    - [3-1. Install nginx and php-fpm](#3-1-install-nginx-and-php-fpm)
    - [3-2. Configure the container to run as the web user](#3-2-configure-the-container-to-run-as-the-web-user)
    - [3-3. Configure to output log files](#3-3-configure-to-output-log-files)
    - [3-4. Performance and security measures](#3-4-performance-and-security-measures)
      - [for performance](#for-performance)
      - [for security](#for-security)


## 1. Overview

This document outlines the steps to set up a Linux server environment using Docker for web development. The server includes Nginx and PHP-FPM, configured to run under a specific user with performance and security tuning.

## 2. Prerequisites

Docker installed on the host machine

## 3. Set up

### 3-1. Install nginx and php-fpm
Create yml, conf, and info.php files.  
Verify that the containers run properly.  
Confirm that the configured IP address works as expected.  

```
docker compose build
docker compose up -d
```
Note: The original IP address was already in use on my host machine, so I changed it to one that is available.  


- docker-compose.yml
```
services:
  web_server:
    image: nginx
    container_name: web-server
    networks:
      custom_network:
        ipv4_address: 172.20.0.10
    ports:
      - "8080:80"
    volumes:
      - ./www:/home/web/www
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./log:/home/web/log
    environment:
      - NGINX_USER=web

  php_fpm:
    image: php:7.4-fpm
    container_name: php-fpm
    networks:
      custom_network:
        ipv4_address: 172.20.0.11
    volumes:
      - ./www:/home/web/www
      - ./php-fpm.conf:/etc/php/7.4/fpm/pool.d/www.conf
      - ./log:/home/web/log
    environment:
      - PHP_FPM_USER=web
      - PHP_FPM_GROUP=web

networks:
  custom_network:
    ipam:
      config:
        - subnet: 172.20.0.0/16
```

- nginx.conf

```
# user web;
worker_processes 1;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
}

http {

    server {
        listen 80;
        server_name localhost;

        root /home/web/www;
        index index.php;

        location / {
            try_files $uri $uri/ =404;
        }

        location ~ \.php$ {
            fastcgi_pass php-fpm:9000;
            fastcgi_param SCRIPT_FILENAME /home/web/www$fastcgi_script_name;
            include fastcgi_params;
        }
    }
}
```

- php-fpm.conf

```
[www]
user = web
group = web
listen = 9000
listen.owner = web
listen.group = web
listen.mode = 0660
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
```

- www/info.php
```
<?php
phpinfo();
```

### 3-2. Configure the container to run as the web user
Check https://hub.docker.com/_/nginx to configure NGINX to run as a non-root user in a Docker environment.  
Configure PHP-FPM to run as a non-root user by modifying its configuration file.  
Due to the need for detailed configuration, NGINX and PHP-FPM are installed via Dockerfile, and the documentation structure is reorganized to manage configuration files more clearly.  

Confirm that the web user is created correctly.  
```
docker exec -it web-server bash
ls -ld /home/web

docker exec -it php-fpm bash
ls -ld /home/web
```

Confirm that the application operates under a non-root user. 

```
docker exec -it web-server whoami
docker exec -it php-fpm whoami
```

- Project structure
```
Project/
├── docker-compose.yml
├── nginx
│   └── default.conf
│   └── Dockerfile
├── php
│   └── php-fpm.d
│         └── www.conf
│   └── Dockerfile
│   └── php-fpm.conf
│   └── php-fpm.ini
├── www/
│   └── info.php
├── log/
```

- docker-compose.yml
```
services:
  web_server:
    build:
      context: ./nginx
      dockerfile: Dockerfile
  
  php_fpm:
    build:
      context: ./php
      dockerfile: Dockerfile

```

- php/Dockerfile
```
FROM php:8.0-fpm

# 必要なPHP拡張をインストール
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd \
    && apt-get clean

# webユーザーとグループを作成
RUN groupadd -g 1000 web && useradd -m -u 1000 -g web web


# 作業ディレクトリ
WORKDIR /var/www/html

# FPMの設定ファイルにwebユーザーを設定する（`www.conf` にも対応しておく）
RUN sed -i 's/^user = .*/user = web/' /usr/local/etc/php-fpm.d/www.conf && \
    sed -i 's/^group = .*/group = web/' /usr/local/etc/php-fpm.d/www.conf && \
    sed -i 's/^listen.owner = .*/listen.owner = web/' /usr/local/etc/php-fpm.d/www.conf && \
    sed -i 's/^listen.group = .*/listen.group = web/' /usr/local/etc/php-fpm.d/www.conf

# コンテナ内でwebユーザーとして実行する
USER web

# ログディレクトリ作成と所有権設定
RUN mkdir -p /home/web/log \
    && touch /home/web/log/php-error.log \
    && touch /home/web/log/php-slow.log \
    && chown -R web:web /home/web/log

# ポート9000を公開
EXPOSE 9000

# php-fpm を起動
CMD ["php-fpm"]

```

- php/php-fpm.d/www.conf
```
[www]

user = web
group = web

listen = 9000
listen.owner = web
listen.group = web
listen.mode = 0660

pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
```

- nginx/Dockerfile
```
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
```

- nginx/default.conf
```
# user web;
worker_processes 1;
pid        /tmp/nginx.pid;

events {
    worker_connections 1024;
}

http {
    access_log /home/web/log/nginx_access.log;
    error_log /home/web/log/nginx_error.log;

    
    # 一時ファイルのパスを変更（非rootユーザーに書き込み可能）
    client_body_temp_path /tmp/client_temp;
    proxy_temp_path /tmp/proxy_temp;
    fastcgi_temp_path /tmp/fastcgi_temp;
    uwsgi_temp_path /tmp/uwsgi_temp;
    scgi_temp_path /tmp/scgi_temp;

    server {
        listen 8080;
        server_name localhost;

        root /home/web/www;
        index index.php;

        location / {
            try_files $uri $uri/ =404;
        }

        location ~ \.php$ {
            fastcgi_pass php-fpm:9000;
            fastcgi_param SCRIPT_FILENAME /home/web/www$fastcgi_script_name;
            include fastcgi_params;
        }
    }
}
```

### 3-3. Configure to output log files
Configure to output log files with conf files.  
Note: Since mounting had to be disabled when installing NGINX from the Dockerfile in the Docker environment, it was necessary to check error messages from within the container using commands.

```
docker exec -it web-server bash
cat home/web/log/nginx_access.log 
cat home/web/log/nginx_error.log 

docker exec -it php-fpm bash
cat home/web/log/php-error.log
cat home/web/log/php-slow.log
```


- php/php.ini
```
[PHP]

; エラー表示設定（開発用）
display_errors = On
display_startup_errors = On
error_reporting = E_ALL
log_errors = On
error_log = /home/web/log/php-error.log

```

- php/php-fpm.conf
```
[global]
error_log = /home/web/log/fpm-error.log

include=/usr/local/etc/php-fpm.d/*.conf
```

- php/php-fpm.d/www.conf
```
php_admin_flag[log_errors] = on
php_admin_value[error_log] = /home/web/log/php-error.log
```

- nginx/default.conf
```
http {
    access_log /home/web/log/nginx_access.log;
    error_log /home/web/log/nginx_error.log;
}
```

- www/test-error.php(for log test)
```
<?php
// 未定義変数の使用（Warning 発生）
echo $undefined_variable;

// 明示的なエラー
trigger_error("手動エラー: テスト中", E_USER_ERROR);

```

### 3-4. Performance and security measures
Configure the conf file to enhance performance and implement security measures.  

#### for performance
- docker-compose.yml
```
    # add to each services
    deploy:
      resources:
        limits:
          cpus: "1.0"  # 最大 1 CPU
          memory: "512M"  # 最大 512MB メモリ
```

- nginx/default.conf
```
worker_processes auto; # 自動でCPU数を取得してプロセス数を決定

location ~* \.(jpg|jpeg|png|gif|ico|css|js|woff|woff2|ttf|svg|eot)$ {
    expires 30d;
    access_log off;
}

http {
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
}
```

#### for security
- nginx/default.conf
```
# セキュリティヘッダーの追加
add_header X-Content-Type-Options nosniff;
add_header X-Frame-Options SAMEORIGIN;
add_header X-XSS-Protection "1; mode=block";
```
