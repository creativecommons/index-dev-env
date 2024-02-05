# Use Dedian as base image
FROM debian:bookworm-slim as base

# Install packages
RUN apt-get update && \
    apt-get install -y \
    apache2 \
    curl \
    libapache2-mod-php \
    git \
    php8.2-mbstring \
    php8.2-xml \
    php8.2 \
    php8.2-mysql \
    php8.2-pdo \
    unzip \
    vim \
    wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


# Enable Apache modules
RUN a2enmod php8.2
RUN a2enmod rewrite

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

COPY ./config/composer/composer.json /var/www/html/composer.json
COPY ./config/composer/composer.lock /var/www/html/composer.lock

# Install WordPress CLI
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Set up WordPress
WORKDIR /var/www/html
RUN wp core download --allow-root


# Remove the default Apache index.html file
RUN rm /var/www/html/index.html


# Initialize and start Apache service
COPY startupservice.sh /startupservice.sh
RUN chmod +x /startupservice.sh

# Expose ports for Apache and MariaDB
EXPOSE 80

ENTRYPOINT ["/startupservice.sh"]

