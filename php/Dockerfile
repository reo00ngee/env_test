# PHP 8.0 FPMをベースにする
FROM php:8.0-fpm

# 必要なPHP拡張をインストール
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd \
    && apt-get clean

# webユーザーとグループを作成（UID/GIDを固定したいなら指定も可）
RUN groupadd -r web && useradd -r -g web web

# ログディレクトリ作成と所有権設定
RUN mkdir -p /home/web/log \
    && touch /home/web/log/php-error.log \
    && touch /home/web/log/php-slow.log \
    && chown -R web:web /home/web

# 作業ディレクトリ
WORKDIR /var/www/html

# FPMの設定ファイルにwebユーザーを設定する（`www.conf` にも対応しておく）
RUN sed -i 's/^user = .*/user = web/' /usr/local/etc/php-fpm.d/www.conf && \
    sed -i 's/^group = .*/group = web/' /usr/local/etc/php-fpm.d/www.conf && \
    sed -i 's/^listen.owner = .*/listen.owner = web/' /usr/local/etc/php-fpm.d/www.conf && \
    sed -i 's/^listen.group = .*/listen.group = web/' /usr/local/etc/php-fpm.d/www.conf

# コンテナ内でwebユーザーとして実行する
USER web

# ポート9000を公開
EXPOSE 9000

# php-fpm を起動
CMD ["php-fpm"]
