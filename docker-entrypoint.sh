# First clone the repo that contain the application.
git clone --depth 1 https://github.com/sjlio/dockerapp app

cd app

bundle install --without=development,test
bundle exec rake db:migrate
# Pick up on the status of the command above, if it return anything other than zero meaning that it has error
# then we will run rake db;setup first, and then the migration
if [[ $? != 0 ]]; then
  echo
  echo "== Failed to migrate. Running setup first."
  echo
  bundle exec rake db:setup && \
  bundle exec rake db:migrate
fi

bundle exec rails server