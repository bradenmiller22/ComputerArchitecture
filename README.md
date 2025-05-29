# ComputerArchitecture

This repository contains a series of projects completed for a Computer Architecture course focused on digital logic design and processor implementation using Verilog. Each project builds upon the last, starting from simple logic blocks and culminating in a custom-built processor capable of executing a defined instruction set.

## 📁 Repository Structure

```plaintext
ComputerArchitecture/
├── ProjectPart1/     # Basic logic gates, adders, multiplexers
├── part2/            # ALU, register file, basic datapath modules
├── ProjectPart3/     # Complete processor (SISC) and control logic


---

## 🧠 Project Summaries

### 🔹 ProjectPart1: Fundamental Digital Logic

- **Goal**: Implement foundational digital components using Verilog.
- **Components**:
  - Logic gates (AND, OR, XOR, NOT)
  - Half and full adders
  - 4-bit ripple carry adder
  - 2:1 and 4:1 multiplexers
  - D flip-flops and registers
- **Simulation**:
  - Includes testbenches for all modules.
  - Verifies truth tables and propagation delays.

### 🔹 part2: Arithmetic and Datapath Design

- **Goal**: Build essential components of a processor datapath.
- **Key Modules**:
  - 32-bit ALU supporting add, sub, and, or, xor, slt
  - Register file with 32 registers (read/write ports)
  - Sign extender
  - Multiplexers and basic control signals
- **Highlights**:
  - All modules follow modular and hierarchical Verilog design principles.
  - Simulations confirm arithmetic and logic operations.

### 🔹 ProjectPart3: Full Processor Implementation (SISC)

- **Goal**: Design and simulate a functioning Single Instruction Stream Computer (SISC) processor.
- **Features**:
  - Supports a custom instruction set architecture (ISA)
  - Instruction memory and data memory (RAM) models
  - Control unit with state machine and datapath coordination
  - Test programs (e.g., sorting, multiplication)
- **Outputs**:
  - Final Verilog processor capable of running predefined programs from `.data` files.
  - Top-level module simulates fetch–decode–execute cycles.

---

## 🧪 How to Simulate

You can use any Verilog simulator (Icarus Verilog, ModelSim, or Vivado). Here's how to get started:

### 🅰️ Option A: Icarus Verilog

1. Install Icarus Verilog:
    ```bash
    sudo apt install iverilog
    ```
2. Compile and simulate:
    ```iverilog -o sim.out *.v
    vvp sim.out
    ```

3. Optional — View waveform:
    ```bash
    gtkwave dump.vcd
    ```

### 🅱️ Option B: ModelSim

1. Start ModelSim GUI or CLI.

2. **Compile files**:
    ```tcl
    vlog *.v
    ```

3. **Simulate module**:
    ```tcl
    vsim top_module
    ```

4. **Run simulation**:
    ```tcl
    run -all
    ```

---

## 🛠️ Requirements

- Basic Verilog HDL knowledge  
- Verilog simulator (Icarus Verilog, ModelSim, or Xilinx Vivado)  
- Linux/macOS/Windows (any OS with a terminal + simulator)

---

## 📸 Screenshots / Output Examples

Due to CLI-based simulation, output is printed in console logs and testbench VCD waveforms. For full-cycle processor execution traces, see `sisc_tb.v` output logs in `ProjectPart3`.

---

## 📦 Notes

- All modules are written in synthesizable Verilog.
- Tested using both behavioral and structural modeling styles.
- This code was developed using **ModelSim on Windows** and **VS Code with Icarus Verilog on macOS**.
- You may need to update the file paths to your Verilog `.data` memory files in `sisc_tb.v`.

---

## 🧾 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## 🙋‍♂️ Author

Braden Miller  
University of Iowa — Computer Science and Engineering  
[GitHub Profile](https://github.com/bradenmiller22)
