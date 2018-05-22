# FPGA Virtual Console

This project implements a VT102-compatible console on Cyclone IV E EP4CE55F23I7. The experimental board has PS/2 keyboard input and HDMI video output, with UART transceiver to communicate with a Linux computer.

The project is developed under Quartus Prime Lite 18.0, we do not provide any warranty for successful compilation on any other software.

## Usage

1. Compile the project and program the FPGA board
2. Connect the keyboard and monitor
3. Connect the FPGA board and PC with an USB-UART cable
4. Start a serial tty on PC, such as: `systemctl start serial-getty@ttyUSB0.service`  
5. Enjoy it