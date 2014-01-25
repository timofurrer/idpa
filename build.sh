#!/bin/bash

log()
{
  echo `date "+%Y.%m.%d %H:%M:%S[$$]:"` $@
}

log_error()
{
  echo -e "\033[1;31m`log $@`\033[1;m" >&2
}

SECTIONS_DIR=sections
OUTPUT_DIR=output
TEMP_DIR=build_tmp

export TEMP_DIR

build()
{
  # prepare
  if [[ ! -d "$TEMP_DIR" ]]; then
    mkdir "$TEMP_DIR"
  fi

  if [[ ! -d "$OUTPUT_DIR" ]]; then
    mkdir "$OUTPUT_DIR"
  else
    rm -rf "$OUTPUT_DIR/*"
  fi

  # create sections include
  log "Create sections include"
  ls $SECTIONS_DIR/*.tex | sort -V | awk '{ printf "\\input{%s}\n", $1}' > $TEMP_DIR/sections.tex

  log "Create pdf from latex"
  pdflatex --halt-on-error --output-directory="$OUTPUT_DIR" document.tex > /dev/null
  if [[ $? -ne 0 ]]; then
    log_error "Failed to create pdf from latex (see $OUTPUT_DIR/document.log)"
  fi

  # cleanup
  log "Cleanup temporary files"
  rm -rf "$TEMP_DIR"
}

if [ "$1" == "build" ]; then
  build
  exit
fi

subbuilds=". manuals/tor manuals/mailserver manuals/owncloud"
for b in $subbuilds; do
  cd $b
  log "building $b document.tex"
  ./build.sh build
  cp output/document.pdf $OLDPWD/output/`basename $b`.pdf
  cd $OLDPWD
done
