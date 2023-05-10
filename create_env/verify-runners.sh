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

  	# send curl GET request to personal access token page to get auth token
  	body_header=$(curl -L --silent -H 'user-agent: curl' -b /tmp/cookies.txt -i "${gitlab_host}/profile/personal_access_tokens" -s)
  	csrf_token=$(echo $body_header | perl -ne 'print "$1\n" if /authenticity_token"[[:blank:]]value="(.+?)"/' | sed -n 1p)

  	# curl POST request to send the "generate personal access token form"
  	# the response will be a redirect, so we have to follow using `-L`
  	body_header=$(curl --silent -L -b /tmp/cookies.txt "${gitlab_host}/profile/personal_access_tokens" \
        --data-urlencode "authenticity_token=${csrf_token}" \
        --data 'personal_access_token[name]=golab-generated&personal_access_token[expires_at]=&personal_access_token[scopes][]=api')

  	personal_access_token=$(echo $body_header | perl -ne 'print "$1\n" if /created-personal-access-token"[[:blank:]]value="(.+?)"/' | sed -n 1p)	
}

create_gitlab_token &> /dev/null
curl -L --header "PRIVATE-TOKEN: $personal_access_token" "$gitlab_host/api/v4/runners/all"
echo