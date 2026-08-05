# Clock Divider & Frequency Synthesizer using Verilog HDL

A Verilog HDL project implementing counter-based clock divider circuits and a UART baud rate generator, verified through functional simulation in Xilinx Vivado.

---

## Table of Contents

- [Project Overview](#project-overview)
- [Project Objectives](#project-objectives)
- [What is a Clock Divider?](#what-is-a-clock-divider)
- [Frequency Formula](#frequency-formula)
- [Clock Period Formula](#clock-period-formula)
- [Duty Cycle](#duty-cycle)
- [Even Clock Division](#even-clock-division)
- [Odd Clock Division](#odd-clock-division)
- [What is a Baud Rate Generator?](#what-is-a-baud-rate-generator)
- [Baud Rate Formula](#baud-rate-formula)
- [Implemented Modules](#implemented-modules)
- [Project Folder Structure](#project-folder-structure)
- [Simulation](#simulation)
- [Applications](#applications)
- [Skills Gained](#skills-gained)
- [Future Enhancements](#future-enhancements)
- [Tools Used](#tools-used)
- [Author](#author)

---

## Project Overview

Every digital system is driven by a clock, but a single system clock is rarely sufficient for an entire design. Different peripherals, communication protocols, and control blocks often require clock signals of different frequencies derived from one master oscillator. This project explores that problem at the RTL level by implementing a family of **counter-based clock divider circuits** and a **UART baud rate generator** in Verilog HDL.

Clock division is a foundational concept in FPGA and ASIC design. It underpins communication interfaces such as UART, SPI, and I2C, as well as timers, PWM generators, and frequency synthesizers. Understanding how to generate accurate, glitch-aware divided clocks — and knowing when to avoid generating a second clock altogether — is an essential skill for any digital design engineer.

Each module in this repository is implemented as a synchronous RTL design, paired with a self-checking testbench, and verified using the Vivado Simulator through waveform inspection and counter behavior analysis.

---

## Project Objectives

- Implement synchronous, counter-based clock divider circuits for even and odd division ratios.
- Analyze and derive the resulting duty cycle for each division scheme.
- Design a UART baud rate generator using a clock-enable pulse approach.
- Verify all RTL modules through simulation using individual testbenches.
- Document the underlying digital design theory behind clock division and frequency synthesis.

---

## What is a Clock Divider?

A clock divider is a digital circuit that generates an output clock with a frequency lower than that of its input clock, typically by an integer division factor `N`. Instead of routing the divided signal through a PLL or dedicated clocking hardware, this project uses a **synchronous counter-based approach**, where a counter increments on every rising edge of the input clock and toggles or resets the output signal at defined count values.

| Signal | Description |
|---|---|
| `clk_in` | Input clock signal supplied to the module |
| `clk_out` | Output clock signal, divided in frequency by a factor of `N` |
| `N` | Integer division ratio |

The output clock is always derived synchronously from the input clock domain, meaning every transition of `clk_out` is registered on an edge of `clk_in`. This avoids the glitches that can arise from purely combinational clock division and keeps the design portable across FPGA architectures.

---

## Frequency Formula

The relationship between the input clock frequency and the output clock frequency for a divide-by-N circuit is given by:

$$
F_{out} = \frac{F_{in}}{N}
$$

Where:

- $F_{in}$ is the frequency of the input clock, in Hz
- $F_{out}$ is the frequency of the resulting output clock, in Hz
- $N$ is the integer clock division ratio

**Numerical Example**

For an input clock of 100 MHz divided by 4:

$$
F_{out} = \frac{100 \times 10^{6}}{4} = 25 \text{ MHz}
$$

For an input clock of 50 MHz divided by 5:

$$
F_{out} = \frac{50 \times 10^{6}}{5} = 10 \text{ MHz}
$$

---

## Clock Period Formula

The period of a clock signal is the reciprocal of its frequency:

$$
T = \frac{1}{F}
$$

Where `T` is the clock period in seconds and `F` is the clock frequency in Hz.

**Numerical Example**

For a 100 MHz input clock:

$$
T_{in} = \frac{1}{100 \times 10^{6}} = 10 \text{ ns}
$$

After dividing this clock by 4, the resulting output period becomes:

$$
T_{out} = \frac{1}{25 \times 10^{6}} = 40 \text{ ns}
$$

This confirms that dividing the frequency by `N` multiplies the period by the same factor `N`.

---

## Duty Cycle

Duty cycle describes the proportion of one clock period during which the signal remains logic HIGH. It is expressed as:

$$
\text{Duty Cycle} = \left( \frac{T_{HIGH}}{T_{PERIOD}} \right) \times 100\%
$$

Where `T_HIGH` is the time the signal stays high within one period, and `T_PERIOD` is the total period of the output clock.

**50% Duty Cycle**

```
clk_out  ___     ___     ___
        |   |   |   |   |   |
   _____|   |___|   |___|   |___
```

**40% Duty Cycle**

```
clk_out  __      __      __
        |  |    |  |    |  |
   _____|  |____|  |____|  |____
```

**60% Duty Cycle**

```
clk_out  ____    ____    ____
        |    |  |    |  |    |
   _____|    |__|    |__|    |__
```

A 50% duty cycle is generally the most desirable characteristic for a divided clock, since it produces symmetric high and low phases and simplifies downstream timing analysis.

---

## Even Clock Division

Even division ratios are the simplest to implement because they naturally allow a **toggle-based method**: the output register is inverted at a fixed, evenly spaced count value, producing equal high and low phases.

- **Divide by 2**: The output toggles on every rising edge of the input clock, producing an exact 50% duty cycle.
- **Divide by 4**: A 2-bit counter increments on every input clock edge, and the output toggles once every two counts, again producing a 50% duty cycle.
- **Divide by 8**: A 3-bit counter is used, with the output toggling once every four counts, maintaining a 50% duty cycle.

Because an even division factor can always be split into two equal halves, the toggle method inherently produces an output that is high for exactly `N/2` input clock cycles and low for the remaining `N/2` cycles. This is why even clock dividers naturally generate an approximately (and in this case, exact) 50% duty cycle.

---

## Odd Clock Division

Odd division ratios cannot be split into two equal integer halves, so a single toggle event per half-period is not possible. As a result, **an exact 50% duty cycle cannot be achieved using only one clock edge (the rising edge) of the input clock** for odd values of `N`. Achieving a true 50% duty cycle for odd division typically requires toggling logic on both the rising and falling edges of the input clock, which this project intentionally avoids in order to keep the design fully synchronous to a single clock edge.

**Divide by 3**

A counter cycles through three states (0, 1, 2) on the input clock. The output is held high for one count and low for two counts, resulting in a duty cycle of approximately 33%.

**Divide by 5**

A counter cycles through five states (0 through 4). The output is held high for three counts and low for two counts, resulting in a duty cycle of approximately 60%.

| Division Ratio | Achievable Duty Cycle (single-edge) |
|---|---|
| Divide by 3 | ~33% |
| Divide by 5 | ~60% |

---

## What is a Baud Rate Generator?

A baud rate generator is a timing circuit used in serial communication interfaces, such as UART, to produce a periodic timing reference that matches a target baud rate. Rather than generating an entirely new physical clock domain, this project's baud rate generator produces a **single-clock-cycle enable pulse** at the required baud interval, while the UART transmit and receive logic continue to operate synchronously within the original system clock domain.

This clock-enable approach is strongly preferred in FPGA design over generating a second physical clock for several reasons:

- It avoids introducing an additional clock domain, which would otherwise require careful **Clock Domain Crossing (CDC)** handling, synchronizers, and additional verification effort.
- FPGA clock resources (global clock buffers, PLLs, and clock trees) are limited, and reserving one for every derived timing signal is inefficient.
- A clock-enable pulse allows all downstream logic to remain in a single, well-understood clock domain, simplifying static timing analysis and reducing the risk of metastability.

In this design, the baud rate generator produces a one-cycle-wide `baud_en` pulse once every fixed number of system clock cycles, which other modules can use as a qualifying enable signal on their sequential logic.

---

## Baud Rate Formula

The number of system clock cycles corresponding to one baud period is given by:

$$
\text{Baud Divisor} = \frac{F_{system}}{\text{Baud Rate}}
$$

**Numerical Example**

For a 100 MHz system clock and a target baud rate of 9600:

$$
\text{Baud Divisor} = \frac{100 \times 10^{6}}{9600} \approx 10416
$$

Since the internal counter starts counting from zero, it must count from `0` up to `10415` (a total of 10416 clock cycles) before the `baud_en` pulse is asserted and the counter is reset. Comparing the counter against `10415` rather than `10416` ensures the counter produces exactly 10416 system clock cycles per baud period, since the count value `0` is itself the first cycle in that interval.

---

## Implemented Modules

| Module | Description |
|---|---|
| `clk_div2` | Divide-by-2 clock divider, exact 50% duty cycle |
| `clk_div3` | Divide-by-3 clock divider, approximately 33% duty cycle |
| `clk_div4` | Divide-by-4 clock divider, exact 50% duty cycle |
| `clk_div5` | Divide-by-5 clock divider, approximately 60% duty cycle |
| `clk_div8` | Divide-by-8 clock divider, exact 50% duty cycle |
| `baud_9600` | UART baud rate generator, produces a one-cycle enable pulse every 10416 system clock cycles |

Each module is accompanied by a dedicated testbench and has been functionally verified using the Vivado Simulator.

---

## Project Folder Structure

```
clock-divider-frequency-synthesizer/
│
├── RTL/
│   ├── clk_div2.v
│   ├── clk_div3.v
│   ├── clk_div4.v
│   ├── clk_div5.v
│   ├── clk_div8.v
│   └── baud_9600.v
│
├── Testbench/
│   ├── tb_clk_div2.v
│   ├── tb_clk_div3.v
│   ├── tb_clk_div4.v
│   ├── tb_clk_div5.v
│   ├── tb_clk_div8.v
│   └── tb_baud_9600.v
│
└── README.md
```

---

## Simulation

All RTL modules were functionally verified using the **Xilinx Vivado Simulator**. The verification process for each module included:

- **Functional Verification** — confirming correct output behavior against expected logic for each division ratio.
- **Waveform Verification** — visually inspecting `clk_in` and `clk_out` waveforms in the Vivado waveform viewer to confirm correct toggling behavior.
- **Counter Verification** — checking that internal counters increment correctly and reset at the expected boundary values.
- **Duty Cycle Verification** — measuring high and low phase durations of each output clock to confirm they match the theoretical duty cycle.
- **Baud Pulse Verification** — confirming that `baud_en` asserts for exactly one system clock cycle at the correct interval for a 9600 baud rate.

---

## Applications

The clock division and frequency synthesis techniques demonstrated in this project are directly applicable to:

- UART (Universal Asynchronous Receiver/Transmitter)
- SPI (Serial Peripheral Interface)
- I2C (Inter-Integrated Circuit)
- CAN (Controller Area Network)
- PWM (Pulse Width Modulation) generation
- Timers and watchdog circuits
- Frequency synthesizers
- Embedded systems requiring multiple internal clock domains
- General-purpose FPGA and ASIC digital designs

---

## Skills Gained

- Verilog HDL
- RTL Design
- Sequential Logic Design
- Counter Design
- Clock Division Techniques
- Frequency Synthesis
- Baud Rate Generation
- Testbench Development
- Vivado Functional Simulation
- FPGA Design Fundamentals

---

## Future Enhancements

- Implement a **parameterized clock divider** supporting arbitrary integer division ratios through a single generic module.
- Design a **programmable baud rate generator** with a runtime-configurable divisor register.
- Develop a **glitch-free clock divider** using output-register gating techniques.
- Generalize the design into a **generic frequency divider IP core** reusable across multiple projects.
- Target **FPGA hardware implementation** with on-board verification using an FPGA development board.

---

## Tools Used

| Tool | Purpose |
|---|---|
| Verilog HDL | RTL design language |
| Xilinx Vivado | FPGA design suite |
| Vivado Simulator | Functional simulation and waveform analysis |
| Git | Version control |
| GitHub | Source code hosting and collaboration |

---

## Author

**Naveen A**
B.E. Electrical and Electronics Engineering

Naveen is an aspiring FPGA and digital design engineer with a strong interest in RTL design, digital communication systems, and hardware verification. This project reflects a hands-on approach to understanding clock management techniques that are fundamental to real-world FPGA and ASIC designs, built with an emphasis on clean, synthesizable RTL and thorough functional verification.

---

## License

This project is open-source and available for educational and portfolio purposes. Feel free to fork, study, and build upon it.
