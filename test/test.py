import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer


def make_ui(heart_sw, oxygen_sw, display_select):
    return ((display_select & 0x3) << 6) | ((oxygen_sw & 0x7) << 3) | (heart_sw & 0x7)


def make_uio_in(bp_sw):
    return bp_sw & 0x7


async def apply_case(
    dut,
    heart_sw,
    oxygen_sw,
    bp_sw,
    display_select,
    expected_value,
    expected_hb_alarm,
    expected_oxygen_alarm,
    expected_bp_alarm,
):
    dut.ui_in.value = make_ui(heart_sw, oxygen_sw, display_select)
    dut.uio_in.value = make_uio_in(bp_sw)

    await Timer(100, unit="ns")

    actual_value = int(dut.uo_out.value)
    actual_uio_out = int(dut.uio_out.value)
    actual_uio_oe = int(dut.uio_oe.value)

    actual_hb_alarm = (actual_uio_out >> 4) & 1
    actual_oxygen_alarm = (actual_uio_out >> 5) & 1
    actual_bp_alarm = (actual_uio_out >> 6) & 1
    actual_any_alarm = (actual_uio_out >> 7) & 1

    expected_any_alarm = expected_hb_alarm | expected_oxygen_alarm | expected_bp_alarm

    assert actual_value == expected_value, (
        f"wrong selected value: got {actual_value}, expected {expected_value}"
    )

    assert actual_hb_alarm == expected_hb_alarm, (
        f"wrong heart alarm: got {actual_hb_alarm}, expected {expected_hb_alarm}"
    )

    assert actual_oxygen_alarm == expected_oxygen_alarm, (
        f"wrong oxygen alarm: got {actual_oxygen_alarm}, expected {expected_oxygen_alarm}"
    )

    assert actual_bp_alarm == expected_bp_alarm, (
        f"wrong BP alarm: got {actual_bp_alarm}, expected {expected_bp_alarm}"
    )

    assert actual_any_alarm == expected_any_alarm, (
        f"wrong any alarm: got {actual_any_alarm}, expected {expected_any_alarm}"
    )

    assert actual_uio_oe == 0xF0, (
        f"wrong uio_oe: got {actual_uio_oe:#04x}, expected 0xf0"
    )


@cocotb.test()
async def test_health_monitor(dut):
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    dut.ena.value = 1
    dut.rst_n.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0

    await Timer(100, unit="ns")

    await apply_case(
        dut,
        heart_sw=0,
        oxygen_sw=4,
        bp_sw=3,
        display_select=0,
        expected_value=40,
        expected_hb_alarm=1,
        expected_oxygen_alarm=0,
        expected_bp_alarm=0,
    )

    await apply_case(
        dut,
        heart_sw=2,
        oxygen_sw=2,
        bp_sw=3,
        display_select=1,
        expected_value=90,
        expected_hb_alarm=0,
        expected_oxygen_alarm=1,
        expected_bp_alarm=0,
    )

    await apply_case(
        dut,
        heart_sw=3,
        oxygen_sw=4,
        bp_sw=6,
        display_select=2,
        expected_value=150,
        expected_hb_alarm=0,
        expected_oxygen_alarm=0,
        expected_bp_alarm=1,
    )

    await apply_case(
        dut,
        heart_sw=3,
        oxygen_sw=4,
        bp_sw=1,
        display_select=3,
        expected_value=65,
        expected_hb_alarm=0,
        expected_oxygen_alarm=0,
        expected_bp_alarm=0,
    )

    await apply_case(
        dut,
        heart_sw=4,
        oxygen_sw=4,
        bp_sw=5,
        display_select=0,
        expected_value=100,
        expected_hb_alarm=0,
        expected_oxygen_alarm=0,
        expected_bp_alarm=0,
    )
