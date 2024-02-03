FROM php:8.2.4-apache


# Mod Rewrite
RUN a2enmod rewrite

# Linux Library
RUN apt-get update -y && apt-get install -y \
    libicu-dev \
    libmariadb-dev \
    unzip zip \
    zlib1g-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev 

# Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# PHP Extension
RUN docker-php-ext-install gettext intl pdo_mysql gd

EXPOSE 80

RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd

    
COPY --chown=www-data:www-data . /srv/app 
COPY .docker/vhost.conf /etc/apache2/sites-available/000-default.conf 

WORKDIR /srv/app


# # Use an official PHP runtime as a parent image
# FROM php:8.2.4-apache

# # Set the working directory to /var/www/html
# WORKDIR /var/www/html

# # Copy composer.lock and composer.json into the container
# COPY composer.lock composer.json /var/www/html/

# # Install Laravel dependencies using Composer
# RUN apt-get update && apt-get install -y \
#     libzip-dev \
#     unzip \
#     && docker-php-ext-install zip pdo pdo_mysql \
#     && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
#     && composer install --no-scripts --no-autoloader --no-progress --no-suggest \
#     && rm -rf /var/lib/apt/lists/*

# # Copy the rest of the application code into the container
# COPY . /var/www/html

# # Generate the Laravel application key
# RUN php artisan key:generate

# # Set permissions
# RUN chown -R www-data:www-data /var/www/html \
#     && chmod -R 755 /var/www/html/storage

# # Expose port 80
# EXPOSE 80

# # Run Apache in the foreground
# CMD ["apache2-foreground"]