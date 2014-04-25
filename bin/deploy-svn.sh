#!/bin/sh -x
set -e

name="$1"
path="$2"

if test "x$name" = x; then
	echo "No name set" >&2
	echo "USAGE: $0 APPNAME PATH" >&2
	exit 1
fi

if test -d "$path"; then
	:
else
	echo "$path: does not exist" >&2
	echo "USAGE: $0 APPNAME PATH" >&2
	exit 1
fi

# before_rev and current_rev
cd "$path"
before_rev="$(svnversion .|grep -oE '^[0-9]+')"
svn up
current_rev="$(svnversion .|grep -oE '^[0-9]+')"

# host
host="$(hostname -f)"

# changelog
changelog=''
if test "x$before_rev" = "x$current_rev"; then
	echo 'No changes done. No deployment.' >&2
	exit 1
else
	changelog="$(svn log -r "$before_rev:$current_rev")"
fi

# description
description="Deployed upgrade from $before_rev to $current_rev"

# Deploy to newrelic
nor-newrelic --user="$USER@$host" --revision="$current_rev" --description="$description" --app-name="$name" --changelog="$changelog" deploy

# EOF
