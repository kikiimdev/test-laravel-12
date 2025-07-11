# Use the official FrankenPHP image as the base
FROM dunglas/frankenphp:latest

ENV SERVER_NAME=http://test-laravel-12.banjarmasinkota.go.id

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    git \
    unzip \
    librabbitmq-dev \
    libpq-dev \
    supervisor

# Install PHP extensions required by Laravel
# You may need to add more extensions based on your application's needs
RUN install-php-extensions \
    pdo_mysql \
    pcntl \
    opcache \
    redis \
    # Add any other extensions like gd, zip, etc., if your app needs them
    # For example: gd zip
    && rm -rf /var/lib/apt/lists/*


COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /app

# Copy the rest of the application code
COPY . .

# Install Composer dependencies
RUN composer install --no-dev --optimize-autoloader

# Set appropriate permissions for Laravel storage and bootstrap/cache directories
RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R ug+rwx storage bootstrap/cache

# Expose ports (FrankenPHP listens on 80 for HTTP and 443 for HTTPS)
# EXPOSE 80 443 443/udp
EXPOSE 8000

# Command to run FrankenPHP with Laravel Octane in worker mode
# --host=0.0.0.0 makes it accessible from other containers/outside the container
# --max-requests=1 is useful for development to see immediate code changes
# For production, you might want to increase this or remove it,
# and use --workers to control the number of PHP worker processes.
CMD ["php", "artisan", "octane:frankenphp", "--caddyfile=Caddyfile"]
