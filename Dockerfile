FROM dunglas/frankenphp

RUN apk add --no-cache \
    git \
    curl \
    # libpng-dev \
    # libxml2-dev \
    # zip \
    unzip
    # oniguruma-dev \
    # libzip-dev \
    # freetype-dev \
    # libjpeg-turbo-dev \
    # libwebp-dev \
    # icu-dev

RUN install-php-extensions \
    pcntl
    # Add other PHP extensions here...

COPY . /app

# Copy Composer dari official image
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /app

# Install dependencies PHP menggunakan Composer
RUN composer install --optimize-autoloader

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

ENTRYPOINT ["php", "artisan", "octane:frankenphp"]
