# Gradecraft web application Docker image
#
# VERSION       2.0
# ENVIRONMENT	staging

# ~~~~ Image base ~~~~
FROM ruby:2.5.3
MAINTAINER ai-devops <ai-devops@umich.edu>

# ~~~~ Newrelic ~~~~
RUN echo deb http://apt.newrelic.com/debian/ newrelic non-free >> /etc/apt/sources.list.d/newrelic.list
RUN wget -O- https://download.newrelic.com/548C16BF.gpg | apt-key add -
RUN wget -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | apt-key add -
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/pgdg.list

# ~~~~ Update OS ~~~~~
RUN apt-get update
RUN apt-get upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install libssl1.0.2 libpq-dev wget git nginx vim newrelic-sysmond postgresql-client-9.5 libkrb5-dev nodejs krb5-user build-essential libfuse-dev libcurl4-openssl-dev libxml2-dev mime-support automake libtool wget tar zip cron -y
RUN apt-get install -y nodejs yarn

RUN mkdir /s3mnt
RUN chgrp -R 1000 /s3mnt
RUN chmod -R g+rwx /s3mnt

# ~~~~ Add user for OpenShift sandbox ~~~~
RUN useradd -l -u 1000170000 -s /bin/bash ocapp

# ~~~~ Add cron jobs ~~~~
#ADD cron/crontab /etc/cron.d/trim-cron
#RUN chmod 0644 /etc/cron.d/trim-cron
#RUN touch /var/log/cron.log

# ~~~~~ Opening Ports ~~~~~
EXPOSE 8080
EXPOSE 8443

ENV DOCKER_FIX random
RUN gem install -v 1.17.3 bundler
RUN mkdir /home/ocapp && chown -R ocapp: /home/ocapp
RUN mkdir /gradecraft
WORKDIR /gradecraft/
ADD Gemfile /gradecraft/Gemfile
ADD Gemfile.lock /gradecraft/Gemfile.lock
RUN bundle install
COPY . /gradecraft

RUN cp ./secrets/gradecraft_saml_idp.pem /gradecraft/gradecraft_saml_idp.pem
RUN cp ./secrets/gcsha256.key /gradecraft/gcsha256.key
RUN cp ./secrets/gcsha256.crt /gradecraft/gcsha256.crt
#RUN cp ./secrets/www.gradecraft.com.key /gradecraft/www.gradecraft.com.key
#RUN cp ./secrets/www.gradecraft.com.crt /gradecraft/www.gradecraft.com.crt
RUN cp ./secrets/app.gradecraft.com.key /gradecraft/app.gradecraft.com.key
RUN cp ./secrets/app.gradecraft.com.crt /gradecraft/app.gradecraft.com.crt
RUN cp ./secrets/database.yml /gradecraft/config/database.yml
RUN cp ./secrets/mongoid.yml /gradecraft/config/mongoid.yml
RUN cp ./secrets/puma.rb /gradecraft/config/puma.rb
RUN cp ./secrets/Procfile /gradecraft/Procfile
RUN cp ./secrets/default /etc/nginx/sites-available/default
RUN cp ./secrets/beta.rb /gradecraft/config/environments/beta.rb

#RUN printf  "if [ \$WEBRESQUE = 'WEB' ]\nthen \n RAILS_ENV=beta  bundle exec rake resque:scheduler &\n/mounts3.sh\nservice nginx stop\ncertbot-auto certonly --verbose --noninteractive  --standalone --agree-tos --email=\"ai-devops@umich.edu\" -d \"beta.gradecraft.com\" --force-renew\nservice nginx start\ncrontab -r\ncrontab -l | { cat; echo \"30 2 * * * certbot-auto renew \"; } | crontab - \npuma\nelse \n RAILS_ENV=beta bundle exec rake resque:scheduler & \nbundle exec rake resque:work >> resque.log\nfi" > /gradecraft/start.sh
RUN printf  "ln -s /s3mnt ./files\nif [ \$WEBRESQUE = 'WEB' ]\nthen \n RAILS_ENV=beta bundle exec rake resque:scheduler &\nservice nginx start\npuma\nelse \n RAILS_ENV=beta bundle exec rake resque:scheduler & \nbundle exec rake resque:work >> resque.log\nfi" > /gradecraft/start.sh
RUN chmod +x /gradecraft/start.sh
#RUN crontab /etc/cron.d/trim-cron
#CMD cron && tail -f /var/log/cron.log
RUN chgrp -R 1000 /gradecraft /usr
RUN chmod -R g+rwx /gradecraft /usr
RUN chmod g+s /gradecraft /usr
RUN chown -R ocapp:  /gradecraft /usr
RUN chgrp -R 1000 /s3mnt /run /etc/nginx /tmp /var/log /var/run /var/lib/ /var/cache
RUN chmod -R g+rwx /s3mnt /run /etc/nginx /tmp /var/log /var/run /var/lib/ /var/cache
RUN RAILS_ENV=beta bundle exec rake --trace assets:precompile
RUN RAILS_ENV=beta bundle exec rake db:migrate
RUN ls /gradecraft/tmp
RUN chmod -R 777 /gradecraft/tmp
RUN chgrp -R 1000 /gradecraft/log
RUN chmod -R g+rwx /gradecraft/log
ENTRYPOINT /gradecraft/start.sh
