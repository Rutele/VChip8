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
        o_VXSrc : out std_logic;
        o_ALUOp : out chip8_alu_op_t;
        o_ALU_VXSrc : out std_logic_vector(1 downto 0);
        o_ALU_VYSrc : out std_logic_vector(1 downto 0)
    );

end InstructionDecoder;

architecture RTL of InstructionDecoder is

    signal r_CurrState : chip8_fsm_state_t;

begin

    ALUDecoder : entity work.ALUDecoder(RTL)
    port map(
        i_Clk => i_Clk,
        i_Rst => i_Rst,
        i_InstrOpcode => i_InstrOpcode,
        i_InstrSub => i_InstrSub,
        i_FSMState => r_CurrState,
        o_ALU_VXSrc => o_ALU_VXSrc,
        o_ALU_VYSrc => o_ALU_VYSrc,
        o_ALUOp => o_ALUOp
    );

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
                        when chip8_instr_opcode_store_imm | chip8_instr_opcode_add_imm =>
                            r_CurrState <= chip8_fsm_state_writeVX;
                        when chip8_instr_opcode_ALU_calc =>
                            r_CurrState <= chip8_fsm_state_ALUOp;
                        when others =>
                            r_CurrState <= chip8_fsm_state_fetch;
                    end case;
                when chip8_fsm_state_ALUOp =>
                    case i_InstrSub is
                        when chip8_alu_add | chip8_alu_sub | chip8_alu_sl | chip8_alu_sr =>
                            r_CurrState <= chip8_fsm_state_writeVF;
                        when others =>
                            r_CurrState <= chip8_fsm_state_writeVX;
                    end case;
                when chip8_fsm_state_writeVF =>
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
                o_VXSrc <= '0';
            when chip8_fsm_state_decode =>
                o_PCWrite <= '0';
                o_IRWrite <= '0';
                o_RRWrite <= '1';
                o_RegFileWrite <= '0';
                o_VXSrc <= '0';
            when chip8_fsm_state_writeVX =>
                o_PCWrite <= '0';
                o_IRWrite <= '0';
                o_RRWrite <= '0';
                o_RegFileWrite <= '1';
                o_VXSrc <= '0';
            when chip8_fsm_state_ALUOp =>
                o_PCWrite <= '0';
                o_IRWrite <= '0';
                o_RRWrite <= '1';
                o_RegFileWrite <= '0';
                o_VXSrc <= '0';
            when chip8_fsm_state_writeVF =>
                o_PCWrite <= '0';
                o_IRWrite <= '0';
                o_RRWrite <= '0';
                o_RegFileWrite <= '1';
                o_VXSrc <= '1';
            when others =>
                o_PCWrite <= '0';
                o_IRWrite <= '0';
                o_RRWrite <= '0';
                o_RegFileWrite <= '0';
                o_VXSrc <= '0';
        end case;
    end process;

end architecture;