# PHP 8.0 FPMをベースにする
FROM php:8.0-fpm

# 作業ディレクトリを設定
WORKDIR /var/www/html

# 必要なPHP拡張をインストール
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd \
    && apt-get clean

# カスタムのphp.iniをコピー
COPY ./php/php.ini /usr/local/etc/php/

# PHP-FPMのカスタム設定ファイルをコピー
COPY ./php/php-fpm.conf /usr/local/etc/php-fpm.conf
COPY ./php/php-fpm.d/www.conf /usr/local/etc/php-fpm.d/www.conf

# PHP-FPMのログを指定の場所に保存
RUN mkdir -p /home/web/log \
    && touch /home/web/log/php-error.log \
    && touch /home/web/log/php-slow.log \
    && chown -R www-data:www-data /home/web/log

# ポート9000を公開（PHP-FPMのデフォルトポート）
EXPOSE 9000

# コンテナ起動時にPHP-FPMを実行
CMD ["php-fpm"]
