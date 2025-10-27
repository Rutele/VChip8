library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.chip8_const_pkg.all;
use work.chip8_types_pkg.all;
use work.chip8_decoder_types_pkg.all;

entity InstructionDecoder is
    port(
        i_Clk : in std_logic;
        i_Rst : in std_logic;
        i_InstrOpcode : in chip8_instr_opcode_t;
        i_InstrSub : in chip8_alu_op_t;
        o_ALUOp : out chip8_alu_op_t;
        o_SelSignals : out chip8_select_signals_t;
        o_WriteSignals : out chip8_write_signals_t
    );
end InstructionDecoder;

architecture RTL of InstructionDecoder is
    signal r_CurrState       : chip8_fsm_state_t;
    signal w_ALUOp_int       : chip8_alu_op_t;
    signal w_SelSignals_int  : chip8_select_signals_t;
    signal w_WriteSignals_int: chip8_write_signals_t;
begin

    e_SelectDecoder: entity work.SelectDecoder(RTL)
    port map(
        i_FSMState    => r_CurrState,
        i_InstrOpcode => i_InstrOpcode,
        i_InstrSub    => i_InstrSub,
        o_SelSignals  => w_SelSignals_int
    );

    e_WriteDecoder : entity work.WriteDecoder(RTL)
    port map(
        i_FSMState     => r_CurrState,
        o_WriteSignals => w_WriteSignals_int
    );

    e_ALUDecoder : entity work.ALUDecoder(RTL)
    port map(
        i_FSMState    => r_CurrState,
        i_InstrOpcode => i_InstrOpcode,
        i_InstrSub    => i_InstrSub,
        o_ALUOp       => w_ALUOp_int
    );

    process(i_Clk)
    begin
        if rising_edge(i_Clk) then
            if i_Rst = '1' then
                r_CurrState <= chip8_fsm_state_reset;
            else
                case r_CurrState is
                    when chip8_fsm_state_reset =>
                        r_CurrState <= chip8_fsm_state_fetch;

                    when chip8_fsm_state_fetch =>
                        r_CurrState <= chip8_fsm_state_decode;

                    when chip8_fsm_state_decode =>
                        case i_InstrOpcode is
                            when chip8_instr_opcode_StoreImm |
                                 chip8_instr_opcode_ALUExec |
                                 chip8_instr_opcode_AddImm | 
                                 chip8_instr_opcode_SetRandom =>
                                r_CurrState <= chip8_fsm_state_writeVX;
                            when others =>
                                r_CurrState <= chip8_fsm_state_fetch;
                        end case;

                    when chip8_fsm_state_writeVX =>
                        case i_InstrSub is
                            when chip8_alu_add | chip8_alu_sub |
                                 chip8_alu_sl  | chip8_alu_sr |
                                 chip8_alu_sub_swap =>
                                if i_InstrOpcode = chip8_instr_opcode_ALUExec then
                                    r_CurrState <= chip8_fsm_state_writeVF;
                                else
                                    r_CurrState <= chip8_fsm_state_fetch;
                                end if;
                            when others =>
                                r_CurrState <= chip8_fsm_state_fetch;
                        end case;

                    when chip8_fsm_state_writeVF =>
                        r_CurrState <= chip8_fsm_state_fetch;

                    when others =>
                        r_CurrState <= chip8_fsm_state_fetch;
                end case;
            end if;
        end if;
    end process;

    o_ALUOp        <= w_ALUOp_int;
    o_SelSignals   <= w_SelSignals_int;
    o_WriteSignals <= w_WriteSignals_int;

end architecture;
