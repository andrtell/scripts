#!/bin/env bash

deps() {
  if ! type -p $1 &> /dev/null 
  then
      echo "'$1' must be installed to run this script."
      exit 126
  fi
}

deps "yasm"
deps "ld"

help() {
  cat <<_EOF
    Assembly helper

    usage: 
      
      asm <command> [<arg> ...]

    commands:

      a     <file>      assemble file
      run               assemble and link executable, then run it

      help              print help
_EOF
}

(( $# < 1 )) && {
    help
    exit 126
}

case "$1" in
    obj)
        (( $# != 2 )) && {
            help
            exit 126
        }
        NAME=$(basename $2 .asm)
        yasm -f elf64 -g dwarf2 -l $NAME.lst $2
        ;;
    exe)
        NAME=$(basename $2 .o)
        ld -o $NAME $2
        ;;
    run)
        asm obj $2.asm 
        asm exe $2.o
        ./$2
        ;;
    help)
        help
        ;;
    *)
        help
        exit 126
        ;;
esac

