#!/usr/bin/env sh
stty cols 100 rows 50
TERM="xterm-256color" mplayer -noautosub -really-quiet -monitorpixelaspect 0.5 -vo caca tv:// -tv driver=v4l2:width=640:height=480:device=/dev/video0:fps=25:outfmt=yuy2
