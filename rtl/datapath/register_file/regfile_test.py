import cocotb
import random
from cocotb.triggers import Timer, RisingEdge
from cocotb.clock import Clock
from cocotb.handle import SimHandleBase
from typing import List, Tuple


def create_clock(dut: SimHandleBase) -> None:
    cocotb.start_soon(Clock(dut.i_Clk, 1, "ns").start(start_high=False))


def clear_inputs(dut: SimHandleBase) -> None:
    dut.i_Rst.value = 0
    dut.i_SelX.value = 0
    dut.i_SelY.value = 0
    dut.i_WriteData.value = 0
    dut.i_WriteEnable.value = 0


def generate_random_data(count: int, val_range: Tuple[int, int], seed: int = None) -> List[Tuple[int, int]]:
    if seed is not None:
        random.seed(seed)
    return [(i, random.randint(val_range[0], val_range[1])) for i in range(count)]

async def setup_dut(dut: SimHandleBase) -> None:
    create_clock(dut)
    await RisingEdge(dut.i_Clk)
    clear_inputs(dut)
    await reset_regfile(dut)
    clear_inputs(dut)

async def reset_regfile(dut: SimHandleBase) -> None:
    dut.i_Rst.value = 1
    await RisingEdge(dut.i_Clk)
    dut.i_Rst.value = 0
    await RisingEdge(dut.i_Clk)


async def write_register(dut: SimHandleBase, data: int, vn: int, write_enabled: bool = True) -> None:
    dut.i_WriteEnable.value = 1 if write_enabled else 0
    dut.i_WriteData.value = data
    dut.i_SelX.value = vn
    await RisingEdge(dut.i_Clk)
    dut.i_WriteEnable.value = 0


async def read_register(dut: SimHandleBase, vn: int, bank: str) -> int:
    select_obj = dut.i_SelX if bank == 'x' else dut.i_SelY
    data_obj = dut.o_DataX if bank == 'x' else dut.o_DataY
    select_obj.value = vn
    await Timer(100, "ps")
    return data_obj.value.integer


async def validate_reg(dut: SimHandleBase, vn: int, bank: str, expected_data: int) -> None:
    bank_name = str(bank).capitalize()
    data = await read_register(dut, vn, bank)
    assert data == expected_data, (
        f"[{bank_name}-BANK] Validation failed: V{bank_name}[{hex(vn)}] -> "
        f"got {hex(data)}, expected {hex(expected_data)}"
    )


async def validate_regs(dut: SimHandleBase, vn: int, expected_data: int) -> None:
    await validate_reg(dut, vn, 'x', expected_data)
    await validate_reg(dut, vn, 'y', expected_data)


@cocotb.test()
async def reset_test(dut: SimHandleBase) -> None:
    await setup_dut(dut)
    for i in range(16):
        await validate_regs(dut, i, 0)


@cocotb.test()
async def test_write_during_reset(dut: SimHandleBase) -> None:
    write_data = generate_random_data(16, (0, 255))
    create_clock(dut)
    await RisingEdge(dut.i_Clk)
    clear_inputs(dut)
    await reset_regfile(dut)
    dut.i_Rst.value = 1
    await RisingEdge(dut.i_Clk)

    for reg, data in write_data:
        await write_register(dut, data, reg)
        await validate_regs(dut, reg, 0)

    dut.i_Rst.value = 0
    await RisingEdge(dut.i_Clk)


@cocotb.test()
async def write_test(dut: SimHandleBase) -> None:
    write_data = generate_random_data(16, (0, 255))
    await setup_dut(dut)
    for reg, data in write_data:
        await write_register(dut, data, reg)
        await validate_regs(dut, reg, data)


@cocotb.test()
async def disable_write_test(dut: SimHandleBase) -> None:
    write_data = generate_random_data(16, (0, 255))
    await setup_dut(dut)
    for reg, data in write_data:
        await write_register(dut, data, reg, False)
        await validate_reg(dut, reg, 'y', 0)
