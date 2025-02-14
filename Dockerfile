# Używamy obrazu PHP 8.3 z FPM
FROM php:8.3-fpm

# Instalujemy niezbędne pakiety
RUN apt-get update && apt-get install -y \
    nginx \
    supervisor \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    git \
    unzip \
    libpq-dev \
    curl \
    && apt-get clean \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_pgsql pgsql

# Instalujemy Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Ustawiamy katalog roboczy
WORKDIR /var/www/html

# Kopiujemy pliki projektu do kontenera
COPY . .

# Instalujemy zależności Laravel
RUN composer install --no-dev --optimize-autoloader

# Kopiujemy konfigurację Nginx
COPY ./nginx.conf /etc/nginx/nginx.conf

# Tworzymy link do katalogu public w Laravel
RUN ln -s /var/www/html/public /var/www/html/public_html

# Ustawiamy uprawnienia dla Laravel
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Kopiujemy konfigurację Supervisord
COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY .env .env
# Wystawiamy port 80 dla Nginx
EXPOSE 80

# Uruchamiamy Supervisord, który odpala zarówno PHP-FPM, jak i Nginx
CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
