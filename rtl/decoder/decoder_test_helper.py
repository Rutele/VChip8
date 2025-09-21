import sys
from dataclasses import dataclass, fields
from pathlib import Path

project_root = Path(__file__).resolve().parents[2]
sys.path.append(str(project_root / "tools"))
from type_parser import CustomTypeParser

custom_types = CustomTypeParser(project_root/"rtl"/"pkg"/"chip8_types.vhd")

@dataclass
class DecoderState:
    r_CurrState: int = 0
    o_PCWrite: int = 0
    o_IRWrite: int = 0
    o_RRWrite: int = 0
    o_RFWrite: int = 0
    o_ALUOp: int = 0
    o_ALU_VXSrc: int = 0
    o_ALU_VYSrc: int = 0
    o_RF_VXSrc: int = 0

    def as_dict(self) -> dict[str, int]:
        return {
            field.name: getattr(self, field.name) for field in fields(self)
        }


def make_state(fsm_state_name, pc_write, ir_write, rr_write, rf_write, alu_op, alu_vx, alu_vy, rf_vx_src):
    return DecoderState(
        r_CurrState=custom_types["chip8_fsm_state_t"][fsm_state_name],
        o_PCWrite=pc_write,
        o_IRWrite=ir_write,
        o_RRWrite=rr_write,
        o_RFWrite=rf_write,
        o_ALUOp=custom_types["chip8_alu_op_t"][alu_op],
        o_ALU_VXSrc=custom_types["chip8_alu_vx_t"][alu_vx],
        o_ALU_VYSrc=custom_types["chip8_alu_vy_t"][alu_vy],
        o_RF_VXSrc=custom_types["chip8_rf_vx_src_t"][rf_vx_src],
    )
