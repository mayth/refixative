[![Build Status](https://travis-ci.org/mayth/refixative.png?branch=next)](https://travis-ci.org/mayth/refixative)

Refixative-plus
===============

REFLEC BEAT colette score tool next version.

Refixative is licensed under The MIT License. See 'LICENSE'.

Requirements
------------
Refixative requires these softwares:

* Ruby 2.1
* Bundler
* PostgreSQL (for development/production)
* SQLite3 (for testing)
* memcached

In addition, musics data is required. It must be added to the database before this app runs. 

Setup
-----

Clone the repository and checkout `next` branch.

    git clone git@github.com:mayth/refixative.git
    git checkout next

Next, install gems and make 'springified' binstubs. (See: [rails/spring](https://github.com/rails/spring) on github)

    bundle install --path vendor/bundle
    bundle exec spring binstub --all

After that, modify `config/database.yml` to fit your environment. And, do

    bin/rake RAILS_ENV=development db:create
    bin/rake RAILS_ENV=development db:migrate
    bin/rake RAILS_ENV=development db:seed
    bin/rails s

Open `http://localhost:3000` with the browser.

Heroku
------

Set these environment variables:

* `SECRET_KEY_BASE`
