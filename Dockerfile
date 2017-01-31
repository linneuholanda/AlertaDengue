FROM debian:jessie

RUN apt-get update
RUN apt-get install -q -y locales nginx sqlite3 libspatialite5 spatialite-bin git-core supervisor python3 python3-pip python3-setuptools python3-numpy python3-pandas python3-shapely postgresql libpq-dev memcached

# Set locale
RUN echo "pt_BR.UTF-8 UTF-8" > /etc/locale.gen
RUN locale-gen pt_BR.UTF-8
RUN update-locale pt_BR.UTF-8
ENV LC_ALL pt_BR.UTF-8

# Configure nginx
ADD config/nginx.conf /etc/supervisor/conf.d/nginx.conf
RUN rm /etc/nginx/sites-enabled/default
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# Configure Memcached
ADD config/memcached.conf /etc/supervisor/conf.d/memcached.conf

# Create deploy user
RUN useradd --shell=/bin/bash --home=/srv/deploy/ --create-home deploy
RUN mkdir -p /srv/deploy/logs/

# Clone code
RUN git clone https://github.com/AlertaDengue/AlertaDengue.git /srv/deploy/AlertaDengue

# Add our local settings. This file is not versioned because it contains
# sensitive data (such as the SECRET_KEY).
ADD AlertaDengue/AlertaDengue/settings.ini /srv/deploy/AlertaDengue/AlertaDengue/AlertaDengue/settings.ini

# Install python deps
RUN pip3 install -r /srv/deploy/AlertaDengue/requirements.txt

# Collectstatic
RUN /srv/deploy/AlertaDengue/AlertaDengue/manage.py collectstatic --noinput

RUN /srv/deploy/AlertaDengue/AlertaDengue/manage.py migrate --run-syncdb --noinput

# Configure supervisor job
ADD config/alerta_dengue.conf /etc/supervisor/conf.d/alerta_dengue.conf

# Configure nginx
ADD config/alerta_dengue_nginx.conf /etc/nginx/sites-enabled/alerta_dengue

# Change the permissions for the user home directory
RUN chown -R deploy:deploy /srv/deploy/

EXPOSE 80
CMD ["/usr/bin/supervisord", "--nodaemon"]
