import sys
import cocotb
from pathlib import Path
from cocotb.handle import SimHandleBase
from cocotb.triggers import Timer

project_root = Path(__file__).resolve().parents[3]
sys.path.append(str(project_root / "tools"))
from type_parser import CustomTypeParser

async def alu_decoder_output_test(dut: SimHandleBase,
                            fsm_state: str,
                            instr_opcode: str,
                            instr_sub: str,
                            expected_output: str) -> None:

    type_paths = [project_root/"rtl"/"pkg"/"chip8_types.vhd",
                  project_root/"rtl"/"pkg"/"chip8_decoder_types.vhd",]
    
    custom_types = CustomTypeParser(type_paths)
    dut.i_FSMState.value = custom_types["chip8_fsm_state_t"][fsm_state]
    dut.i_InstrOpcode.value = custom_types["chip8_instr_opcode_t"][instr_opcode]
    dut.i_InstrSub.value = custom_types["chip8_alu_op_t"][instr_sub]
    output = custom_types["chip8_alu_op_t"][expected_output]

    await Timer(1, 'ns')
    assert output == dut.o_ALUOp.value

async def alu_decoder_state_decode_test(dut: SimHandleBase,
                                        instr: str,
                                        instr_sub: str,
                                        expected_output: str) -> None:
    await alu_decoder_output_test(dut, 
                                  "chip8_fsm_state_decode",
                                  instr,
                                  instr_sub,
                                  expected_output)

@cocotb.test()
async def alu_decoder_state_reset_test(dut: SimHandleBase) -> None:
    await alu_decoder_output_test(dut, 
                                  "chip8_fsm_state_reset",
                                  "chip8_instr_opcode_Illegal",
                                  "chip8_alu_nop",
                                  "chip8_alu_nop")
@cocotb.test()    
async def alu_decoder_state_fetch_test(dut: SimHandleBase) -> None:
    await alu_decoder_output_test(dut, 
                                  "chip8_fsm_state_fetch",
                                  "chip8_instr_opcode_Illegal",
                                  "chip8_alu_nop",
                                  "chip8_alu_nop")

@cocotb.test()    
async def alu_decoder_state_writeVX_test(dut: SimHandleBase) -> None:
    await alu_decoder_output_test(dut, 
                                  "chip8_fsm_state_writeVX",
                                  "chip8_instr_opcode_Illegal",
                                  "chip8_alu_nop",
                                  "chip8_alu_nop")

@cocotb.test()    
async def alu_decoder_state_writeVF_test(dut: SimHandleBase) -> None:
    await alu_decoder_output_test(dut, 
                                  "chip8_fsm_state_writeVF",
                                  "chip8_instr_opcode_Illegal",
                                  "chip8_alu_nop",
                                  "chip8_alu_nop")

@cocotb.test()    
async def alu_decoder_storeimm_test(dut: SimHandleBase) -> None:
    await alu_decoder_state_decode_test(dut,
                                        "chip8_instr_opcode_StoreImm",
                                        "chip8_alu_nop",
                                        "chip8_alu_add")

@cocotb.test()    
async def alu_decoder_addimm_test(dut: SimHandleBase) -> None:
    await alu_decoder_state_decode_test(dut,
                                        "chip8_instr_opcode_AddImm",
                                        "chip8_alu_nop",
                                        "chip8_alu_add")

@cocotb.test()    
async def alu_decoder_aluexec_test(dut: SimHandleBase) -> None:
    alu_operations = ["chip8_alu_nop", "chip8_alu_add", "chip8_alu_sub",
                      "chip8_alu_and", "chip8_alu_or", "chip8_alu_xor",
                      "chip8_alu_sr", "chip8_alu_sl"]

    for op in alu_operations:
        await alu_decoder_state_decode_test(dut,
                                            "chip8_instr_opcode_ALUExec",
                                            op,
                                            op)
