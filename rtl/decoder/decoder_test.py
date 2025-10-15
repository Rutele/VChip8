import cocotb
import sys
from decoder_test_helper import DecoderState, make_state
from pathlib import Path
from cocotb.triggers import Timer, RisingEdge
from cocotb.clock import Clock
from cocotb.handle import SimHandleBase

project_root = Path(__file__).resolve().parents[2]
sys.path.append(str(project_root / "tools"))
from type_parser import CustomTypeParser

custom_types = CustomTypeParser(project_root/"rtl"/"pkg"/"chip8_types.vhd")

async def create_clock(dut: SimHandleBase) -> None:
    cocotb.start_soon(Clock(dut.i_Clk, 1, "ns").start(start_high=False))
    await RisingEdge(dut.i_Clk)

async def reset_decoder(dut: SimHandleBase, n_cycles: int) -> None:    
    dut.i_Rst.value = 1
    for _ in range(n_cycles):
        await RisingEdge(dut.i_Clk)
    dut.i_Rst.value = 0

def check_state(dut: SimHandleBase, state: DecoderState) -> None:
    for signal, value in state.as_dict().items():
        actual_value = int(getattr(dut, signal).value)
        assert actual_value == value

async def instruction_test(dut: SimHandleBase, trans_list: list[DecoderState]) -> None:
    await create_clock(dut)
    await reset_decoder(dut, 3)

    for expected_state in trans_list:
        await RisingEdge(dut.i_Clk)
        check_state(dut, expected_state)


@cocotb.test()
async def StoreImm_Test(dut: SimHandleBase):
    dut.i_InstrOpcode.value = custom_types["chip8_instr_opcode_t"]["chip8_instr_opcode_StoreImm"]
    dut.i_InstrSub.value = custom_types["chip8_alu_op_t"]["chip8_alu_nop"]

    trans_list = [
        make_state("chip8_fsm_state_fetch",
                   1, 1, 0, 0,
                   "chip8_alu_nop", "chip8_alu_vx_normal", "chip8_alu_vy_normal", "chip8_rf_vx_normal"),

        make_state("chip8_fsm_state_decode",
                   0, 0, 1, 0,
                   "chip8_alu_add", "chip8_alu_vx_zero", "chip8_alu_vy_imm", "chip8_rf_vx_normal"),

        make_state("chip8_fsm_state_writeVX",
                   0, 0, 0, 1,
                   "chip8_alu_nop", "chip8_alu_vx_normal", "chip8_alu_vy_normal", "chip8_rf_vx_normal"),

        make_state("chip8_fsm_state_fetch",
                   1, 1, 0, 0,
                   "chip8_alu_nop", "chip8_alu_vx_normal", "chip8_alu_vy_normal", "chip8_rf_vx_normal"),
    ]

    await instruction_test(dut, trans_list)

@cocotb.test()
async def AddImm_Test(dut):
    dut.i_InstrOpcode.value = custom_types["chip8_instr_opcode_t"]["chip8_instr_opcode_AddImm"]
    dut.i_InstrSub.value = custom_types["chip8_alu_op_t"]["chip8_alu_nop"]

    trans_list = [
        make_state("chip8_fsm_state_fetch",
                   1, 1, 0, 0,
                   "chip8_alu_nop", "chip8_alu_vx_normal", "chip8_alu_vy_normal", "chip8_rf_vx_normal"),

        make_state("chip8_fsm_state_decode",
                   0, 0, 1, 0,
                   "chip8_alu_add", "chip8_alu_vx_normal", "chip8_alu_vy_imm", "chip8_rf_vx_normal"),

        make_state("chip8_fsm_state_writeVX",
                   0, 0, 0, 1,
                   "chip8_alu_nop", "chip8_alu_vx_normal", "chip8_alu_vy_normal", "chip8_rf_vx_normal"),

        make_state("chip8_fsm_state_fetch",
                   1, 1, 0, 0,
                   "chip8_alu_nop", "chip8_alu_vx_normal", "chip8_alu_vy_normal", "chip8_rf_vx_normal"),
    ]

    await instruction_test(dut, trans_list)

