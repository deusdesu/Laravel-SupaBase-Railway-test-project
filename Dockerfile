# 1. Pobieramy obraz PHP z wbudowanym FPM i Composerem
FROM php:8.3-fpm

# 2. Instalujemy niezbędne rozszerzenia i zależności systemowe
RUN apt-get update && apt-get install -y \
    libpq-dev \
    unzip \
    git \
    curl \
    && docker-php-ext-install pdo pdo_pgsql

# 3. Instalujemy Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Naprawa HTTPS w Packagist
RUN composer config -g repos.packagist composer https://repo.packagist.org
RUN composer clear-cache

# 4. Ustawiamy katalog roboczy
WORKDIR /var/www/html

# 5. Kopiujemy pliki projektu do kontenera
COPY . .

# 5. Instalacja zależności
COPY . /app
RUN composer install --no-dev --optimize-autoloader
RUN composer require guzzlehttp/guzzle

# 7. Ustawiamy uprawnienia dla storage i bootstrap/cache
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# 8. Otwieramy port (Railway dynamicznie przypisuje zmienną PORT)
EXPOSE 8000

# 9. Uruchamiamy Laravel na dynamicznym porcie
CMD php artisan serve --host=0.0.0.0 --port=${PORT:-8000}
