#!/bin/sh

if [ -z $1 ]; then
	echo "Usage: startjob.sh <RAILS_ENV>"
	echo "Where <RAILS_ENV> can be: development, test, production"
	exit
fi

/usr/bin/env RAILS_ENV=$1 ./script/delayed_job start
