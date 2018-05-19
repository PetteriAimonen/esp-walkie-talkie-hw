#!/bin/bash -x

PROJECT=$( ls *.pro | head -n 1 )

mkdir -p images
rm -f images/*.png images/*.pdf

for SHEET in *.sch
do eeplot -s 4 -o images/${SHEET%.*}.png $PROJECT $SHEET
done

eeplot -o images/${PROJECT[0]%.*}_schematics.pdf $PROJECT

BASE=${PROJECT%.*}
BOARD=$BASE.kicad_pcb

python plot_assembly.py $BOARD
python plot_gerbers.py $BOARD

gerbv -D 600 -a -x png -o images/${BASE}_top.png \
    -f '#000000ff' gerbers/$BASE.TXT \
    -f '#ffffffaa' gerbers/$BASE.GTO \
    -f '#ff880088' gerbers/$BASE.GTS \
    -f '#008800ff' gerbers/$BASE.GTL \
    -f '#aaaaaaff' gerbers/$BASE.GML

gerbv -D 600 -a -x png -o images/${BASE}_bottom.png \
    -f '#000000ff' gerbers/$BASE.TXT \
    -f '#ffffffaa' gerbers/$BASE.GBO \
    -f '#ff880088' gerbers/$BASE.GBS \
    -f '#008800ff' gerbers/$BASE.GBL \
    -f '#aaaaaaff' gerbers/$BASE.GML

for SHEET in bom/*.gnumeric
do ssconvert -T Gnumeric_html:xhtml $SHEET ${SHEET%.*}.html
done

