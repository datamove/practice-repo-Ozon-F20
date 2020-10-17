#!/bin/bash

# Get the dir this script lives in
# $0 is the path to the scriup as it's run
dirname=`dirname $0`
cd "$dirname"

# Get scripts arguments (requires two - name and homework code)
NAME=$1
NAME_=$(echo $NAME | tr '-' '_')
HW=$2
CFG_FILE=${3:-hw${HW}.cfg}

# copy deploy key from the student's to my dir
# using sudo, since provate key has read permission for the user only
DEPLOY_KEY_USER=/home/$NAME/.ssh/linux-git1-deploy-key
DEPLOY_KEY=/home/ubuntu/.ssh/id_rsa_deploy_key_${NAME}

if ! sudo cp $DEPLOY_KEY_USER $DEPLOY_KEY
then
	echo No deploy key $DEPLOY_KEY_USER
	exit 1
else
	sudo chown ubuntu:ubuntu $DEPLOY_KEY
	chmod 600 $DEPLOY_KEY
fi


#
# Helpers - provide usefull functions
#
source checker-helpers.sh

#
# Get the homework project config
#
# $TRAIN_PATH etc

#only source config files from the current dir
source `basename $CFG_FILE`

#
# Prepare dirs, clone the repo
#
source checker-prepare.sh

#
# Checks
#
f1=.gitignore

check_exists $f1

check_contains $f1 "__pycache__"

f2=README.md

check_exists $f2

check_contains $f2 '[greetings.py](greetings.py)'


f3=greetings.py

check_exists $f3

greet=$(/usr/bin/python3 $f3 2>&1)

check_notequal $greet "greetings!"

#upload file
#first check that it does not exist already
H1="Accept: application/vnd.github.v3+json"
H2="Authorization: token $GHTK"
UPLOAD_FILE=https://api.github.com/repos/$NAME/$REPO_NAME/contents/PASSED
DATA='"message":"congrats!","content":"Y29uZ3JhdHMhCg=="'

if curl --fail -s -X GET -H "$H1" -H "$H2" $UPLOAD_FILE > /tmp/$NAME
then
	#get sha, add to data
	sha_line=$(cat /tmp/$NAME | grep sha | tr -d ',' )
	DATA=$DATA','$sha_line
fi
#echo H2 $h2 DATA $DATA
#echo curl --fail -s -X PUT -H "$H1" -H "$H2" $UPLOAD_FILE -d '{'"$DATA"'}'
if ! curl --fail -s -S -X PUT -H "$H1" -H "$H2" $UPLOAD_FILE -d '{'"$DATA"'}' >/tmp/curl-upload-$NAME.log
then
	echo Could not upload file to $REPO_NAME
	exit 1
else
	echo Uploaded file to $REPO_NAME. Log in /tmp/curl-upload-$NAME.log
fi


PASSED=1
echo PASSED $PASSED

[[ ${PASSED:=0} -eq 1 && ! -f $HWSTUDENTDIR/_PASSED ]] && echo $next > $HWSTUDENTDIR/_PASSED

TGBANNER="======================= Telegram send ======================================="

[[ ! -z "$TGUSERID" ]] && tg_send "$TGUSERID" "ATTEMPT $next FINISHED\nPASSED $PASSED"

exit


