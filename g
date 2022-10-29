#!/bin/env bash

GOT_HOME=$HOME/.got

deps() {
  if ! type -p $1 &> /dev/null 
  then
      echo "'$1' must be installed to run this script."
      exit 126
  fi
}

deps "git"

help() {
  cat <<_EOF
    A restricted subset of git

    usage: 
      
      g <command> [<arg> ...]

    commands:

      ls                          list local branches
      new                         create a new branch (from main)
      clean                       remove all branches fully merged with main
      main                        switch to main branch
      switch       <branch>       switch to <branch> (defaults to main)
      add                         add all unchanged or new files to the index
      commit                      commit
      amend                       amend last commit
      merge        <branch>       merge current branch with <branch>
      push                        push current branch
      status                      show status

      help                        print help
_EOF
}

init_got () {
  mkdir -p $GOT_HOME
  if [ ! -f $GOT_HOME/.bcount ]; then
    echo '1' > $GOT_HOME/.bcount
  fi
}

branch_inc () {
  local i=$(cat $GOT_HOME/.bcount) 
  local j=$(expr $i + 1)
  echo "$j" > $GOT_HOME/.bcount
  echo "$i"
}

check_if_dirty_or_untracked () {
  if [[ ! -z "$(git diff HEAD)" ]] || [[ ! -z "$(git status --short)" ]]; then
    echo "working directory is DIRTY or has UNTRACKED files"
    echo ""
    git status
    exit 126
  fi
}

if [[ "$1" == "init" ]]; then
  init_got
  exit 0
fi

if [[ ! -d $GOT_HOME ]]; then
  echo "please run: got init"
  exit 126
fi

(( $# < 1 )) && {
    help
    exit 126
}

case "$1" in
  ls)
    git branch --list
    ;;
  new)
    check_if_dirty_or_untracked
    NEW_BRANCH=${3:-"pr-$(branch_inc)"}
    git branch $NEW_BRANCH main
    git switch $NEW_BRANCH
    ;;
  rm)
    (( $# < 2 )) && {
        help
        exit 126
    }
    REMOVE_BRANCH=$2
    git branch -d $REMOVE_BRANCH 2> /dev/null
    ;;
  clean)
    for branch in $(git branch --format='%(refname:short)' | grep -v -e 'main'); do 
      if [[ ! $(git branch -d $branch 2> /dev/null) ]]; then 
        echo "skipped: $branch"
      fi
    done  
    ;;
  switch)
    check_if_dirty_or_untracked
    BRANCH=${2:-main}
    git switch $BRANCH
    ;;
  main)
    check_if_dirty_or_untracked
    git switch main
    ;;
  add)
    git add .
    ;;
  commit)
    git commit
    ;;
  amend)
    git commit --amend
    ;;
  push)
    check_if_dirty_or_untracked
    git push --set-upstream origin $(git branch --show-current)
    ;;
  merge)
    (( $# < 2 )) && {
        help
        exit 126
    }
    check_if_dirty_or_untracked
    WITH_BRANCH=$2
    git merge $WITH_BRANCH
    ;;
  status)
    git status
    ;;
  help)
    help
    ;;
  *)
    help
    exit 126
  ;;
esac
