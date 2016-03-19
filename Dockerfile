# Dockerfile
# This will build and deploy hello_app
FROM phusion/passenger-ruby22
MAINTAINER Gleidson Nascimento "slaterx@live.com"

# Using default from image - this should call nginx if enabled
CMD ["/sbin/my_init"]

# Set Environment Variables
ENV HOME /root

# Install Postgres
RUN apt-get update && \
    apt-get -y install postgresql 

# Create DB
USER postgres
RUN /etc/init.d/postgresql start \
    && psql --command "CREATE USER username WITH SUPERUSER PASSWORD 'password';" \
    && createdb -O username hello_app \
    && /etc/init.d/postgresql stop

# Install bundle of gems, create DB
USER root
RUN mkdir -p /var/www/hello_app && \
    cd /var/www && \
    git clone --branch=master https://github.com/jeremyolliver/hello_app && \
    chmod -R 775 /var/www/hello_app && \
    chown -R app:app /var/www/hello_app && \
    sed -i 's/^%sudo.*/%sudo   ALL=(ALL) NOPASSWD:ALL/g' /etc/sudoers && \
    usermod -a -G sudo app && \
    cd /var/www/hello_app && \
    touch /var/www/hello_app/log/production && \
    su app -c "bundle install --without test development" && \
    chown -R app:app /var/www/hello_app && \
    chmod -R 775 /var/www/hello_app && \
    su postgres -c "/etc/init.d/postgresql start" && \
    su app -c "RAILS_ENV=production DATABASE_URL=postgres://username:password@localhost/hello_app bundle exec rake db:migrate"  

# Expose Nginx HTTP service
EXPOSE 80

# Enabling Nginx / Passenger startup
RUN rm -f /etc/service/nginx/down && \
    rm /etc/nginx/sites-enabled/default

# Add the nginx site and config
ADD configuration/nginx.conf /etc/nginx/sites-enabled/hello_app.conf
ADD configuration/rails-env.conf /etc/nginx/main.d/rails-env.conf
ADD configuration/startup.sh /etc/my_init.d/startup.sh

# Clean up APT and bundler when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
