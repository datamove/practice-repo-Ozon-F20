#
# Helpers
#
tg_send () {
  /usr/local/sbin/telegram-notify --user "$1" --text "$2"
}

#
# Check files in the repo
#
check_exists() {
if [ ! -f $1 ]
then
        echo "No $1 file in the repo"
        exit 1
fi
}

#
# File contains string
#
check_contains() {
if ! grep -F "$2" $1
then
        what="$2"
        echo "File $1 does not contain $what"
        exit 1
fi
}

# 
# String not equal
#
check_notequal() {
if [ "$1" != "$2" ]
then
        echo "Got $1 instead of $2"
        exit 1
fi
}


