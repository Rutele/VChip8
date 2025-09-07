library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.chip8_const_pkg.all;
use work.chip8_types_pkg.all;

entity InstructionDecoder is

    port(
        i_Clk : in std_logic;
        i_Rst : in std_logic;
        i_InstrOpcode : in chip8_instr_opcode_t;
        i_InstrSub : in chip8_alu_op_t;
        o_PCWrite : out std_logic;
        o_IRWrite : out std_logic;
        o_RRWrite : out std_logic;
        o_RegFileWrite : out std_logic;
        o_VFWrite : out std_logic;
        o_ALUOp : out chip8_alu_op_t
    );

end InstructionDecoder;

architecture RTL of InstructionDecoder is

    signal r_CurrState : chip8_fsm_state_t;

begin

    process(i_Clk, i_Rst) is
    begin
        if (i_Rst) then
            r_CurrState <= chip8_fsm_state_fetch;
        elsif rising_edge(i_Clk) then
            case r_CurrState is
                when chip8_fsm_state_fetch =>
                    r_CurrState <= chip8_fsm_state_decode;
                when chip8_fsm_state_decode =>
                    case i_InstrOpcode is
                        when chip8_instr_opcode_store_imm =>
                            r_CurrState <= chip8_fsm_state_writeVX;
                        when chip8_instr_opcode_ALU_calc =>
                            r_CurrState <= chip8_fsm_state_ALUOp;
                        when others =>
                            r_CurrState <= chip8_fsm_state_fetch;
                    end case;
                when chip8_fsm_state_ALUOp =>
                    r_CurrState <= chip8_fsm_state_writeVX;
                when others =>
                    r_CurrState <= chip8_fsm_state_fetch;
            end case;
        end if;
    end process;

    process(r_CurrState) is
    begin
        case r_CurrState is
            when chip8_fsm_state_fetch =>
                o_PCWrite <= '0';
                o_IRWrite <= '1';
                o_RRWrite <= '0';
                o_RegFileWrite <= '0';
                o_VFWrite <= '0';
                o_ALUOp <= chip8_alu_nop;
            when chip8_fsm_state_decode =>
                o_PCWrite <= '0';
                o_IRWrite <= '0';
                o_RRWrite <= '1';
                o_RegFileWrite <= '0';
                o_VFWrite <= '0';
                o_ALUOp <= chip8_alu_nop;
            when chip8_fsm_state_writeVX =>
                o_PCWrite <= '0';
                o_IRWrite <= '0';
                o_RRWrite <= '1';
                o_RegFileWrite <= '1';
                o_VFWrite <= '0';
                o_ALUOp <= chip8_alu_nop;
            when chip8_fsm_state_ALUOp =>
                o_PCWrite <= '0';
                o_IRWrite <= '0';
                o_RRWrite <= '1';
                o_RegFileWrite <= '0';
                o_VFWrite <= '0';
                o_ALUOp <= i_InstrSub;
            when others =>
                o_PCWrite <= '0';
                o_IRWrite <= '0';
                o_RRWrite <= '0';
                o_RegFileWrite <= '0';
                o_VFWrite <= '0';
                o_ALUOp <= chip8_alu_nop;
        end case;
    end process;

end architecture;