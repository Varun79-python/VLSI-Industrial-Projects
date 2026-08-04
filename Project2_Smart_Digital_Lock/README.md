# 🔐 Smart Digital Lock System Using VHDL

## Project Overview
A VHDL-based digital lock system that accepts a **4-digit password** via a 4x4 keypad, displays input on a 7-segment display, alerts on wrong attempts, and includes a **master reset** feature.

## Features
- **4x4 Keypad Interface:** Scans and debounces keypad inputs
- **Password Entry:** Accepts 4-digit numeric password
- **7-Segment Display:** Shows entered digits and status
- **Wrong Attempt Alert:** Buzzer/LED alert on incorrect password
- **Lockout Protection:** 3 wrong attempts → temporary lockout
- **Master Reset:** Emergency reset to initial state
- **Success Indicator:** LED indication when unlocked

## System Architecture
```
                    +-----------------------+
                    | smart_digital_lock    |
                    |  (Top Level Module)   |
                    +-----------+-----------+
                                |
                    +-----------+-----------+
                    |                       |
        +-----------v-----------+ +---------v-----------+
        |  Keypad Scanner       | | State Machine       |
        |  (Debounce + Scan)    | | (FSM Controller)    |
        +-----------+-----------+ +---------+-----------+
                    |                       |
                    +-----------+-----------+
                                |
                    +-----------v-----------+
                    |  Output Logic         |
                    |  (7-seg, LEDs, etc.)  |
                    +-----------------------+
```

## State Diagram
```
    IDLE ──(key press)──> INPUT ──(confirm)──> VERIFY
                                        |           |
                                        |     (correct?)
                                        |       /    \
                                        |      /      \
                                        v     v        v
                                   UNLOCKED  WRONG   LOCKED_OUT
                                        |    ATTEMPT     |
                                        |       |        |
                                        +───────+────────+
                                        (timeout/confirm)
```

## Files
| File | Description |
|------|-------------|
| `src/smart_digital_lock.vhd` | Main VHDL design module |
| `src/smart_digital_lock.xdc` | FPGA pin constraints (Xilinx) |
| `testbench/tb_smart_digital_lock.vhd` | Comprehensive testbench |

## Keypad Layout
```
    Col0  Col1  Col2  Col3
Row0:  1     2     3     A
Row1:  4     5     6     B
Row2:  7     8     9     C
Row3:  *     0     #     D
```

**Default Password:** `1234`

## How to Simulate (ModelSim)
```bash
# Compile
vcom src/smart_digital_lock.vhd
vcom testbench/tb_smart_digital_lock.vhd

# Simulate
vsim -c tb_smart_digital_lock
run -all
```

## How to Synthesize (Vivado)
1. Create new Vivado project
2. Add `smart_digital_lock.vhd` from `src/`
3. Add `.xdc` constraints file
4. Run Synthesis → Implementation → Generate Bitstream
5. Program FPGA board

## Hardware Requirements
- FPGA Board (Xilinx Spartan-6 / Artix-7 or compatible)
- 4x4 Matrix Keypad
- 1x 7-segment display (or 4-digit display)
- 2x Push buttons (Confirm, Master Reset)
- 3x LEDs (Lock status, Wrong alert, Success)
- 1x Buzzer (optional, for wrong attempt alert)

## Security Features
| Feature | Description |
|---------|-------------|
| Password Protection | 4-digit numeric password |
| Attempt Limiting | Max 3 wrong attempts allowed |
| Lockout Timer | 1-second lockout after 3 failures |
| Master Reset | Emergency reset to bypass lockout |
| Debounce | 10ms debounce on all button inputs |

## Default Configuration
- **Password:** `1234` (changeable in code)
- **Max Attempts:** 3
- **Lockout Duration:** 1 second (at 50 MHz)
- **Debounce Time:** 10 ms
- **Clock Frequency:** 50 MHz

## How to Change Password
In `smart_digital_lock.vhd`, modify:
```vhdl
constant CORRECT_PASSWORD : std_logic_vector(15 downto 0) := x"1234";
```
Change `x"1234"` to your desired 4-digit password in hex.

## Author
VLSI Internship Project - Codec Technologies

## License
Educational use - 2-Month Digital Electronics & VLSI Internship
