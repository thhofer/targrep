#! /bin/bash
# This utility function searches for a given pattern within recursive tarballs
# Within a single tarball, this can be achieved using `zgrep -a pattern archive.tar`
# However, when a tarball may contain other tarballs, it can be more tricky to obtain

#####################################################################################
# SAMPLE USE CASE                                                                   #
# ---------------                                                                   #
# Given a tarball with following structure                                          #
#===================================================================================#
# parent.tar                                                                        #
# - child1.tar                                                                      #
#   - subchild1-1.tar                                                               #
#     - path/to/file1.text                                                          #
#     - ...                                                                         #
#   - subchild1-2.tar                                                               #
#     - ...                                                                         #
# - child2.tar                                                                      #
#   - subchild2-1.tar                                                               #
#     - path/to/otherfile.text                                                      #
#     - ...                                                                         #
# - folder/otherfile.log                                                            #
#===================================================================================#
# We want to know which files contain the string "ERROR"                            #
#===================================================================================#
# The function can be imported in the shell session with:                           #
# $ source targrep.sh                                                               #
# And then called as:                                                               #
# $ targrep "ERROR" EvotingSetup-05.02.00.10-201606VP-prod1-update.tar              #
#####################################################################################

targrep() {
  # List all files within a tarball file
  listFilesInTarFile() {
    if [[ $# -ge 2 ]]; then
      tar xOf $1 $2 | listFilesInTar "${@:3}"
    else
      tar tf $1
    fi
  }

  # List all files within a tarball read from stdin
  listFilesInTar() {
    if [[ $# -gt 1 ]]; then
      tar xO $1 | listFilesInTar "${@:2}"
    elif [[ $# -eq 1 ]]; then
      tar xO $1 | tar t
    else
      tar t
    fi
  }

  # Extract a tarball file to stdout
  extractTarFile() {
    if [[ $# -gt 2 ]]; then
      tar xOf $1 $2 | extractTar "${@:3}"
    elif [[ $# -eq 2 ]]; then
      tar xOf $1 $2
    else
      tar xOf $1
    fi
  }

  # Extract a tarball read from stdin to stdout
  extractTar() {
    if [[ $# -gt 1 ]]; then
      tar xO $1 | extractTar "${@:2}"
    elif [[ $# -eq 1 ]]; then
      tar xO $1
    else 
      cat
    fi
  }

  # Recursively open successive levels of tarballs to grep the files contained for the pattern searched
  recursiveTargrep() {
    local pattern=$1
    local tarfile=$2
    
    while read filename; do
      case "$filename" in
        *.tar) recursiveTargrep "$@" $filename
        ;;
        *)  extractTarFile $tarfile "${@:3}" $filename \
            | grep --color=always -n "$pattern" \
            | sed "s|^|$filename:|";
        ;;
      esac
    done < <(listFilesInTarFile "${@:2}" | grep -v '/$')
  }

  # store the pattern to persist it through shifting of the arguments
  local pattern=$1

  if [[ ! -f "$2" ]]; then
    echo "Usage: targrep pattern file"
    echo "\t can be call with multiple files too, e.g."
    echo "\t targrep pattern file1 file2 ..."
  fi

  while [[ -n "$2" ]]; do
    
    if [[ ! -f "$2" ]]; then
      echo "targrep: $2: No such file" >&2
    fi

    recursiveTargrep $pattern $2

    shift
  done
}

