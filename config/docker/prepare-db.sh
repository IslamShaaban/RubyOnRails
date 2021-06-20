#! /bin/sh

# If the database exists, migrate. Otherwise setup (create and migrate)
bundle exec rake db:create db:migrate
echo "Done!"