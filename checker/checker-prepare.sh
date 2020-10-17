#
# Prepare dirs
#

# HW dir
[ ! -d hws/$HW ] && mkdir hws/$HW
cd hws/$HW || exit 1

#Student's dir
[ ! -d $NAME ] && mkdir $NAME
cd $NAME || exit 1

#STUDENT DIR
HWSTUDENTDIR=`pwd`

# check if already passed
if [ -f _PASSED ]; then
   echo Already passed on attempt `cat _PASSED`
fi

# Check number of attempts
last=$(ls -1 2>/dev/null | sort -n | tail -1)

: ${last:=0}

next=$(( last + 1 ))

echo ATTEMPT $next

# Attempt workdir
mkdir $next
cd $next || exit 1
#cd $next || ( echo CAN NOT CD to workdir && exit )
#for testing
#cd $last 

#TODO check if allowed more attempts

# start logging
exec 1> >(tee -a log) 2>&1

#
# Check repo private
#
if curl --fail -s -I -L https://api.github.com/repos/$NAME/$REPO_NAME > /dev/null
then
	echo Repo $NAME/$REPO_NAME is not private
	exit 1
fi


#
# Pull student's repo
#
DEPLOY_KEY=${DEPLOY_KEY:-/home/ubuntu/.ssh/id_rsa_deploy_key_${NAME}}
GIT_SSH_OPTS='-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
export GIT_SSH_COMMAND="ssh -i $DEPLOY_KEY $GIT_SSH_OPTS"
echo DEPLOY_KEY=${DEPLOY_KEY:-/home/ubuntu/.ssh/id_rsa_deploy_key_${NAME}}
echo GIT_SSH_COMMAND="ssh -i $DEPLOY_KEY $GIT_SSH_OPTS"
echo git clone git@github.com:${NAME}/${REPO_NAME}.git
git clone git@github.com:${NAME}/${REPO_NAME}.git
exit_status=$?
if [ $exit_status -ne 0 ]; then
  echo "Error cloning the repo"
  exit $exit_status
fi

#cd $REPO_NAME/$PROJECT_PREFIX

#echo WORKDIR `pwd`

echo ATEMPTDIR `pwd`

# check if repo cloned
if [ ! -d $REPO_NAME ]; then
 echo Repo not cloned, exiting
 exit 1
fi

cd $REPO_NAME

echo WORKDIR `pwd`

#
# Get tg user id if supplied
#
TGUSERID=""
[ -f "tguserid" ] && TGUSERID=$(cat "tguserid")



