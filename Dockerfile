FROM ubuntu
MAINTAINER Christian Lück <christian@lueck.tv>

RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y \
  nginx git supervisor php5-fpm php5-cli php5-curl php5-gd php5-json \
  php5-pgsql php5-mysql php5-mcrypt && apt-get clean

# add ttrss as the only nginx site
ADD ttrss.nginx.conf /etc/nginx/sites-available/ttrss
RUN ln -s /etc/nginx/sites-available/ttrss /etc/nginx/sites-enabled/ttrss
RUN rm /etc/nginx/sites-enabled/default

# install ttrss and patch configuration
RUN git clone https://github.com/gothfox/Tiny-Tiny-RSS.git /var/www
WORKDIR /var/www
RUN cp config.php-dist config.php
RUN sed -i -e "/'SELF_URL_PATH'/s/ '.*'/ 'http:\/\/localhost\/'/" config.php

# install greader theme
RUN git clone https://github.com/naeramarth7/clean-greader /var/www/themes.local/clean-greader
RUN ln -s /var/www/themes.local/clean-greader/clean-greader.css /var/www/themes.local/clean-greader.css

# install joschasa plugin package
RUN apt-get install -y wget unzip && apt-get clean
RUN cd /var/www/plugins.local/ && wget -O- https://github.com/Joschasa/Tiny-Tiny-RSS-Plugins/archive/master.tar.gz | \
	tar -xvz --strip 1

# install reeder theme
RUN cd /var/www/themes.local/ && wget -O- https://github.com/tschinz/tt-rss_reeder_theme/archive/master.tar.gz | \
	tar -xvz --strip 1

# install feediron plugin
RUN git clone git://github.com/m42e/ttrss_plugin-feediron.git /var/www/plugins.local/feediron

# install ttbag plugin
RUN git clone --recursive git://github.com/stesie/ttbag.git /var/www/plugins.local/ttbag
RUN sed -e 's/note/&, ttbag/' -i config.php

RUN chown www-data:www-data -R /var/www

# enable mcrypt php module
RUN php5enmod mcrypt

# expose only nginx HTTP port
EXPOSE 80

# expose default database credentials via ENV in order to ease overwriting
ENV DB_NAME ttrss
ENV DB_USER ttrss
ENV DB_PASS ttrss

# always re-configure database with current ENV when RUNning container, then monitor all services
ADD configure-db.php /configure-db.php
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD php /configure-db.php && supervisord -c /etc/supervisor/conf.d/supervisord.conf

