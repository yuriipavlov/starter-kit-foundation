#!/usr/bin/env bash

# Based on https://habr.com/ru/company/redmadrobot/blog/305364/
# https://github.com/renskiy/cron-docker-image
# Thanks to renskiy

# Stop when error
set -e

# setting user for additional cron jobs
case $1 in
-u=*|--user=*)
    crontab_user="-u ${1#*=}"
    shift
    ;;
-u|--user)
    crontab_user="-u $2"
    shift 2
    ;;
-*)
    echo "Unknown option: ${1%=*}" > /dev/stderr
    exit 1
    ;;
*)
    crontab_user=""
    ;;
esac

# adding additional cron jobs passed by arguments
# every job must be a single quoted string and have standard crontab format,
# e.g.: start-cron --user user "0 \* \* \* \* env >> /var/log/cron.log 2>&1"
#{ for cron_job in "$@"; do echo -e ${cron_job}; done } \
#    | sed --regexp-extended 's/\\(.)/\1/g' \
#    | crontab ${crontab_user} -

# start cron
default_crontabs_dir=/etc/crontabs

# Replace env variables with values in sSMTP config
#envsubst < /etc/cron_templates/root > ${CRONTABS_DIR:-$default_crontabs_dir}/root

chown "root:root" ${CRONTABS_DIR:-$default_crontabs_dir}/root

crond -L /var/log/cron.log -c ${CRONTABS_DIR:-$default_crontabs_dir}

# trap SIGINT and SIGTERM signals and gracefully exit
trap "echo \"stopping cron\"; kill \$!; exit" SIGINT SIGTERM

# start "daemon"
while true
do
    cat /var/log/cron.log & wait $!
done