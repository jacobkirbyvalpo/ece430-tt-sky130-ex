# Health Monitor Alarm Decoder

## Description

This project is a simple digital health monitor alarm decoder for Tiny Tapeout. It takes switch-coded inputs for heart rate, oxygen level, and blood pressure. Each input code is mapped to an 8-bit value. The circuit then checks those values against preset limits and turns on alarm outputs if a reading is outside the normal range.

The design also has a display select input. This chooses whether `uo_out[7:0]` shows heart rate, oxygen percentage, systolic blood pressure, or diastolic blood pressure.

This is only an educational digital logic project and is not meant to be used as a real medical device.

## Tiny Tapeout I/O Pin Assignments

| Tiny Tapeout Pin | Direction | Internal Signal | Purpose |
|---|---|---|---|
| `ui_in[2:0]` | Input | `heart_rate_sw[2:0]` | Heart-rate switch code |
| `ui_in[5:3]` | Input | `oxygen_rate_sw[2:0]` | Oxygen switch code |
| `ui_in[7:6]` | Input | `display_select[1:0]` | Chooses which value appears on `uo_out` |
| `uo_out[7:0]` | Output | `selected_value[7:0]` | Selected decoded health value |
| `uio[2:0]` | Input | `blood_pressure_sw[2:0]` | Blood-pressure switch code |
| `uio[3]` | Input | unused | Unused input |
| `uio[4]` | Output | `hb_alarm` | Heart-rate alarm |
| `uio[5]` | Output | `oxygen_alarm` | Oxygen alarm |
| `uio[6]` | Output | `bp_alarm` | Blood-pressure alarm |
| `uio[7]` | Output | `any_alarm` | High when any alarm is active |

## Display Select

| `ui_in[7:6]` | Value shown on `uo_out[7:0]` |
|---|---|
| `00` | Heart rate |
| `01` | Oxygen percentage |
| `10` | Systolic blood pressure |
| `11` | Diastolic blood pressure |

## Behavior

The heart-rate input is decoded into one of eight BPM values. The heart alarm turns on if the value is below 60 BPM or above 100 BPM.

The oxygen input is decoded into one of eight oxygen percentage values. The oxygen alarm turns on if the value is below 92%.

The blood-pressure input is decoded into a systolic and diastolic pair. The blood-pressure alarm turns on if systolic pressure is below 90 or above 140, or if diastolic pressure is below 60 or above 90.

The `any_alarm` output is high whenever at least one of the three alarm outputs is high.

## Example Operation

| Time | Heart SW | Oxygen SW | BP SW | Display Select | Expected `uo_out[7:0]` | Alarm |
|---|---|---|---|---|---:|---|
| `t0` | `000` | `100` | `011` | `00` | 40 | Heart alarm |
| `t1` | `010` | `010` | `011` | `01` | 90 | Oxygen alarm |
| `t2` | `011` | `100` | `110` | `10` | 150 | BP alarm |
| `t3` | `011` | `100` | `001` | `11` | 65 | No alarm |
| `t4` | `100` | `100` | `101` | `00` | 100 | No alarm |

## Test Bench

The cocotb test drives several input combinations and checks the selected output value, the three alarm signals, the combined alarm signal, and the `uio_oe` direction bits. This verifies that the decoders, display selection logic, and alarm threshold logic work correctly.

## Block Diagram

The block diagram will be added later. It will show the Tiny Tapeout input pins feeding the heart-rate, oxygen, and blood-pressure decoder blocks, then the threshold/alarm logic and display multiplexer driving the Tiny Tapeout output pins.
