import cocotb
from cocotb.triggers import RisingEdge
from cocotb.clock import Clock
from cocotb.handle import SimHandleBase

INIT_ADDRESS = 0x200

def create_clock(dut: SimHandleBase) -> None:
    cocotb.start_soon(Clock(dut.i_Clk, 1, "ns").start(start_high=False))

def clear_inputs(dut: SimHandleBase) -> None:
    dut.i_Clk.value = 0
    dut.i_Rst.value = 0
    dut.i_Write = 0

async def reset_pc(dut: SimHandleBase) -> None:
    dut.i_Rst.value = 1
    await RisingEdge(dut.i_Clk)
    dut.i_Rst.value = 0

async def setup_dut(dut: SimHandleBase) -> None:
    create_clock(dut)
    await RisingEdge(dut.i_Clk)
    clear_inputs(dut)
    await reset_pc(dut)
    clear_inputs(dut)

@cocotb.test()
async def pc_rest_test(dut: SimHandleBase) -> None:
    await setup_dut(dut)
    dut.i_Write.value = 1
    for _ in range(4):
        await RisingEdge(dut.i_Clk)
    await reset_pc(dut)
    await RisingEdge(dut.i_Clk)
    assert dut.o_InstrAddress == INIT_ADDRESS

@cocotb.test()
async def pc_advance_test(dut: SimHandleBase) -> None:
    curr_address = INIT_ADDRESS
    await setup_dut(dut)
    dut.i_Write.value = 1
    for _ in range(4):
        await RisingEdge(dut.i_Clk)
        assert dut.o_InstrAddress == curr_address
        curr_address = curr_address + 2
