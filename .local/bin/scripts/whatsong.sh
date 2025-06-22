#!/bin/bash

title=$(playerctl metadata title)
artist=$(playerctl metadata artist)

final="${title} - ${artist}"

echo $final
