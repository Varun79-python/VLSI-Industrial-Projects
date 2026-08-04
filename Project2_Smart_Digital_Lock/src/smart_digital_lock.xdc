##==============================================================================
## Constraints File: Smart Digital Lock System
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

## Confirm button
set_property PACKAGE_PIN D12 [get_ports confirm_btn]
set_property IOSTANDARD LVCMOS33 [get_ports confirm_btn]

## Master Reset button
set_property PACKAGE_PIN E12 [get_ports master_reset]
set_property IOSTANDARD LVCMOS33 [get_ports master_reset]

## Keypad Row Inputs (active low)
set_property PACKAGE_PIN H17 [get_ports {keypad_row[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {keypad_row[0]}]
set_property PACKAGE_PIN K15 [get_ports {keypad_row[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {keypad_row[1]}]
set_property PACKAGE_PIN J13 [get_ports {keypad_row[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {keypad_row[2]}]
set_property PACKAGE_PIN N14 [get_ports {keypad_row[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {keypad_row[3]}]

## Keypad Column Outputs (active low)
set_property PACKAGE_PIN R18 [get_ports {keypad_col[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {keypad_col[0]}]
set_property PACKAGE_PIN V17 [get_ports {keypad_col[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {keypad_col[1]}]
set_property PACKAGE_PIN U16 [get_ports {keypad_col[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {keypad_col[2]}]
set_property PACKAGE_PIN E19 [get_ports {keypad_col[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {keypad_col[3]}]

## 7-Segment Display (active low)
set_property PACKAGE_PIN U19 [get_ports {seg_display[0]}]  ;# a
set_property IOSTANDARD LVCMOS33 [get_ports {seg_display[0]}]
set_property PACKAGE_PIN V19 [get_ports {seg_display[1]}]  ;# b
set_property IOSTANDARD LVCMOS33 [get_ports {seg_display[1]}]
set_property PACKAGE_PIN W18 [get_ports {seg_display[2]}]  ;# c
set_property IOSTANDARD LVCMOS33 [get_ports {seg_display[2]}]
set_property PACKAGE_PIN U15 [get_ports {seg_display[3]}]  ;# d
set_property IOSTANDARD LVCMOS33 [get_ports {seg_display[3]}]
set_property PACKAGE_PIN U14 [get_ports {seg_display[4]}]  ;# e
set_property IOSTANDARD LVCMOS33 [get_ports {seg_display[4]}]
set_property PACKAGE_PIN V14 [get_ports {seg_display[5]}]  ;# f
set_property IOSTANDARD LVCMOS33 [get_ports {seg_display[5]}]
set_property PACKAGE_PIN V13 [get_ports {seg_display[6]}]  ;# g
set_property IOSTANDARD LVCMOS33 [get_ports {seg_display[6]}]

## Digit Select (active low)
set_property PACKAGE_PIN V10 [get_ports {digit_select[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {digit_select[0]}]
set_property PACKAGE_PIN V11 [get_ports {digit_select[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {digit_select[1]}]
set_property PACKAGE_PIN V12 [get_ports {digit_select[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {digit_select[2]}]
set_property PACKAGE_PIN V9  [get_ports {digit_select[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {digit_select[3]}]

## Status LEDs
set_property PACKAGE_PIN H15 [get_ports lock_status]
set_property IOSTANDARD LVCMOS33 [get_ports lock_status]

set_property PACKAGE_PIN J13 [get_ports wrong_alert]
set_property IOSTANDARD LVCMOS33 [get_ports wrong_alert]

set_property PACKAGE_PIN K15 [get_ports success_led]
set_property IOSTANDARD LVCMOS33 [get_ports success_led]
