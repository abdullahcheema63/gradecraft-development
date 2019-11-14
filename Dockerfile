# Gradecraft web application Docker image
#
# VERSION       2.0
# ENVIRONMENT	beta

# ~~~~ Image base ~~~~
FROM quay.io/gradecraft/secrets:beta.gradecraft.com
MAINTAINER Nagumalli Sundeep <nagumals@umich.edu>
ENV DOCKER_FIX random
RUN gem install -v 1.17.3 bundler
RUN mkdir /gradecraft
WORKDIR /gradecraft/
ADD Gemfile /gradecraft/Gemfile
ADD Gemfile.lock /gradecraft/Gemfile.lock
RUN bundle install
COPY . /gradecraft
RUN cp /intermidiate/gradecraft_saml_idp.pem /gradecraft/gradecraft_saml_idp.pem
RUN cp /intermidiate/gcsha256.key /gradecraft/gcsha256.key
RUN cp /intermidiate/gcsha256.crt /gradecraft/gcsha256.crt
RUN cp /intermidiate/app.gradecraft.com.key /gradecraft/app.gradecraft.com.key
RUN cp /intermidiate/app.gradecraft.com.crt /gradecraft/app.gradecraft.com.crt
RUN cp /intermidiate/database.yml /gradecraft/config/database.yml
RUN cp /intermidiate/puma.rb /gradecraft/config/puma.rb
RUN cp /intermidiate/Procfile /gradecraft/Procfile
RUN cp ./secrets/start.sh /gradecraft/start.sh
RUN chmod +x /gradecraft/start.sh
RUN ln -svf /usr/local/bundle/gems/sidekiq-[0-9]*/web/assets /gradecraft/public/sidekiq
RUN crontab /etc/cron.d/trim-cron
CMD cron && tail -f /var/log/cron.log
RUN RAILS_ENV=beta bundle exec rake assets:precompile
RUN RAILS_ENV=beta bundle exec rake db:migrate
ENTRYPOINT /gradecraft/start.sh
