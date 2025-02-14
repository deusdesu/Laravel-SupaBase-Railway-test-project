# Używamy obrazu PHP 8.3
FROM php:8.3-fpm

# Instalujemy niezbędne pakiety, w tym Nginx
RUN apt-get update && apt-get install -y \
    ca-certificates \
    nginx \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    git \
    unzip \
    libpq-dev \
    && apt-get clean \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_pgsql pgsql

# Instalujemy Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Zmiana właściciela plików (jeśli Git odmawia z powodu "dubious ownership")
RUN chown -R www-data:www-data /var/www/html
RUN git config --global --add safe.directory /var/www/html

# Ustawiamy katalog roboczy
WORKDIR /var/www/html

# Kopiujemy pliki projektu do kontenera
COPY . .

# Instalujemy zależności aplikacji
RUN composer install --no-dev --optimize-autoloader

# Wyczyść cache i skonfiguruj Composer, aby nie wymagał HTTPS
RUN composer clear-cache
RUN composer config -g -- disable-tls true
RUN composer config -g secure-http false
RUN composer config -g repo.packagist composer http://repo.packagist.org

# Instalujemy Guzzle
RUN composer require guzzlehttp/guzzle

# Kopiujemy konfigurację Nginx
COPY ./nginx.conf /etc/nginx/nginx.conf

# Tworzymy link do katalogu public w Laravel
RUN ln -s /var/www/html/public /var/www/html/public_html

# Ustawiamy uprawnienia dla folderów Laravel
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Wystawiamy port 80, na którym działa Nginx
EXPOSE 80

# Uruchamiamy Nginx oraz PHP-FPM
CMD nginx && php-fpm
