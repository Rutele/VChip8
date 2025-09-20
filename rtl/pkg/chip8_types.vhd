library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.chip8_const_pkg.all;

package chip8_types_pkg is
    -- ALU Types
    type chip8_alu_op_t is (chip8_alu_nop, chip8_alu_add, chip8_alu_sub,
                            chip8_alu_and, chip8_alu_or, chip8_alu_xor,
                            chip8_alu_sr, chip8_alu_sl);
    -- Register File Types
    type reg_arr_t is array (0 to REG_COUNT-1) of std_logic_vector(REG_DATA_WIDTH-1 downto 0);

    -- Instruction Decoder Types
    type chip8_instr_opcode_t is (chip8_instr_opcode_StoreImm, chip8_instr_opcode_ALUExec,
                                  chip8_instr_opcode_AddImm, chip8_instr_opcode_Illegal);

    type chip8_fsm_state_t is (chip8_fsm_state_fetch, chip8_fsm_state_decode,
                               chip8_fsm_state_writeVX, chip8_fsm_state_writeVF);

    type chip8_alu_vx_t is (chip8_alu_vx_normal, chip8_alu_vx_zero);
    type chip8_alu_vy_t is (chip8_alu_vy_normal, chip8_alu_vy_imm);
    type chip8_rf_vx_src_t is (chip8_rf_vx_normal, chip8_rf_vx_vf);

end package;

package body chip8_types_pkg is
end package body;
