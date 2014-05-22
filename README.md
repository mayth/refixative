[![Build Status](https://travis-ci.org/mayth/refixative.png?branch=next)](https://travis-ci.org/mayth/refixative)

Refixative NEXT
===============

REFLEC BEAT colette score tool next version.

Refixative is licensed under The MIT License. See 'LICENSE'.

Requirements
------------
Refixative requires these softwares:

* Ruby 2.1.1
* Bundler
* PostgreSQL

In addition, musics data is required. It must be added to the database before this app runs. 

Setup
-----

1. Clone the repository and checkout `next` branch.
2. Install gems
3. Modify `config/database.yml` to fit your environment
4.
5. Setup DB (`bin/rake db:create db:migrate db:seed`)
6. Start the Rails server
7. Open `http://localhost:3000` with the browser.