#!/bin/env bash

PG_HOST=${PG_HOST:-"postgres://postgres:postgres@localhost:5432/postgres"}

deps() {
  if ! type -p $1 &> /dev/null 
  then
      echo "'$1' must be installed to run this script."
      exit 126
  fi
}

deps "psql"

help() {
  cat <<_EOF
    Start sql console

    usage: 
      
      sql [<arg> ...]

    commands:

      default                     do: psql

      help                        print help
_EOF
}

case "$1" in
    help)
        help
        ;;
    *)
        psql $PG_HOST ${@:3}
        ;;
esac
