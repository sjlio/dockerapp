export APP_PWD=password # Put this in the "zshrc", do not live password in this file.

# Database function.
# -e: let us set environment variable. -P: exposes all of the ports of the pg image to container it links to.
# this set up the database container, create a POSTGRES_USER and PASSWORD env variable
# This container is isolated from everything else. The container "--name" is "app_db". -d: to dettach
# We need to create a container to hold just the data, if we don't want to lose data when or if the database container stop.
# "--volume-from app_data" in the db function is used to link the pg database to the volume app_data where the data will be saved.
db() {
  docker run -P --volumes-from app_data --name app_db -e POSTGRES_USER=app_user -e POSTGRES_PASSWORD=$APP_PWD -d -t postgres:latest
}

# This the action to be called, which is the first argument.
action=$1

# Call the action variable 
${action}

# run "sh script.sh db" to execute the db function. This will install the postgresql database.
# Bellow is the location of all data save in postgresql:schema, tables, everything
# This a containe we are creating just to store the volume, that we will link to the pg database, it will be prsistent.
# Run " docker run -v /var/lib/postgresql/data --name app_data busybox" busybox is a lightweight system.
# Then run the "sh script.sh db" to create the database container, that will look for the app_data volume and link to it.

# NOTE: make sure to remove app_db container if exist and add it after running app_data volume.
# NOTE: don't ever remove the volume "app_data" otherwise all the data will be lost.
