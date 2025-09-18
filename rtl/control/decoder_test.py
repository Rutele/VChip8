import cocotb
import sys
from pathlib import Path
from cocotb.triggers import Timer, RisingEdge
from cocotb.clock import Clock
from cocotb.handle import SimHandleBase

project_root = Path(__file__).resolve().parents[2]
sys.path.append(str(project_root / "tools"))
from type_parser import CustomTypeParser

custom_types = CustomTypeParser(project_root/"rtl"/"pkg"/"chip8_types.vhd")

def create_clock(dut: SimHandleBase) -> None:
    cocotb.start_soon(Clock(dut.i_Clk, 1, "ns").start(start_high=False))


async def reset_decoder(dut: SimHandleBase) -> None:    
    dut.i_InstrOpcode.value = custom_types["chip8_instr_opcode_t"]["chip8_instr_opcode_StoreImm"]
    dut.i_InstrSub.value = custom_types["chip8_alu_op_t"]["chip8_alu_nop"]
    dut.i_Rst.value = 1
    await RisingEdge(dut.i_Clk)
    await RisingEdge(dut.i_Clk)
    await RisingEdge(dut.i_Clk)
    dut.i_Rst.value = 0

@cocotb.test()
async def run_decoder(dut):
    create_clock(dut)
    await reset_decoder(dut)
    await RisingEdge(dut.i_Clk) # fetch
    await RisingEdge(dut.i_Clk)
    await RisingEdge(dut.i_Clk)
    await RisingEdge(dut.i_Clk)

    dut.i_InstrOpcode.value = custom_types["chip8_instr_opcode_t"]["chip8_instr_opcode_ALUExec"]
    dut.i_InstrSub.value = custom_types["chip8_alu_op_t"]["chip8_alu_sl"]

    await RisingEdge(dut.i_Clk)
    await RisingEdge(dut.i_Clk)
    await RisingEdge(dut.i_Clk)
    await RisingEdge(dut.i_Clk)
    

    assert True