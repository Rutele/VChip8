library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.chip8_types_pkg.all;
use work.chip8_decoder_types_pkg.all;

entity SelectDecoder is
  port (
    i_FSMState    : in  chip8_fsm_state_t;
    i_InstrOpcode : in  chip8_instr_opcode_t;
    o_SelSignals  : out chip8_select_signals_t
  );
end entity;

architecture RTL of SelectDecoder is
    signal w_SelSignals : chip8_select_signals_t; 
begin

    process(i_FSMState, i_InstrOpcode) is
    begin
        w_SelSignals <= CHIP8_SELECT_DEFAULT;

        case i_FSMState is
            when chip8_fsm_state_fetch |
                 chip8_fsm_state_reset |
                 chip8_fsm_state_writeVX =>
                null;

            when chip8_fsm_state_decode =>
                case i_InstrOpcode is
                    when chip8_instr_opcode_StoreImm =>
                        w_SelSignals.alu_vx <= chip8_alu_vx_zero;
                        w_SelSignals.alu_vy <= chip8_alu_vy_imm;

                    when chip8_instr_opcode_AddImm =>
                        w_SelSignals.alu_vy <= chip8_alu_vy_imm;

                    when chip8_instr_opcode_ALUExec =>
                        null;

                    when others =>
                        null;
                end case;

            when chip8_fsm_state_writeVF =>
                w_SelSignals.rf_vx <= chip8_rf_vx_vf;

            when others =>
                null;
        end case;
    end process;

    o_SelSignals <= w_SelSignals;

end architecture;
