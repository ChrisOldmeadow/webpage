#!/bin/bash
# Created by Jacob Strieb


# Global variables
# TODO: Implement as arguments
RES_DIR="resources"
SITE_DIR="../personal-site-simple"
SRC_DIR="md"

# Pandoc executable
PANDOC=pandoc


# Exit immediately if anything fails
set -e


# If pandoc isn't installed, abort
if ! which $PANDOC > /dev/null; then
  PANDOC=pandoc
  if ! which $PANDOC > /dev/null; then
    echo \
  "Pandoc must be installed to use this script. To install it on a Debian-based
  Linux computer (e.g., Ubuntu), do:   sudo apt install pandoc"
    exit
  fi
fi


# Find all markdown (md) files to convert
MD_FILES=$(find $SRC_DIR -name "*.md")


# Loop over each md file, converting if necessary
for MD in $MD_FILES; do
  # Get the name of the file and directory to create
  HTML=$(echo $MD | sed "s:$SRC_DIR/:$SITE_DIR/:" | sed "s/\.md$/\.html/")
  DIR=$(echo $HTML | sed "s:/[^/]*\.html$:/:")

  # Make the directory if it doesn't already exist
  if [ ! -d "$DIR" ]; then
    echo Creating directory "$DIR"
    mkdir -p $DIR
  fi

  # Convert the file if the HTML doesn't exist or is older than the markdown
  if [ ! -f $HTML ] || [ $MD -nt $HTML ] || [ $RES_DIR -nt $HTML ]; then
    echo "Converting file $MD -> $HTML"
    $PANDOC \
      --standalone \
      --css=/style.css \
      --highlight-style=$RES_DIR/code-highlight.theme \
      --variable=lang:en \
      --include-before-body=$RES_DIR/navbar.html \
      --include-after-body=$RES_DIR/footer.html \
      --template=$RES_DIR/template.html \
      $MD -o $HTML
  fi
done


# Copy miscellaneous non-markdown files that don't need conversion, skip
# temporary vim swap files (*.swp and *.swo)
MISC_RES=$(find $SRC_DIR -name "*" \
            | grep -v '\.md$' \
            | grep -v '\.swp$' \
            | grep -v '\.swo$' \
            | grep -v '\.bak$')
for RES in $MISC_RES; do
  if [ -d $RES ]; then continue; fi

  # Get the name of the destination and its directory
  DEST=$(echo $RES | sed "s:$SRC_DIR/:$SITE_DIR/:")
  DIR=$(echo $DEST | sed "s:/[^/]*$:/:")

  # Make the directory if it doesn't already exist
  # TODO: Fix error copying files with spaces
  if [ ! -d "$DIR" ]; then
    echo Creating directory "$DIR"
    mkdir -p $DIR
  fi

  # Move the resource if it doesn't exist or is newer than the destination
  if [ ! -f $DEST ] || [ $RES -nt $DEST ]; then
    echo "Copying resource $RES -> $DEST"
    cp $RES $DEST
  fi
done
