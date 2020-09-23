FROM php:7-fpm-alpine

RUN apk update \
 && apk add --no-cache $PHPIZE_DEPS \
    bash \
    git \
    zip \
    unzip

# PHP extensions
RUN docker-php-ext-install opcache pdo_mysql mysqli
RUN docker-php-ext-enable opcache

# Install composer
RUN php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer

# Upgrade bash configuration
COPY .bashrc /home/www-data/.bashrc

#######################
# Override the image  #
# ENTRYPOINT to add   #
# some logic          #
#######################
COPY entrypoint.sh /usr/local/bin/entrypoint
RUN chmod +x /usr/local/bin/entrypoint
ENTRYPOINT ["entrypoint"]