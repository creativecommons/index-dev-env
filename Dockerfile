# https://docs.docker.com/engine/reference/builder/

# https://hub.docker.com/_/debian
FROM debian:bookworm-slim
# NOTE: Occurrences of "NOTE: PHP version", below, where a specific PHP version
#       is required (based on version supported by installed Debian version)

# https://docs.docker.com/build/building/best-practices/#apt-get
# - Resynchronize the package index, update packages, install packages,
#   clean-up, and update CA certificates
RUN DEBIAN_FRONTEND=noninteractive apt-get update \
        --no-allow-insecure-repositories --quiet \
    && DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade \
        --no-install-recommends --no-install-suggests --quiet --yes \
    && DEBIAN_FRONTEND=noninteractive apt-get install \
        --no-install-recommends --no-install-suggests --quiet --yes \
    apache2 \
    apache2-utils \
    ca-certificates \
    curl \
    git \
    less \
    libapache2-mod-php \
    mariadb-client \
    php \
    php-mbstring \
    php-mysql \
    php-pdo \
    php-xml \
    sudo \
    unzip \
    vim \
    wget \
    && DEBIAN_FRONTEND=noninteractive apt-get clean --quiet \
    && rm --recursive --force /var/lib/apt/lists/* \
    && update-ca-certificates


# Add Apache2's www-data user to sudo group and enable passwordless startup
RUN adduser www-data sudo
COPY config/www-data_startupservice /etc/sudoers.d/www-data_startupservice

# Add Apache2 service startup script
COPY config/startupservice.sh /startupservice.sh
RUN chmod +x /startupservice.sh
CMD ["sudo", "--preserve-env", "/startupservice.sh"]


# Expose ports for Apache
EXPOSE 80


# Enable Apache modules - NOTE: PHP version
RUN a2enmod headers \
    && a2enmod php8.2 \
    && a2enmod proxy \
    && a2enmod proxy_http \
    && a2enmod rewrite \
    && a2enmod ssl

# Configure PHP - NOTE: PHP version
COPY config/90-local.ini /etc/php/8.2/apache2/conf.d/

# Install Composer
# https://getcomposer.org/doc/00-intro.md#installation-linux-unix-macos
RUN curl --silent --show-error https://getcomposer.org/installer \
    | php -- --install-dir=/usr/local/bin --filename=composer

# Create compose directory for www-data
RUN mkdir /var/www/.composer
RUN chown -R www-data:www-data /var/www/.composer


# Install WordPress CLI (WP-CLI)
# https://wp-cli.org/#installing
RUN curl --silent --show-error --location \
    https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    --output wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Create WP-CLI directory for www-data
RUN mkdir /var/www/.wp-cli
RUN chown -R www-data:www-data /var/www/.wp-cli


# Create the index directory and set permissions
RUN mkdir -p /var/www/index/wp-content/uploads
RUN chown -R www-data:www-data /var/www/index


# Use WP-CLI to intall WordPress
USER www-data
WORKDIR /var/www/index
ARG WP_VERSION
RUN wp core download --version=$WP_VERSION

# Add WordPress basic configuration
# 1) Download wp-config-docker.php for use as wp-config.php. Friendly view at:
# https://github.com/docker-library/wordpress/blob/master/latest/php8.2/apache/wp-config-docker.php
RUN curl --silent --show-error --location \
    https://raw.githubusercontent.com/docker-library/wordpress/master/latest/php8.2/apache/wp-config-docker.php \
    --output /var/www/index/wp-config.php


# 2) Use awk to replace all instances of "put your unique phrase here" with a
#    properly unique string (for AUTH_KEY and friends to have safe defaults if
#    they aren't specified with environment variables)
#    Based on:
# https://github.com/docker-library/wordpress/blob/master/latest/php8.2/apache/docker-entrypoint.sh
RUN awk ' \
    /put your unique phrase here/ { \
        cmd = "head -c1m /dev/urandom | sha1sum | cut -d\\  -f1"; \
        cmd | getline str; \
        close(cmd); \
        gsub("put your unique phrase here", str); \
    } \
    { print } \
    ' /var/www/index/wp-config.php > /var/www/index/wp-config.tmp \
    && mv /var/www/index/wp-config.tmp /var/www/index/wp-config.php
