#!/bin/bash

COVER="/tmp/album_cover.png"

function add_cover {
  # ImageLayer::add [identifier]="img" [x]="2" [y]="1" [path]="$COVER"
  kitten icat --place "2x1@2x1" "$COVER"
}

ImageLayer 0< <(
if [ ! -f "$COVER" ]; then
  cp "$HOME/.ncmpcpp/default_cover.png" "$COVER"
fi
while inotifywait -q -q -e close_write "$COVER"; do
  add_cover
done
)

