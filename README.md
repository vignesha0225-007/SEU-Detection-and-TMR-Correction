# SEU Detection and Correction Using Triple Modular Redundancy (TMR)

A SystemVerilog implementation of a Single Event Upset (SEU) detection and recovery system using Triple Modular Redundancy.

## Project overview

The design stores an 8-bit input in three redundant registers (`r1`, `r2`, and `r3`). A bitwise majority voter produces the output. A disagreement signal detects when the three register copies are not identical. When fault injection is disabled, the voted output is written back into all three registers on the next active clock edge.

## Repository structure

```text
SEU-Detection-and-TMR-Correction/
├── RTL/
│   └── design.sv
├── Testbench/
│   └── testbench.sv
├── Simulation/
│   └── simulation_results.txt
├── Images/
│   ├── eda_playground_console.png
│   └── tmr_waveform.png
├── README.md
└── LICENSE
```

## Design details

### Majority voter

The output is calculated bit by bit:

```systemverilog
assign data_out = (r1 & r2) | (r2 & r3) | (r1 & r3);
```

For each bit position, the value held by at least two registers wins.

### Error detection

```systemverilog
assign error = (r1 != r2) || (r2 != r3);
```

The error output is asserted whenever the register copies disagree.

### Recovery

When `error` is asserted and `fault_en` is low, the majority-voted data is written into all three registers at the next rising clock edge:

```systemverilog
{r1, r2, r3} <= {data_out, data_out, data_out};
```

## Verification scenarios

The supplied testbench loads `8'b10110110` into all three registers and injects one bit flip into each register in turn.

| Scenario | Selected register | Bit index |
|---|---:|---:|
| R1 fault | R1 | 2 |
| R2 fault | R2 | 5 |
| R3 fault | R3 | 0 |

The EDA Playground console shows `error=1` for each injected fault. After recovery, each case reports `error=0` and `output=10110110`. The simulator run terminates normally with zero simulation errors; its summary reports one optimization warning from `vopt`. See the [detailed results](Simulation/simulation_results.txt).

## Simulation evidence

### EDA Playground console output

The console capture shows all three fault-detection and recovery messages and the simulator's final run summary.

![EDA Playground console showing SEU detection and recovery results](Images/eda_playground_console.png)

### EPWave timing waveform

The waveform shows the three register copies loaded with `10110110`, diverging during each fault injection, and returning to the common correct value after recovery.

![EPWave waveform showing TMR fault injection and recovery](Images/tmr_waveform.png)

## Running the simulation

The project can be run in a SystemVerilog simulator such as EDA Playground.

1. Add `RTL/design.sv` as the design source.
2. Add `Testbench/testbench.sv` as the testbench.
3. Select a simulator with SystemVerilog support.
4. Run the simulation and inspect the console output.
5. The testbench also requests a waveform dump named `dump.vcd`; waveform generation depends on simulator support and settings.

EDA Playground project: https://edaplayground.com/x/rYD_

## Scope and limitations

- The current testbench exercises one flipped bit in one register at a time.
- TMR can tolerate a single faulty replica when the other two replicas retain the correct value.
- Two or more replicas corrupted in the same bit position can cause an incorrect majority result.
- The error signal detects disagreement, not the physical cause or location of a fault.
- This RTL is a functional demonstration; it does not by itself establish radiation-hardness, FPGA timing, power, or area.

## Future work

- Add assertions and automated self-checking testbench comparisons.
- Test multiple and repeated fault scenarios.
- Add fault-location reporting and more detailed coverage.
- Synthesize the design and document area/timing results.
- Evaluate an FPGA implementation.

## Author

**Vignesh A**  
Electronics and Communication Engineering

---

*The project report, synthesis evidence, and additional test coverage can be added as they are finalized.*

