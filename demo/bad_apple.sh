#!/usr/bin/env sh
stty cols 100 rows 50
TERM="vt220" mplayer -nosub -noautosub -really-quiet -monitorpixelaspect 0.5 -vo aa:eight:extended:driver=curses:contrast=35 "/home/miskcoo/Share/BadApple-dqw19880428.blog.163.com.mkv" 
