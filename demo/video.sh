#!/usr/bin/env sh
stty cols 100 rows 50
TERM="xterm-256color" mplayer -noautosub -really-quiet -monitorpixelaspect 0.5 -vo caca $1
