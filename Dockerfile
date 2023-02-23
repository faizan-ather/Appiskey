# Use an official PHP runtime as a parent image
FROM php:8.1-fpm

# Set the working directory
WORKDIR /var/www/html

COPY php.ini /usr/local/etc/php/php.ini

# Copy the composer.json and composer.lock files
COPY composer.json composer.lock ./

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install dependencies
RUN apt-get update && \
    apt-get install -y git unzip libicu-dev libzip-dev && \
    docker-php-ext-install intl pdo_mysql zip && \
    #curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer && \
    composer install --no-scripts --no-autoloader

# Copy the code into the container
COPY . .

# Set permissions
RUN chown -R www-data:www-data storage bootstrap/cache && \
    chmod -R 775 storage bootstrap/cache

# Install Nginx
RUN apt-get update && apt-get install -y nginx

# Remove the default Nginx configuration file
#RUN rm /etc/nginx/sites-enabled/default

# Copy the Nginx configuration file
#COPY nginx.conf /etc/nginx/sites-enabled/
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80
EXPOSE 80

# Run composer and generate autoload files
RUN composer dump-autoload --no-scripts --no-dev --optimize

# Start Nginx and PHP-FPM
CMD php-fpm && service nginx start
