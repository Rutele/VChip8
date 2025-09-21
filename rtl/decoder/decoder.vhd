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

    signal r_CurrState : chip8_fsm_state_t;

begin

    SourceDecoder: entity work.SourceDecoder(RTL)
    port map(
        i_FSMState => r_CurrState,
        i_InstrOpcode => i_InstrOpcode,
        o_SelSignals => o_SelSignals
    );

    WriteDecoder : entity work.WriteDecoder(RTL)
    port map(
        i_FSMState => r_CurrState,
        o_WriteSignals => o_WriteSignals
    );

    process(i_Clk, i_Rst) is
    begin
        if (i_Rst) then
            r_CurrState <= chip8_fsm_state_reset;
        elsif rising_edge(i_Clk) then
            case r_CurrState is
                when chip8_fsm_state_reset =>
                    r_CurrState <= chip8_fsm_state_fetch;
                when chip8_fsm_state_fetch =>
                    r_CurrState <= chip8_fsm_state_decode;
                when chip8_fsm_state_decode =>
                    case i_InstrOpcode is
                        when chip8_instr_opcode_StoreImm | chip8_instr_opcode_ALUExec |
                             chip8_instr_opcode_AddImm =>
                            r_CurrState <= chip8_fsm_state_writeVX;
                        when others =>
                            r_CurrState <= chip8_fsm_state_fetch;
                    end case;
                when chip8_fsm_state_writeVX =>
                    case i_InstrSub is
                        when chip8_alu_add | chip8_alu_sub | chip8_alu_sl | chip8_alu_sr =>
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
    end process;

    process(r_CurrState, i_InstrOpcode, i_InstrSub) is
    begin
        case r_CurrState is
            when chip8_fsm_state_fetch =>
                o_ALUOp     <= chip8_alu_nop;
            when chip8_fsm_state_decode =>
                case i_InstrOpcode is
                    when chip8_instr_opcode_StoreImm =>
                        o_ALUOp     <= chip8_alu_add;
                    when chip8_instr_opcode_AddImm =>
                        o_ALUOp     <= chip8_alu_add;
                    when chip8_instr_opcode_ALUExec =>
                        o_ALUOp     <= i_InstrSub;
                   when others =>
                        o_ALUOp     <= chip8_alu_nop;
                end case;
            when chip8_fsm_state_writeVX =>
                o_ALUOp     <= chip8_alu_nop;
            when chip8_fsm_state_writeVF =>
                o_ALUOp     <= chip8_alu_nop;
            when chip8_fsm_state_reset =>
                o_ALUOp     <= chip8_alu_nop;
            when others =>
                o_ALUOp     <= chip8_alu_nop;
        end case;
    end process;
end architecture;
