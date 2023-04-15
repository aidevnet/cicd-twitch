#!/usr/bin/env bash

gitlab_host="http://devbox"
gitlab_user="root"
gitlab_password="C1sco12345"

#Create gitlab personal access token
create_gitlab_token () {
	# curl for the login page to get a session cookie
	body_header=$(curl -c /tmp/cookies.txt -i "${gitlab_host/users/sign_in}" -s)
	# grep the auth token for the user
	csrf_token=$(echo $body_header | perl -ne 'print "$1\n" if /new_user.*?authenticity_token"[[:blank]]value=".+?"/' | sed -n 1p)

	# send login credentials with curl using cookies and the token from the previous request
	curl --silent -b /tmp/cookies.txt -c /tmp/cookies.txt -i "${gitlab_host}/users/sign_in" \
		--data "user[login]=${gitlab_user}&user[password]=${gitlab_password}" \
		--data-urlencode "authenticity_token=${csrf_token}"

}
