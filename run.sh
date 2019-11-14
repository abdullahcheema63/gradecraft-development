#!/usr/bin/env bash

cp config/puma.sample-env.rb config/puma.rb

if [ "${GC_PROCESS_TYPE}" = "worker" ]; then
  apt-get update
  apt-get install -y nginx
  echo "server { listen 5000; root html; index index.html; }" >> /etc/nginx/sites-enabled/default
  service nginx restart
  bundle exec rake sidekiq
else
  bundle exec puma
fi
