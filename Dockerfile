# The docker image is base on ubuntu 14.04
FROM ubuntu:trusty 
MAINTAINER Serge J LaPorte <sjl@sjl.io>

# Remove sh, simlink bash to bin/sh, so we can keep using bash instead of the default.
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Debian complains about the terminal environment on Docker. Use this.
# Tell the docker image that we are going to use non-interactive mode.
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Install base packages: update, upgrade, install: curl, wget, and others
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y curl wget ca-certificates build-essential autoconf python-software-properties libyaml-dev

# Install nginx repositories
RUN wget http://nginx.org/keys/nginx_signing.key
RUN apt-key add nginx_signing.key
RUN echo "deb http://nginx.org/packages/ubuntu/ trusty nginx" >> /etc/apt/sources.list.d/nginx.list
RUN echo "deb-src http://nginx.org/packages/ubuntu/ trusty nginx" >> /etc/apt/sources.list.d/nginx.list

# Finish installing remaining dependencies.
RUN apt-get update -y
RUN apt-get install -y libssl-dev libreadline6 libreadline6-dev zlib1g zlib1g-dev bison openssl make git libpq-dev libsqlite3-dev nodejs nginx
# Clean the cluder from the installation to reduce the file size.
RUN apt-get clean

# Force sudoers to not being asked the password, by echo %sudo in the etc/sudoers file.
# Make it that sudo user dont have to use password.
RUN echo %sudo        ALL=NOPASSWD: ALL >> /etc/sudoers

# Download and install "Ruby-install"
RUN wget -O ruby-install-0.6.0.tar.gz https://github.com/postmodern/ruby-install/archive/v0.6.0.tar.gz && tar -xzvf ruby-install-0.6.0.tar.gz && cd ruby-install-0.6.0/ && make install

# Download and install change ruby "chruby", a ruby version manager.
RUN wget -O chruby-0.3.9.tar.gz https://github.com/postmodern/chruby/archive/v0.3.9.tar.gz && tar -xzvf chruby-0.3.9.tar.gz && cd chruby-0.3.9/ && make install

# Remove all the content from the package cache, apt and tmp folders to decrease the file size.
RUN rm -rf /var/cache/apt/* /tmp/*

# Add a new user for the application.
# Add a user "app" and add it to the "sudo" group. -m create a home directory for the user.
RUN useradd -m -G sudo app

# Switch to "app" user
USER app

# Set the directory to app directory, tilda "~" don't work in dockerfile
WORKDIR /home/app

# Install a Ruby version inside the app user, and remove the source code "src" for that ruby version. 
RUN ruby-install ruby
RUN rm -rf /home/app/src

# Add docker-entrypoint.sh and the setup.sh file to the home/app folder in the container for deployment 
ADD docker-entrypoint.sh /home/app/docker-entrypoint.sh
ADD setup.sh /home/app/setup.sh
ADD nginx.conf /home/app/nginx.conf

# Set the rails_env environment variable to production.
ENV RAILS_ENV=production

# Expose the server tcp port 80 inside in out
EXPOSE 80:80

# This will execute anything inside docker-entrypoint file.
# Entrypoint will run when we use " docker run -t e02e811dd08f " without a suffix.
ENTRYPOINT /home/app/docker-entrypoint.sh





