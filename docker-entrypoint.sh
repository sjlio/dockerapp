# First clone the repo that contain the application.
git clone --depth 1 https://github.com/sjlio/dockerapp app

cd app

# If we make any change to the docker entry file, we should build the image again "docker build -t sjl/app ."
source "/usr/local/share/chruby/chruby.sh"
chruby ruby

gem install bundler

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

# From the app/config/secret.yml file
export SECRET_KEY_BASE=$(rake secret)

bundle exec rails server -b 0.0.0.0