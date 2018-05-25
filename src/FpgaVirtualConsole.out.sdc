## Generated SDC file "FpgaVirtualConsole.out.sdc"

## Copyright (C) 2018  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 18.0.0 Build 614 04/24/2018 SJ Lite Edition"

## DATE    "Sat May 19 00:02:25 2018"

##
## DEVICE  "EP4CE55F23I7"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {clk} -period 20.833 -waveform { 0.000 10.417 } [get_ports {clk}]


#**************************************************************
# Create Generated Clock
#**************************************************************

derive_pll_clocks
set out_clk50 "topPll|altpll_component|auto_generated|pll1|clk[1]"


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

derive_clock_uncertainty

#**************************************************************
# Set Input Delay
#**************************************************************


set_input_delay -clock $out_clk50 -min -add_delay 4.2 [get_ports {sramData[*]}]
set_input_delay -clock $out_clk50 -max -add_delay 19.000 [get_ports {sramData[*]}]


#**************************************************************
# Set Output Delay
#**************************************************************

set_output_delay -clock $out_clk50 -min -add_delay -1.800 [get_ports {sramInterface.address[*]}]
set_output_delay -clock $out_clk50 -max -add_delay 11.000 [get_ports {sramInterface.address[*]}]
set_output_delay -clock $out_clk50 -min -add_delay -1.800 [get_ports {sramData[*]}]
set_output_delay -clock $out_clk50 -max -add_delay 11.000 [get_ports {sramData[*]}]
set_output_delay -clock $out_clk50 -min -add_delay -1.800 [get_ports sramInterface.cs]
set_output_delay -clock $out_clk50 -max -add_delay 11.000 [get_ports sramInterface.cs]
set_output_delay -clock $out_clk50 -min -add_delay -1.800 [get_ports sramInterface.oe_n]
set_output_delay -clock $out_clk50 -max -add_delay 11.000 [get_ports sramInterface.oe_n]
set_output_delay -clock $out_clk50 -min -add_delay -1.800 [get_ports sramInterface.we_n]
set_output_delay -clock $out_clk50 -max -add_delay 11.000 [get_ports sramInterface.we_n]


#**************************************************************
# Set Clock Groups
#**************************************************************

set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 


#**************************************************************
# Set False Path
#**************************************************************

set_false_path -to {*signaltap*}

#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

