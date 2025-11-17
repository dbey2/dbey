# PIC Simulator Review (Pre-Test)

## Snapshot
- Code under review: `tools/pic-sim.d` plus the bundled firmware fixtures in `firmware/`.
- Goal from request: verify the three completed tasks before attempting to run tests and collect data/suggestions for a higher-fidelity version.

## Key Findings

### CPU model is a placeholder
- `PICState` only tracks the program counter, W register, a flat 512-byte RAM array, and a few peripheral logs, so STATUS bits, the hardware stack, banked RAM semantics, and indirect addressing are absent.
- `executeInstruction` implements a custom set of 0x00–0x11 opcodes rather than the real 14-bit PIC16F628A instruction encoding, which means none of the datasheet instructions (e.g., `MOVLW`, `BSF`, `BCF`, `CALL`, `RETURN`, `GOTO`, `SLEEP`, interrupt context handling) are simulated.
- Because instructions are 8-bit wide here, decoded firmware bytes cannot be shared with authentic PIC hex files (which store 14-bit words split across bytes), so real firmware from the datasheet will not run.

### Peripheral/interrupt behavior is mocked out
- PORTA/PORTB/TRIS writes just stuff bytes into `PeripheralState` and emit log events—there is no pin direction enforcement, latch behavior, or timer-driven edge logic.
- EEPROM writes happen instantaneously without respecting unlock sequences or write delays.
- USART support is limited to appending characters to strings when TXREG/RCREG are touched; baud rate, status bits, interrupts, and framing are not modeled.
- Interrupts/tasks are recorded only when firmware emits the synthetic 0x10/0x11 "annotation" opcodes, so asynchronous events and the real interrupt controller are never exercised.

### CLI is stateless per invocation
- `run`, `step`, and `break` commands all call `executeSimulation`, which internally creates a brand-new `PICSimulator` and runs it until a stopping condition. There is no persistent session/state between commands, so you cannot `step` after a `run` without rerunning from reset.
- `step` counts simple instruction dispatches rather than real PIC cycles, so the `--count` argument is not comparable to datasheet timing.
- The `show` command simply instantiates a simulator and prints its zeroed-out snapshot without loading/decoding any registers from the HEX file, so it cannot display preset data-memory contents.

### Firmware fixtures are synthetic
- `firmware/led_toggle.hex` and `firmware/usart_echo.hex` each contain only four 16-byte records composed of the custom opcodes used by the simulator, not the LED blink and USART echo examples provided in the PIC16F628A datasheet.
- Because the bundled "firmware" is synthetic, the integration tests do not prove compatibility with Microchip toolchains nor verify real PORT/EEPROM timing.

### Tests cannot be exercised locally
- The included `unittest` block relies on `dmd`, but the earlier run already failed because the compiler is missing in this environment. There is no script or container definition that would let CI install the toolchain automatically.

## Suggestions for the Next Version
1. **Adopt a real PIC16F628A core model**: parse 14-bit words from Intel HEX, implement the documented instruction set (including STATUS flags, stack, indirect/banked addressing), and count cycles using datasheet timings.
2. **Model key peripherals**: at minimum, implement TMR0 (with prescaler), EEPROM write sequences/timing, and a basic USART that respects TXIF/RCIF flags so that datasheet firmware examples behave identically.
3. **Rework the CLI into a persistent debugger**: maintain simulator state across commands, add commands to continue/step/reset/inspect memory, and allow setting/clearing breakpoints without restarting the simulation.
4. **Replace synthetic fixtures with real firmware**: compile the datasheet LED blink and USART echo listings (or MPLAB sample projects) into .hex files, and assert against their expected PORTB/EEPROM side effects.
5. **Document and automate testing**: provide a `dub.json` or simple build script that installs `dmd`/`ldc` in CI, runs the unit tests, and explains how to execute the sample firmware end-to-end.
