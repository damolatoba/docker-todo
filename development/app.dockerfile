FROM php:7.2-fpm

COPY composer.lock composer.json /var/www/


COPY database /var/www/database


WORKDIR /var/www


RUN apt-get update -y && apt-get -y install git && apt-get -y install zip

RUN curl -sS https://getcomposer.org/installer -o composer-setup.php
RUN php -r "if (hash_file('SHA384', 'composer-setup.php') === '756890a4488ce9024fc62c56153228907f1545c228516cbf63f885e036d37e9a59d27d63f46af1d4d07ee0f76181c7d3') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
# RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" 
# RUN php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" 
RUN php composer-setup.php 
RUN php -r "unlink('composer-setup.php');" 
RUN php composer.phar install --no-dev --no-scripts 
RUN rm composer.phar


COPY . /var/www


RUN chown -R www-data:www-data /var/www/storage
RUN chown -R www-data:www-data /var/www/bootstrap/cache
         
        


RUN php artisan key:generate

# RUN php artisan migrate

RUN php artisan cache:clear


RUN php artisan optimize


RUN  apt-get install -y libmcrypt-dev 
# RUN  apt-get install -y libmagickwand-dev 
# RUN libmagickwand-dev --no-install-recommends 
RUN pecl install mcrypt-1.0.2 
RUN docker-php-ext-install pdo_mysql 
RUN docker-php-ext-enable mcrypt


RUN mv .env.prod .env


RUN php artisan optimize
