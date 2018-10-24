#!/usr/bin/env bash


# determine the color that text is in
TCOLOR=$(./colors.py $1)

for color in $TCOLOR; do
  #convert leveled.png -fill white +opaque "$SECOND" -fill black -opaque "$SECOND" result.png
  convert $1 -fill white +opaque "#$color" -fill black -opaque "#$color" $2.$color.png
done
