# Gradecraft is a gameful learning management system.

[ ![Codeship Status for UM-USElab/gradecraft-development](https://codeship.com/projects/a7421010-4e8b-0133-aacd-4e8e1c03c7f2/status?branch=master)](https://codeship.com/projects/106957)

[![Test Coverage](https://codeclimate.com/github/UM-USElab/gradecraft-development/badges/coverage.svg)](https://codeclimate.com/github/UM-USElab/gradecraft-development/coverage)

[![Code Climate](https://codeclimate.com/github/UM-USElab/gradecraft-development/badges/gpa.svg)](https://codeclimate.com/github/UM-USElab/gradecraft-development)

## Current features:
* Badges
* Teams (course-long memberships)
* Groups (single-assignment memberships)
* Assignments
* Assignment Submissions
* Assignment Unlocks
* Student Dashboard
* Interactive Grade Predictor
* Interactive Course Timeline
* Grading Rubrics
* Export students and final grades
* User analytics
* Team analytics
* Learning analytics suite
* Custom, multi-component leveling system
* Assignment stats
* Student-logged assignment scoring
* Multipliers (students decide assignment weight)

## Pre-reqs:
* Ruby 2.5.3
* PostgreSQL
* Redis

## Installation Notes for running locally

1. Clone the repository

```sh
# clone to current directory; change dir
git clone https://github.com/UM-USElab/gradecraft-development.git
cd gradecraft-development
```

2. Copy configuration files
```sh
# Note: ensure that you are in the newly cloned /gradecraft-development dir
cp config/database.yml.sample config/database.yml
cp .env.sample .env

# obtain and replace required credentials for .env (AWS, etc.)

# comment out ALL SAML and IDP-related lines
```

3. Install Homebrew (Optional: `brew update`)

4. Install a Ruby version manager of your choice and set current version to project version (Steps below pertain to [rbenv](https://github.com/rbenv/rbenv))

* Use `brew install rbenv` to install rbenv on MacOS and run the following

* Use [these instructions](https://www.digitalocean.com/community/tutorials/how-to-install-ruby-on-rails-with-rbenv-on-ubuntu-18-04) instead of the method above for installing rbenv if using Ubuntu and run the following

```sh
# run command and follow instructions, will likely be the next step where you edit ~/.bash_profile
rbenv init

# make rbenv start up with terminal
edit ~/.bash_profile and add eval "$(rbenv init -)"

# optional (rbenv doctor script to check installation)
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/master/bin/rbenv-doctor | bash

# install and set the current version
rbenv install 2.5.3 (or whatever version Gradecraft is on)
rbenv local 2.5.3 (or rbenv global 2.5.3 if preferred)

# Restart terminal for changes to fully take into effect and ensure that the command rbenv works
```




5. Install databases

* On MacOS use the following:

```sh
brew install redis
brew install postgresql
```

* On Ubuntu use the following:

```sh
sudo apt-get install redis
sudo apt-get install postgresql
```

6. Install Bundler
```sh
# install Bundler version specified in Gemfile.lock to avoid conflicts
gem install bundler -v 1.17.3
```

7. Install project dependencies
```sh
bundle (or bundle install)
```

* When installing on Ubuntu, make sure dependencies for all the gems are installed first by running the following

```sh
# For timfel-krb5-auth
sudo apt-get install -y libpam-krb5 libkrb5-dev

# For pg
sudo apt-get install libpq-dev

# Ensuring there is an ExecJS runtime
sudo apt-get install nodejs
```


8. Start Postgres database and ensure it is running on port `5432` (Optional: Download and run with [Postgres.app](https://postgresapp.com/) for Mac OS)

* Use the following to start Postgres on Ubuntu
```sh
sudo /etc/init.d/postgresql start
```

* Before starting the Postgres database on Ubuntu, ensure the `pg_hba.conf` file as located at `/etc/postgresql/<version>/main/pg_hba.conf` (where \<version\> is the version number of Postgres installed) has the following contents (the file has to be edited as root):

```sh
# Database administrative login by Unix domain socket
local   all             postgres                                peer

# TYPE  DATABASE        USER            ADDRESS                 METHOD

# "local" is for Unix domain socket connections only
local   all             all                                     peer
# IPv4 local connections:
host    all             all             127.0.0.1/32            trust
# IPv6 local connections:
host    all             all             ::1/128                 trust
# Allow replication connections from localhost, by a user with the
# replication privilege.
#local   replication     postgres                                peer
#host    replication     postgres        127.0.0.1/32            md5
#host    replication     postgres        ::1/128                 md5
```
* Restart the Postgres server using the following
```sh
sudo service postgresql restart
```

To edit the file use the following:

9. Create and populate databases with sample data

```sh
bundle exec rails db:create

# optional
bundle exec rails db:sample
```

10. Done! Run `foreman start` to begin

### Additional Notes

* Don't `sudo gem install`, as it will install gems in a way that does not work properly with `rbenv`. If using `rbenv` as the version manager, you may need to ensure that proper read/write permissions are granted for `/Users/{user}/.rbenv`

* See db/samples.rb for dev usernames and passwords

## Testing Emails Locally

1. `gem install mailcatcher`
2. Run `mailcatcher` in terminal
3. Visit `http://127.0.0.1:1080`. Emails are routed through to the web interface.

Modify action_mailer config settings in development.rb if needed

## Linting code

Note: Both rubocop and coffeelint are installed directly on your machine, as they are
not required for development, and thus are not specified within the gemfile or node package.

### To lint ruby:

Install rubocop:

`gem install rubocop`

then

`$ rubocop [path/to/file.rb]`

### To lint coffeescript:

Install coffeelint:

`npm install -g coffeelint`

to lint all files in `javascripts/`

`rake lint:js`

to lint a directory:

`coffeelint -f coffeelint.json path/to/directory`

to lint a single file:

`coffeelint -f coffeelint.json path/to/file.coffee`

### To lint javascript:

Install jslint:

`npm install -g eslint`

to lint the javacripts directory:

`eslint ./app/assets/javascripts --ext .js`

## Running specs

To run all of the spec examples, you can run the following (this is also the default rake task):

```sh
bundle exec rails spec
```

To run all of the spec examples with code coverage, you can run the following:

```sh
bundle exec rails spec:coverage
```

## Contributing

1. Clone the repository `git clone https://github.com/UM-USElab/gradecraft-development`
1. Create a feature branch `git checkout -b my-awesome-feature`
1. Code!
1. Commit your changes (small commits please)
1. Push your new branch `git push origin my-awesome-feature`
1. Create a pull request `hub pull-request -b um-uselab:master -h um-uselab:my-awesome-feature`