async def ALUExec_VFType_Test(dut: SimHandleBase, instr_sub: int) -> None:
    dut.i_InstrOpcode.value = custom_types["chip8_instr_opcode_t"]["chip8_instr_opcode_ALUExec"]
    dut.i_InstrSub.value = custom_types["chip8_alu_op_t"][instr_sub]

    trans_list = [
        make_state("chip8_fsm_state_fetch",
                   1, 1, 0, 0,
                   "chip8_alu_nop", "chip8_alu_vx_normal", "chip8_alu_vy_normal", "chip8_rf_vx_normal"),

        make_state("chip8_fsm_state_decode",
                   0, 0, 1, 0,
                   instr_sub, "chip8_alu_vx_normal", "chip8_alu_vy_normal", "chip8_rf_vx_normal"),

        make_state("chip8_fsm_state_writeVX",
                   0, 0, 0, 1,
                   "chip8_alu_nop", "chip8_alu_vx_normal", "chip8_alu_vy_normal", "chip8_rf_vx_normal"),

        make_state("chip8_fsm_state_writeVF",
                   0, 0, 0, 1,
                   "chip8_alu_nop", "chip8_alu_vx_normal", "chip8_alu_vy_normal", "chip8_rf_vx_vf"),

        make_state("chip8_fsm_state_fetch",
                   1, 1, 0, 0,
                   "chip8_alu_nop", "chip8_alu_vx_normal", "chip8_alu_vy_normal", "chip8_rf_vx_normal"),
    ]

    await instruction_test(dut, trans_list)

async def ALUExec_NoVFType_Test(dut: SimHandleBase, instr_sub: int) -> None:
    dut.i_InstrOpcode.value = custom_types["chip8_instr_opcode_t"]["chip8_instr_opcode_ALUExec"]
    dut.i_InstrSub.value = custom_types["chip8_alu_op_t"][instr_sub]

    trans_list = [
        make_state("chip8_fsm_state_fetch",
                   1, 1, 0, 0,
                   "chip8_alu_nop", "chip8_alu_vx_normal", "chip8_alu_vy_normal", "chip8_rf_vx_normal"),

        make_state("chip8_fsm_state_decode",
                   0, 0, 1, 0,
                   instr_sub, "chip8_alu_vx_normal", "chip8_alu_vy_normal", "chip8_rf_vx_normal"),

        make_state("chip8_fsm_state_writeVX",
                   0, 0, 0, 1,
                   "chip8_alu_nop", "chip8_alu_vx_normal", "chip8_alu_vy_normal", "chip8_rf_vx_normal"),

        make_state("chip8_fsm_state_fetch",
                   1, 1, 0, 0,
                   "chip8_alu_nop", "chip8_alu_vx_normal", "chip8_alu_vy_normal", "chip8_rf_vx_normal"),
    ]

    await instruction_test(dut, trans_list)


@cocotb.test()
async def ALUExec_ADD_Test(dut):
    await ALUExec_VFType_Test(dut, "chip8_alu_add")

@cocotb.test()
async def ALUExec_SUB_Test(dut):
    await ALUExec_VFType_Test(dut, "chip8_alu_sub")

@cocotb.test()
async def ALUExec_SR_Test(dut):
    await ALUExec_VFType_Test(dut, "chip8_alu_sr")

@cocotb.test()
async def ALUExec_SL_Test(dut):
    await ALUExec_VFType_Test(dut, "chip8_alu_sl")

@cocotb.test()
async def ALUExec_AND_Test(dut):
    await ALUExec_NoVFType_Test(dut, "chip8_alu_and")

@cocotb.test()
async def ALUExec_OR_Test(dut):
    await ALUExec_NoVFType_Test(dut, "chip8_alu_or")

@cocotb.test()
async def ALUExec_XOR_Test(dut):
    await ALUExec_NoVFType_Test(dut, "chip8_alu_xor")
