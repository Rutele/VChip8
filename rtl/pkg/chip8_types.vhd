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
    type chip8_instr_opcode_t is (chip8_instr_opcode_store_imm, chip8_instr_opcode_ALU_calc,
                                  chip8_instr_opcode_add_imm);

    -- Instruction Decoder FSM States
    type chip8_fsm_state_t is (chip8_fsm_state_fetch, chip8_fsm_state_decode,
                               chip8_fsm_state_writeVX, chip8_fsm_state_ALUOp,
                               chip8_fsm_state_writeVF);

end package;

package body chip8_types_pkg is
end package body;
