# Secure Digital Voting Machine (Verilog)

A digital voting machine designed in **Verilog HDL** as part of my Digital System Design coursework. The project simulates a secure voting process with vote counting, winner declaration, tie detection, and basic security features such as administrator authentication and invalid vote detection.

## Features

- Vote recording for multiple candidates
- Real-time vote counting
- Winner declaration
- Tie detection
- Administrator authentication
- Invalid vote detection
- Tamper/error indication
- Modular Verilog implementation
- Testbenches covering winner and tie scenarios

## Project Structure

```
.
├── 124cs0034.v          # Main Verilog design
├── Winner_case_tb.v     # Testbench for winner scenario
├── Tie_case_tb.v        # Testbench for tie scenario
```

## Design Overview

The design is divided into different functional modules responsible for:

- Button input handling
- Vote logging
- Mode selection
- Winner calculation
- Displaying voting results

The functionality is verified through dedicated testbenches that simulate different voting conditions.

## Tools Used

- Verilog HDL
- Xilinx Vivado (Simulation)
- Digital Logic Design concepts

## How to Run

1. Open the project in Vivado.
2. Add the Verilog design file and testbench.
3. Set the required testbench as the top module.
4. Run Behavioral Simulation.
5. Observe the waveform to verify the voting process.

## What I Learned

Through this project I gained hands-on experience with:

- Designing digital circuits using Verilog
- Writing combinational and sequential logic
- Building modular hardware designs
- Developing and debugging testbenches
- Understanding how hardware behavior is verified through simulation

## Future Improvements

Some improvements I would like to add in the future are:

- Support for a configurable number of candidates
- FSM-based controller
- Seven-segment display interface
- FPGA implementation
- UART output for vote statistics

---

This project was built as part of my learning in Digital System Design to strengthen my understanding of hardware description languages and digital circuit design.
