#!/usr/bin/python3

fgs = list(range(30, 38)) + list(range(90, 98))
bgs = list(range(40, 48)) + list(range(100, 108))
effect = [0, 4, 7, 1, 5]

for fg in fgs:
    for i, bg in enumerate(bgs):
        print('\033[%d;%d;%dmABCD\033[0m' % (effect[i % 5], fg, bg), end='')
    print('')
