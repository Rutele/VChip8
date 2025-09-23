library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.chip8_types_pkg.all;
use work.chip8_decoder_types_pkg.all;

entity ALUDecoder is
    port(
        i_FSMState : in chip8_fsm_state_t;
        i_InstrOpcode : in chip8_instr_opcode_t;
        i_InstrSub : in chip8_alu_op_t;
        o_ALUOp : out chip8_alu_op_t
    );
end entity;

architecture RTL of ALUDecoder is
    signal w_ALUOp : chip8_alu_op_t;
begin

    process(i_FSMState, i_InstrSub, i_InstrOpcode) is
    begin

        w_ALUOp <= chip8_alu_nop;
        
        case i_FSMState is
            when chip8_fsm_state_reset   |
                 chip8_fsm_state_fetch   |
                 chip8_fsm_state_writeVX |
                 chip8_fsm_state_writeVF =>
                null;

            when chip8_fsm_state_decode =>
                case i_InstrOpcode is
                    when chip8_instr_opcode_StoreImm |
                         chip8_instr_opcode_AddImm   =>
                        w_ALUOp     <= chip8_alu_add;

                    when chip8_instr_opcode_ALUExec =>
                        w_ALUOp     <= i_InstrSub;

                   when others =>
                        null;
                end case;

            when others =>
                null;
        end case;
    end process;

    o_ALUOp <= w_ALUOp;
    
end architecture;
