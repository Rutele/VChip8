import cocotb
from cocotb.triggers import Timer
import sys
from pathlib import Path

project_root = Path(__file__).resolve().parents[3]
sys.path.append(str(project_root / "tools"))
from type_parser import CustomTypeParser

custom_types = CustomTypeParser([project_root/"rtl"/"pkg"/"chip8_types.vhd"])

async def clear_alu(dut, op):
    dut.i_ALUCtrl.value = custom_types["chip8_alu_op_t"][op]
    dut.i_VX.value = 0
    dut.i_VY.value = 0
    await Timer(1, "ns")

async def alu_op_test(dut, op, vx_values, vy_values, expected_fun):
    await clear_alu(dut, op)

    for i in vx_values:
        for j in vy_values:
            dut.i_VX.value = i
            dut.i_VY.value = j
            await Timer(1, "ns")

            expected_result, expected_flag = expected_fun(i, j)

            assert dut.o_ALUResult.value.integer == expected_result, \
                f"{op} failed for VX={i}, VY={j}: " \
                f"got {dut.o_ALUResult.value.integer}, expected {expected_result}"

            assert dut.o_Flag.value.integer == expected_flag, \
                f"{op} flag failed for VX={i}, VY={j}: " \
                f"got {dut.o_Flag.value.integer}, expected {expected_flag}"

@cocotb.test()
async def addition_test(dut):
    await alu_op_test(
        dut,
        "chip8_alu_add",
        vx_values=range(256),
        vy_values=range(256),
        expected_fun=lambda x, y: ((x + y) % 256, int(x + y >= 256))
    )

@cocotb.test()
async def sub_test(dut):
    await alu_op_test(
        dut,
        "chip8_alu_sub",
        vx_values=range(256),
        vy_values=range(256),
        expected_fun=lambda x, y: ((x - y) % 256, int(x >= y))
    )

@cocotb.test()
async def and_test(dut):
    await alu_op_test(
        dut,
        "chip8_alu_and",
        vx_values=range(256),
        vy_values=range(256),
        expected_fun=lambda x, y: (x & y, 0)
    )

@cocotb.test()
async def or_test(dut):
    await alu_op_test(
        dut,
        "chip8_alu_or",
        vx_values=range(256),
        vy_values=range(256),
        expected_fun=lambda x, y: (x | y, 0)
    )

@cocotb.test()
async def xor_test(dut):
    await alu_op_test(
        dut,
        "chip8_alu_xor",
        vx_values=range(256),
        vy_values=range(256),
        expected_fun=lambda x, y: (x ^ y, 0)
    )

@cocotb.test()
async def sr_test(dut):
    await alu_op_test(
        dut,
        "chip8_alu_sr",
        vx_values=[0],
        vy_values=range(256),
        expected_fun=lambda _, y: (y >> 1, y & 1)
    )

@cocotb.test()
async def sl_test(dut):
    await alu_op_test(
        dut,
        "chip8_alu_sl",
        vx_values=[0],
        vy_values=range(256),
        expected_fun=lambda _, y: ((y << 1) % 256, (y >> 7) & 1)
    )
