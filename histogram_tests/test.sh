#!/usr/bin/env bash


# determine the color that text is in
TCOLOR=$(./colors.py $1)

#convert leveled.png -fill white +opaque "$SECOND" -fill black -opaque "$SECOND" result.png
convert $1 -fill white +opaque "#$TCOLOR" -fill black -opaque "#$TCOLOR" $1.fixed.png
