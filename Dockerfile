# https://docs.docker.com/engine/reference/builder/

# https://hub.docker.com/_/debian
FROM debian:bookworm-slim


# Configure apt not to prompt during docker build
ARG DEBIAN_FRONTEND=noninteractive

# Configure apt to avoid installing recommended and suggested packages
RUN apt-config dump \
    | grep -E '^APT::Install-(Recommends|Suggests)' \
    | sed -e's/1/0/' \
    | tee /etc/apt/apt.conf.d/99no-recommends-no-suggests

# Resynchronize the package index files from their sources
RUN apt-get update

# Install packages
RUN apt-get install -y \
    apache2 \
    ca-certificates \
    curl \
    libapache2-mod-php \
    git \
    mariadb-client \
    php8.2-mbstring \
    php8.2-xml \
    php8.2 \
    php8.2-mysql \
    php8.2-pdo \
    sudo \
    unzip \
    vim \
    wget \
    && update-ca-certificates

# Clean up packages: Saves space by removing unnecessary package files
# and lists
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*


# Add Apache2's www-data user to sudo group and enable passwordless startup
RUN adduser www-data sudo
COPY config/www-data_startupservice /etc/sudoers.d/www-data_startupservice

# Add Apache2 service startup script
COPY config/startupservice.sh /startupservice.sh
RUN chmod +x /startupservice.sh
CMD ["sudo", "/startupservice.sh"]


# Expose ports for Apache
EXPOSE 80


# Enable Apache modules
RUN a2enmod php8.2
RUN a2enmod rewrite


# Create the index directory and set permissions
RUN mkdir -p /var/www/index
RUN chown -R www-data:www-data /var/www/index


# Install Composer
# https://getcomposer.org/doc/00-intro.md#installation-linux-unix-macos
RUN curl -sS https://getcomposer.org/installer \
    | php -- --install-dir=/usr/local/bin --filename=composer


# Install WordPress CLI (WP-CLI)
# https://wp-cli.org/#installing
RUN curl -L \
    https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    -o wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp


# Use WP-CLI to intall WordPress
USER www-data
WORKDIR /var/www/index
RUN wp core download
