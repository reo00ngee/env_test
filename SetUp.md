## 1. Overview

This document outlines the steps to set up a Linux server environment using Docker for web development. The server includes Nginx and PHP-FPM, configured to run under a specific user with performance and security tuning.

## 2. Prerequisites

Docker installed on the host machine

## 3. Set up

### 3-1. Install nginx and php-fpm

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
    access_log /home/web/log/access.log;
    error_log /home/web/log/error.log;

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
            fastcgi_param SCRIPT_FILENAME /home/web/www$document_root$fastcgi_script_name;
            include fastcgi_params;
        }
    }
}
```



