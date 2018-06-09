#!/usr/bin/env sh
stty cols 100 rows 50
TERM="xterm-256color" mplayer -noautosub -really-quiet -monitorpixelaspect 0.666 -vo caca tv:// -tv driver=v4l2:width=800:height=600:device=/dev/video0:fps=30:outfmt=yuy2
