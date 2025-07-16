FROM dunglas/frankenphp

# Set Caddy server name to "http://" to serve on 80 and not 443
# Read more: https://frankenphp.dev/docs/config/#environment-variables
ENV SERVER_NAME="http://"

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    git \
    unzip \
    librabbitmq-dev \
    libpq-dev \
    supervisor

RUN install-php-extensions \
    gd \
    pcntl \
    opcache \
    pdo \
    pdo_mysql \
    redis

# Set working directory
WORKDIR /app

# Copy Composer dari official image
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

COPY . .

# Install PHP extensions
RUN pecl install xdebug

# Install Laravel dependencies using Composer.
RUN composer install --optimize-autoloader

# Enable PHP extensions
RUN docker-php-ext-enable xdebug

# Buat direktori yang dibutuhkan Laravel
RUN mkdir -p /app/storage/logs \
    && mkdir -p /app/storage/framework/cache \
    && mkdir -p /app/storage/framework/sessions \
    && mkdir -p /app/storage/framework/views \
    && mkdir -p /app/bootstrap/cache

# Set proper ownership dan permissions
RUN chown -R www-data:www-data /app \
    && find /app/storage -type f -exec chmod 664 {} \; \
    && find /app/storage -type d -exec chmod 775 {} \; \
    && find /app/bootstrap/cache -type f -exec chmod 664 {} \; \
    && find /app/bootstrap/cache -type d -exec chmod 775 {} \;

# EXPOSE 80 443
EXPOSE 8000

ENTRYPOINT ["php", "artisan", "octane:frankenphp"]
