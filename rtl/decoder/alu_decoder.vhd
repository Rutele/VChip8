library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.chip8_const_pkg.all;
use work.chip8_types_pkg.all;

entity ALUDecoder is
    port(
        i_Clk : in std_logic;
        i_Rst : in std_logic;
        i_InstrOpcode : in chip8_instr_opcode_t;
        i_InstrSub : in chip8_alu_op_t;
        i_FSMState : in chip8_fsm_state_t;
        o_ALU_VXSrc : out std_logic_vector(1 downto 0);
        o_ALU_VYSrc : out std_logic_vector(1 downto 0);
        o_ALUOp : out chip8_alu_op_t
    );
end entity;

architecture RTL of ALUDecoder is
begin
    process(i_Clk, i_Rst) is
    begin
        if (i_Rst = '1') then
            o_ALU_VXSrc <= "00";
            o_ALU_VYSrc <= "00";
            o_ALUOp <= chip8_alu_add;
        elsif (rising_edge(i_Clk)) then
        case i_FSMState is
            when chip8_fsm_state_fetch =>
                o_ALU_VXSrc <= "10";
                o_ALU_VYSrc <= "11";
                o_ALUOp <= chip8_alu_add;
            when others =>
            case i_InstrOpcode is
                when chip8_instr_opcode_store_imm =>
                    o_ALU_VXSrc <= "00";
                    o_ALU_VYSrc <= "01";
                    o_ALUOp <= chip8_alu_add;
                when chip8_instr_opcode_add_imm =>
                    o_ALU_VXSrc <= "00";
                    o_ALU_VYSrc <= "10";
                    o_ALUOp <= chip8_alu_add;
                when chip8_instr_opcode_ALU_calc =>
                    case i_InstrSub is
                        when chip8_alu_nop =>
                            o_ALU_VXSrc <= "01";
                            o_ALU_VYSrc <= "00";
                            o_ALUOP <= chip8_alu_add;
                        when others =>
                            o_ALU_VXSrc <= "00";
                            o_ALU_VYSrc <= "00";
                            o_ALUOP <= i_InstrSub;
                    end case;
                when others =>
                    o_ALU_VXSrc <= "00";
                    o_ALU_VYSrc <= "00";
                    o_ALUOp <= chip8_alu_nop;
            end case;
        end case;
        end if;
    end process;
end architecture;
