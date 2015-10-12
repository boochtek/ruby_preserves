#!/bin/bash

case "$(uname)" in
Darwin)
	brew install postgresql
	ln -sfv /usr/local/opt/postgresql/*.plist ~/Library/LaunchAgents
	launchctl load ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist
	bundle --path vendor/bundle
	createdb 'preserves_test'
	;;
*)
	echo "Don't know how to install on this system. Please submit a pull request."
	exit
	;;
esac
