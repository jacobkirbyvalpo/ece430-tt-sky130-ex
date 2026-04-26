# PM32 Multiplier

## How it works

This project wraps the PM32 sequential multiplier for the Tiny Tapeout interface.

The original PM32 design is a 32-bit by 32-bit signed multiplier with a 64-bit product output. Because a Tiny Tapeout tile has limited external pins, this wrapper exposes only small test values.

- `ui_in[6:0]` is used as the lower bits of the multiplicand.
- `ui_in[7]` is the start signal.
- `uio_in[7:0]` is used as the lower bits of the multiplier.
- `uo_out[6:0]` shows the lower 7 bits of the product.
- `uo_out[7]` shows the done signal.

The unused upper input bits are tied to zero inside the wrapper.

## How to test

Apply a small value on `ui_in[6:0]` and another small value on `uio_in[7:0]`.

Pulse `ui_in[7]` high for one clock cycle to start multiplication. After the multiplier finishes, `uo_out[7]` goes high. The lower 7 product bits are visible on `uo_out[6:0]`.

Example:

- `ui_in[6:0] = 3`
- `uio_in[7:0] = 5`
- Expected product is `15`
- Therefore `uo_out[6:0] = 15` after completion

## External hardware

No external hardware is required.
