# 🚦 FPGA-Based Traffic Light Controller with Priority System

## Project Overview
A Verilog-based traffic light controller for a 4-way intersection with **emergency vehicle priority override**. The system manages traffic flow between North-South and East-West directions with proper timing for green, yellow, and red states.

## Features
- **Normal Operation:** Alternating green-yellow-red cycles for NS and EW directions
- **Emergency Priority:** Emergency vehicle detection switches all lights to RED
- **Countdown Display:** 7-segment countdown timer for each direction
- **Clock Divider:** Built-in 50 MHz to 1 Hz clock divider
- **Modular Design:** Separate controller, top module, and 7-segment decoder

## System Architecture
```
                    +-----------------------+
                    |   traffic_light_top   |
                    |  (Top Level Module)   |
                    +-----------+-----------+
                                |
                    +-----------+-----------+
                    |                       |
        +-----------v-----------+ +---------v-----------+
        | traffic_light_        | | seven_segment_      |
        | controller            | | decoder (NS)        |
        | (FSM + Timer)        | +---------------------+
        +-----------+-----------+ +---------v-----------+
                    |             | seven_segment_      |
                    |             | decoder (EW)        |
                    +-------------+---------------------+
```

## State Diagram
```
    NS_GREEN ──(timer done)──> NS_YELLOW ──(timer done)──> EW_GREEN
        ^                           |                          |
        |                           |                          |
        |              (emergency)  |              (emergency)  |
        |                           v                          v
        |                       EMERGENCY <────────────────────
        |                           |
        +──(timer done + no emerg.)─+
```

## Files
| File | Description |
|------|-------------|
| `src/traffic_light_controller.v` | Main FSM controller module |
| `src/traffic_light_top.v` | Top-level integration module |
| `src/seven_segment_decoder.v` | BCD to 7-segment decoder |
| `src/traffic_light_controller.xdc` | FPGA pin constraints (Xilinx) |
| `testbench/tb_traffic_light_controller.v` | Comprehensive testbench |

## How to Simulate (ModelSim)
```bash
# Compile
vlog src/traffic_light_controller.v
vlog src/seven_segment_decoder.v
vlog src/traffic_light_top.v
vlog testbench/tb_traffic_light_controller.v

# Simulate
vsim -c tb_traffic_light_controller
run -all

# View waveform
gtkwave traffic_light_controller.vcd
```

## How to Synthesize (Vivado)
1. Create new Vivado project
2. Add all `.v` files from `src/`
3. Add `.xdc` constraints file
4. Run Synthesis → Implementation → Generate Bitstream
5. Program FPGA board

## Hardware Requirements
- FPGA Board (Xilinx Spartan-6 / Artix-7 or compatible)
- 6 LEDs (3 for NS, 3 for EW: Red, Yellow, Green)
- 2x 7-segment displays (optional, for countdown)
- 1 Push button (Emergency)
- 1 Push button (Reset)

## Default Configuration
- **Green Duration:** 10 seconds
- **Yellow Duration:** 3 seconds
- **Emergency Override:** 5 seconds
- **Clock Frequency:** 50 MHz

## Author
VLSI Internship Project - Codec Technologies

## License
Educational use - 2-Month Digital Electronics & VLSI Internship
