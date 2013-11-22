#!/bin/bash

log()
{
  echo `date "+%Y.%m.%d %H:%M:%S[$$]:"` $@
}

log_error()
{
  echo -e "\033[1;31m`log $@`\033[1;m" >&2
}


CHAPTERS_DIR=chapters
OUTPUT_DIR=output
TEMP_DIR=build_tmp

export TEMP_DIR

# prepare
if [[ ! -d "$TEMP_DIR" ]]; then
  mkdir "$TEMP_DIR"
fi

if [[ ! -d "$OUTPUT_DIR" ]]; then
  mkdir "$OUTPUT_DIR"
fi

# create chapters include
log "Create chapters include"
ls $CHAPTERS_DIR/*.tex | sort -V | awk '{ printf "\\input{%s}\n", $1}' > $TEMP_DIR/chapters.tex

log "Create pdf from latex"
pdflatex --halt-on-error --output-directory="$OUTPUT_DIR" document.tex > /dev/null
if [[ $? -ne 0 ]]; then
  log_error "Failed to create pdf from latex (see $OUTPUT_DIR/document.log)"
fi

# cleanup
log "Cleanup temporary files"
rm -rf "$TEMP_DIR"
