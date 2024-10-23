FROM composer:2.0.8 as composer

WORKDIR /app
RUN composer require h4cc/wkhtmltopdf-amd64 0.12.x
RUN composer require h4cc/wkhtmltoimage-amd64 0.12.x

FROM php:7.3-apache

RUN apt-get update -y

RUN apt-get install -y \
  curl \
  libcurl3-dev \
  build-essential \
  git \
  libicu-dev \
  zip \
  unzip \
  zlib1g-dev \
  libfreetype6-dev \
  libjpeg62-turbo-dev \
  libmcrypt-dev \
  libpng-dev \
  libxml2-dev \
  unixodbc \
  unixodbc-dev \
  freetds-dev \
  freetds-bin \
  tdsodbc \
  libticonv-dev \
  vim \
  traceroute \
  iputils-ping \
  libgmp-dev \
  libfontconfig1 \
  libxrender1 \
  libpq-dev \
  libzip-dev

RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-configure pdo_odbc --with-pdo-odbc=unixODBC,/usr/ \
    && arch=$(arch) && docker-php-ext-configure pdo_dblib --with-libdir=/lib/${arch}-linux-gnu \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install -j$(nproc) \
    mbstring \
    iconv \
    intl \
    zip \
    gd \
    pdo \
    pdo_odbc \
    pdo_dblib \
    pdo_mysql \
    pdo_pgsql \
    pgsql \
    xml \
    curl \
    gmp \
    soap \
    exif \
    pcntl

COPY --from=composer:2.0.8 /usr/bin/composer /usr/local/bin/composer
COPY --from=composer /app/vendor/h4cc/wkhtmltopdf-amd64/bin/wkhtmltopdf-amd64 /usr/local/bin/wkhtmltopdf
COPY --from=composer /app/vendor/h4cc/wkhtmltoimage-amd64/bin/wkhtmltoimage-amd64 /usr/local/bin/wkhtmltoimage

RUN a2enmod rewrite
