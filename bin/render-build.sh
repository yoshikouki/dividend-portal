#!/usr/bin/env bash
# exit on error
set -o errexit

apt-get update -qq \
 && apt-get install -y libidn11-dev

bundle install
bundle exec rake assets:precompile
bundle exec rake assets:clean
bundle exec rake db:migrate
