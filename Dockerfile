FROM php:7.4.3-fpm-alpine3.11

RUN apk update && \
    apk add bash tzdata zip git zlib-dev libzip-dev icu-dev postgresql-dev freetype-dev libjpeg-turbo libjpeg-turbo-dev libpng-dev && \
    rm -rf /var/cache/apk/*

RUN cp /usr/share/zoneinfo/Asia/Seoul /etc/localtime
RUN echo "Asia/Seoul" > /etc/timezone

RUN docker-php-ext-install opcache intl bcmath zip pdo_pgsql gd

# PHP Config
RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini && \
    sed -i "s/display_errors = Off/display_errors = On/" /usr/local/etc/php/php.ini && \
    sed -i "s/upload_max_filesize = .*/upload_max_filesize = 10M/" /usr/local/etc/php/php.ini && \
    sed -i "s/post_max_size = .*/post_max_size = 12M/" /usr/local/etc/php/php.ini && \
    sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /usr/local/etc/php/php.ini && \
    sed -i "s/variables_order = .*/variables_order = 'EGPCS'/" /usr/local/etc/php/php.ini && \
    #    sed -i "s/;error_log =.*/error_log = \/proc\/self\/fd\/2/" /usr/local/etc/php-fpm.conf && \
    sed -i "s/listen = .*/listen = 9000/" /usr/local/etc/php-fpm.d/www.conf && \
    sed -i "s/pm.max_children = .*/pm.max_children = 200/" /usr/local/etc/php-fpm.d/www.conf && \
    sed -i "s/pm.start_servers = .*/pm.start_servers = 56/" /usr/local/etc/php-fpm.d/www.conf && \
    sed -i "s/pm.min_spare_servers = .*/pm.min_spare_servers = 32/" /usr/local/etc/php-fpm.d/www.conf && \
    sed -i "s/pm.max_spare_servers = .*/pm.max_spare_servers = 96/" /usr/local/etc/php-fpm.d/www.conf && \
    sed -i "s/^;clear_env = no$/clear_env = no/" /usr/local/etc/php-fpm.d/www.conf

COPY ./laravel-project /var/www/html

RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/bin/composer

WORKDIR /var/www/html
RUN composer install --no-dev --no-scripts && \
    chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache/

# Bind Port
EXPOSE 9000

CMD ["php-fpm"]
