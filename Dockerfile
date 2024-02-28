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

# Resynchronize the package
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


# Enable Apache modules
RUN a2enmod php8.2
RUN a2enmod rewrite


# create an index directory
RUN mkdir -p /var/www/index

# Install Composer
RUN curl -sS https://getcomposer.org/installer \
    | php -- --install-dir=/usr/local/bin --filename=composer

# set permissions
RUN chown -R www-data:www-data /var/www/index

# Install WordPress CLI
RUN curl -L \
    https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    -o wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Set up WordPress
USER www-data
WORKDIR /var/www/index
RUN wp core download

# Switch to root
USER root

# Initialize and start Apache service
COPY config/startupservice.sh /startupservice.sh
RUN chmod +x /startupservice.sh

# Expose ports for Apache and MariaDB
EXPOSE 80

CMD ["/startupservice.sh"]
