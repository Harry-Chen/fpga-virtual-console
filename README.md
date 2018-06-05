# FPGA Console

This project implements a VT102-compatible console with extra color support on Cyclone IV E EP4CE55F23I7. The experimental board has PS/2 keyboard input and HDMI video output, with UART transceiver to communicate with a computer.

The project is developed under Quartus Prime Lite 18.0, we do not provide any warranty for successful compilation on any other software.

## Usage (Arch Linux as example)

1. Compile the project and program the FPGA board.
2. Connect the keyboard and monitor.
3. Connect the FPGA board with PC via a USB-UART cable.
4. Start a serial tty on PC, such as: `systemctl start serial-getty@ttyUSB0.service`.
5. Login, and run `stty cols 100 rows 50` to set display area. Alternatively, you can run `demo/set_vt220.sh` or `demo/set_xterm.sh` to setup necessary environment for VT220 or XTerm-256color mode, respectively.
6. Enjoy it!

## Demostration

There are some fancy commands. For example,

1. Run `demo/asciicam.sh` to display colored video captured from your camera.
2. Run `demo/video.sh [video_path]` to play video from `video_path`.
3. Run `bb` to show an ASCII-art demo.
4. Run `cacafire` to show the colored fire.

## Notice

1. The default baud is 3M, which is not a standard baud. You might need to modify the configuration of `getty` to make it communicate normally with the FPGA. Or you can slow it down in `DataType.svh`, which will leads to bad experiences such as slow refreshing rate.
2. There might be some timing issue with the VGA signal. You can adjust your monitor manually if it doesn't display image as expected.
3. When `TERM=vt220`, there is no color support but everything will work well. When `TERM=xterm-256color`, there is color support, but there might be some strange behaviors for we have not implemented all instructions in that mode.

## Licence

This project is released under GPLv3, see `LICENSE` for legal text.
