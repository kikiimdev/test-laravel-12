FROM dunglas/frankenphp

# Set Caddy server name to "http://" to serve on 80 and not 443
# Read more: https://frankenphp.dev/docs/config/#environment-variables
ENV SERVER_NAME="http://"

# RUN apt-get update \
#     && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
#     git \
#     unzip \
#     librabbitmq-dev \
#     libpq-dev \
#     supervisor

RUN apt update && apt install -y \
    curl unzip git libicu-dev libzip-dev libpng-dev libjpeg-dev libfreetype6-dev libssl-dev

RUN install-php-extensions \
    gd \
    pcntl \
    opcache \
    pdo \
    pdo_mysql \
    intl \
    zip \
    exif \
    ftp \
    bcmath

# Set php.ini
RUN echo "opcache.enable=1" > /usr/local/etc/php/conf.d/custom.ini \
    && echo "opcache.jit=tracing" >> /usr/local/etc/php/conf.d/custom.ini \
    && echo "opcache.jit_buffer_size=256M" >> /usr/local/etc/php/conf.d/custom.ini \
    && echo "memory_limit=512M" > /usr/local/etc/php/conf.d/custom.ini \
    && echo "upload_max_filesize=6M" >> /usr/local/etc/php/conf.d/custom.ini \
    && echo "post_max_size=6M" >> /usr/local/etc/php/conf.d/custom.ini

# Copy Composer dari official image
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /app

RUN mkdir -p /app/storage /app/bootstrap/cache

RUN chown -R www-data:www-data /app/storage bootstrap/cache && chmod -R 775 /app/storage

COPY . .

# Install PHP extensions
RUN pecl install redis

# Install Laravel dependencies using Composer.
RUN composer install --prefer-dist --optimize-autoloader --no-interaction

# Enable PHP extensions
RUN docker-php-ext-enable redis

# EXPOSE 80 443
EXPOSE 8000

ENTRYPOINT ["php", "artisan", "octane:frankenphp"]
