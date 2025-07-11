# Use the official FrankenPHP image as the base
FROM dunglas/frankenphp:latest

# Set working directory
WORKDIR /app

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

# Copy composer.json and composer.lock first to leverage Docker cache
COPY composer.json composer.lock ./

# Install Composer dependencies
RUN composer install --no-dev --optimize-autoloader

# Copy the rest of the application code
COPY . .

# Set appropriate permissions for Laravel storage and bootstrap/cache directories
RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R ug+rwx storage bootstrap/cache

# Expose ports (FrankenPHP listens on 80 for HTTP and 443 for HTTPS)
EXPOSE 80 443 443/udp

# Command to run FrankenPHP with Laravel Octane in worker mode
# --host=0.0.0.0 makes it accessible from other containers/outside the container
# --max-requests=1 is useful for development to see immediate code changes
# For production, you might want to increase this or remove it,
# and use --workers to control the number of PHP worker processes.
CMD ["php", "artisan", "octane:frankenphp", "--host=0.0.0.0", "--port=80"]
