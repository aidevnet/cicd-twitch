#!/usr/bin/env bash

gitlab_host="http://10.211.55.7"
gitlab_user="root"
gitlab_password="C1sco12345"
gitlab_wait_time=25

#print colored text
success () {
     COLOR="92m"; # green
     STARTCOLOR="\e[$COLOR";
     ENDCOLOR="\e[0m";
     printf "$STARTCOLOR%b$ENDCOLOR" "done\n";
}

echo ""
printf "Launching GitLab CE..."
docker compose up -d 2> gitlab_setup.log
success

printf "Waiting for GitLab CE to become available..."

until $(curl --output /dev/null --silent --head --fail ${gitlab_host}); do
	printf '.'
	sleep 10
done
success

printf "Configuring external URL for GitLab..."
docker compose exec gitlab /bin/bash -c "echo external_url \'${gitlab_host}' >> /etc/gitlab/gitlab.rb"
docker compose exec gitlab gitlab-ctl reconfigure 2>&1 >> gitlab_setup.log
success

printf "Registering GitLab Runner, waiting ${gitlab_wait_time} seconds for GitLab to become available..."
sleep ${gitlab_wait_time}
docker compose exec runner1 gitlab-runner register 2>&1 >> gitlab_setup.log
