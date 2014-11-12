FROM ubuntu:trusty
MAINTAINER dz0ny@ubuntu.si

RUN apt-get -y -q update && apt-get -y -q upgrade
RUN apt-get -y -q install python-software-properties software-properties-common

# posgresql
RUN apt-get -y -q install postgresql postgresql-client postgresql-contrib
# kandan req
RUN apt-get -y -q install ruby1.9.1-dev ruby-bundler libxslt-dev libxml2-dev libpq-dev libsqlite3-dev gcc g++ make nodejs wget git

# run next commands as postgres user
USER postgres

RUN /etc/init.d/postgresql start &&\
    psql --command "CREATE USER kandan WITH SUPERUSER PASSWORD 'kandan';" &&\
    createdb -O kandan kandan &&\
    /etc/init.d/postgresql stop

USER root
WORKDIR /srv
EXPOSE 5000
ENV RACK_ENV production

# Install runner
RUN wget https://godist.herokuapp.com/projects/ddollar/forego/releases/current/linux-amd64/forego -O /usr/bin/forego; chmod +x  /usr/bin/forego

# Bundler
ADD Gemfile Gemfile.lock /srv/
RUN echo "gem: --no-rdoc --no-ri" > ~/.gemrc
RUN bundle install

ADD . /srv

# Configure database
RUN ( echo 'production:' && \
      echo '  adapter: postgresql' && \
      echo '  host: localhost' && \
      echo '  database: kandan' && \
      echo '  pool: 5' && \
      echo '  timeout: 5000' && \
      echo '  username: kandan' && \
      echo '  password: kandan' \
    ) > config/database.yml

RUN sed -i -e"s/config.serve_static_assets = false/config.serve_static_assets = true/" config/environments/production.rb

#Bootstrap application
RUN /etc/init.d/postgresql start &&\
    bundle exec rake assets:precompile db:create db:migrate kandan:bootstrap &&\
    bundle exec rake kandan:boot_hubot && \
    bundle exec rake kandan:hubot_access_key && \
    /etc/init.d/postgresql stop

# Add postgres to procfile
RUN echo "db: su postgres -c '/usr/lib/postgresql/9.3/bin/postgres -D /var/lib/postgresql/9.3/main -c config_file=/etc/postgresql/9.3/main/postgresql.conf'" >> Procfile
# expose data to host for backup
VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

CMD ["forego", "start"]