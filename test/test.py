# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_pm32_small_multiply(dut):
    dut._log.info("Start PM32 test")

    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0

    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 2)

    mc = 3
    mp = 5

    dut.ui_in.value = (1 << 7) | mc
    dut.uio_in.value = mp
    await ClockCycles(dut.clk, 1)

    dut.ui_in.value = mc
    await ClockCycles(dut.clk, 70)

    expected = 0x80 | ((mc * mp) & 0x7F)
    assert int(dut.uo_out.value) == expected
