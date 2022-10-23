#!/bin/env bash

help() {
    cat <<_EOF
    moves file to the $HOME/zap directory

    usage:

      zap <file>
_EOF
}

(( $# < 1 )) && {
    help
    exit 126
}

DIR="$HOME/zap/$(/bin/date +'%Y/%m/%d')"
mkdir -p $DIR
mv "$@" $DIR
