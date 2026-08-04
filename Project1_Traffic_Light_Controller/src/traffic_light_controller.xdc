##==============================================================================
## Constraints File: Traffic Light Controller
## Target: Xilinx Spartan-6 / Artix-7 FPGA Board
## Pin assignments - adjust for your specific board
##==============================================================================

## Clock signal (50 MHz)
set_property PACKAGE_PIN E3 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 20.00 -waveform {0 10} [get_ports clk]

## Reset button (active low)
set_property PACKAGE_PIN C12 [get_ports rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]

## Emergency button
set_property PACKAGE_PIN D12 [get_ports emergency]
set_property IOSTANDARD LVCMOS33 [get_ports emergency]

## North-South Traffic Lights
set_property PACKAGE_PIN H17 [get_ports {ns_light[2]}]  ;# NS Red
set_property IOSTANDARD LVCMOS33 [get_ports {ns_light[2]}]
set_property PACKAGE_PIN K15 [get_ports {ns_light[1]}]  ;# NS Yellow
set_property IOSTANDARD LVCMOS33 [get_ports {ns_light[1]}]
set_property PACKAGE_PIN J13 [get_ports {ns_light[0]}]  ;# NS Green
set_property IOSTANDARD LVCMOS33 [get_ports {ns_light[0]}]

## East-West Traffic Lights
set_property PACKAGE_PIN N14 [get_ports {ew_light[2]}]  ;# EW Red
set_property IOSTANDARD LVCMOS33 [get_ports {ew_light[2]}]
set_property PACKAGE_PIN R18 [get_ports {ew_light[1]}]  ;# EW Yellow
set_property IOSTANDARD LVCMOS33 [get_ports {ew_light[1]}]
set_property PACKAGE_PIN V17 [get_ports {ew_light[0]}]  ;# EW Green
set_property IOSTANDARD LVCMOS33 [get_ports {ew_light[0]}]

## NS Countdown Display (4-bit to 7-segment decoder)
set_property PACKAGE_PIN U16 [get_ports {ns_count[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ns_count[3]}]
set_property PACKAGE_PIN E19 [get_ports {ns_count[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ns_count[2]}]
set_property PACKAGE_PIN U19 [get_ports {ns_count[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ns_count[1]}]
set_property PACKAGE_PIN V19 [get_ports {ns_count[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ns_count[0]}]

## EW Countdown Display (4-bit to 7-segment decoder)
set_property PACKAGE_PIN W18 [get_ports {ew_count[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ew_count[3]}]
set_property PACKAGE_PIN U15 [get_ports {ew_count[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ew_count[2]}]
set_property PACKAGE_PIN U14 [get_ports {ew_count[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ew_count[1]}]
set_property PACKAGE_PIN V14 [get_ports {ew_count[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ew_count[0]}]
