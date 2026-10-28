# Verilog UART Transceiver

A parameterized 8-N-1 (8 Data bits, No Parity, 1 Stop bit) UART Transceiver written in synthesizable Verilog HDL with a self-checking testbench.

## Architecture & Features
- **Configurable Baud Rate**: Baud rate timing controlled via `CLKS_PER_BIT` parameter.
- **Double-Flop Synchronizer**: Metastability protection on the serial `rx` input pin.
- **Mid-Bit Sampling**: Robust noise immunity with 50% midpoint oversampling on incoming start and data bits.
- **Loopback Testbench**: Automated stimulus verifying full-duplex transmission and byte integrity.

## Module Hierarchy
- `uart_tx.v`: Serial transmitter state machine.
- `uart_rx.v`: Serial receiver with edge detection and bit deserialization.
- `uart_transceiver.v`: Top-level module binding TX and RX interfaces.
- `uart_tb.v`: Self-checking testbench running loopback verification.

## Simulation & Waveform Verification

### Prerequisites
- [Icarus Verilog (`iverilog`)](http://bleyer.org/icarus/)
- [WaveTrace (VS Code Extension)](https://marketplace.visualstudio.com/) or [GTKWave](https://gtkwave.sourceforge.net/)

### Running the Testbench
```bash
# Compile design and testbench
iverilog -o uart_sim uart_tx.v uart_rx.v uart_transceiver.v uart_tb.v

# Execute simulation runtime
vvp uart_sim