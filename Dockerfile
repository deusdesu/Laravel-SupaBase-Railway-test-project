FROM php:8.3-cli

WORKDIR /app

# Instalacja Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Naprawa HTTPS w Packagist
RUN composer config -g repos.packagist composer https://repo.packagist.org
RUN composer clear-cache

# Instalacja zależności
COPY . /app
RUN composer install --no-dev --optimize-autoloader
RUN composer require guzzlehttp/guzzle

CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
