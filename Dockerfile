FROM php:7.1-fpm-alpine

LABEL version="v1.0.2"
LABEL maintainer="Sheaven <sheaven@qq.com>, Guan Shiliang <guan.shiliang@gmail.com>"

ARG piplin_ver=v1.0.2

RUN mkdir -p /var/www/piplin
WORKDIR /var/www/piplin

RUN sed -i "s/dl-cdn.alpinelinux.org/mirror.tuna.tsinghua.edu.cn/" /etc/apk/repositories

# PHP 环境安装
RUN set -xe \
    && apk add --no-cache \
        freetype-dev \
        libjpeg-turbo-dev \
        libpng-dev \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd zip

# 复制项目代码
RUN set -xe; \
    curl -o ${piplin_ver}.tar.gz -fSL "https://github.com/Piplin/Piplin/archive/${piplin_ver}.tar.gz"; \
    tar xzvf ${piplin_ver}.tar.gz --strip-components=1; \
    rm -r ${piplin_ver}.tar.gz composer.lock

# 安装 composer
RUN set -xe \
    && php -r "copy('https://install.phpcomposer.com/installer', 'composer-setup.php');" \
    && php composer-setup.php \
    && rm -f composer-setup.php \
    && mv composer.phar /usr/local/bin/composer \
    && composer config -g repo.packagist composer https://packagist.phpcomposer.com

# 安装项目依赖
RUN set -xe \
    && apk add --no-cache nginx redis nodejs nodejs-npm supervisor git bash openssh-client rsync \
    && npm config set registry http://registry.npm.taobao.org/ \
    && composer install -o \
    && npm install --production \
    && chmod -R 777 storage \
    && chmod -R 777 bootstrap/cache \
    && chmod -R 777 public/upload \
    && mkdir -p /etc/supervisor/conf.d \
    && echo '* * * * * /usr/bin/php /var/www/piplin/artisan schedule:run >> /dev/null 2>&1' > /etc/crontabs/root
COPY supervisor/supervisord.conf /etc/supervisor/supervisord.conf
COPY supervisor/piplin.conf /etc/supervisor/conf.d/piplin.conf
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/piplin.template /etc/nginx/conf.d/default.conf
COPY .env.docker /var/www/piplin/.env
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

VOLUME /var/www/piplin
EXPOSE 80

CMD ["/usr/local/bin/entrypoint.sh"]
