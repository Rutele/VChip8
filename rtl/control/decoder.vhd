library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.chip8_const_pkg.all;
use work.chip8_types_pkg.all;

entity InstructionDecoder is

    port(
        i_Clk : in std_logic;
        i_Rst : in std_logic;
        i_InstrOpcode : in chip8_instr_opcode_t;    -- Instruction MSB (1 byte)
        i_InstrSub : in chip8_alu_op_t;             -- Instruction LSB (1 byte)
        o_PCWrite : out std_logic;                  -- Program Counter Write
        o_IRWrite : out std_logic;                  -- Instruction Register Write
        o_RRWrite : out std_logic;                  -- Result Register Write
        o_RFWrite : out std_logic;                  -- Register File Write
        o_ALUOp : out chip8_alu_op_t;               -- ALU Instruction
        o_ALU_VXSrc : out chip8_alu_vx_t;
        o_ALU_VYSrc : out chip8_alu_vy_t;
        o_RF_VXSrc : out chip8_rf_vx_src_t
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
                        when chip8_instr_opcode_StoreImm | chip8_instr_opcode_ALUExec |
                             chip8_instr_opcode_AddImm =>
                            r_CurrState <= chip8_fsm_state_writeVX;
                        when others =>
                            r_CurrState <= chip8_fsm_state_fetch;
                    end case;
                when chip8_fsm_state_writeVX =>
                    case i_InstrSub is
                        when chip8_alu_add | chip8_alu_sub | chip8_alu_sl | chip8_alu_sr =>
                            r_CurrState <= chip8_fsm_state_writeVF;
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

    process(r_CurrState) is
    begin
        case r_CurrState is
            when chip8_fsm_state_fetch =>
                o_PCWrite   <= '1';
                o_IRWrite   <= '1';
                o_RRWrite   <= '0';
                o_RFWrite   <= '0';
                o_ALUOp     <= chip8_alu_nop;
                o_ALU_VXSrc <= chip8_alu_vx_normal;
                o_ALU_VYSrc <= chip8_alu_vy_normal;
                o_RF_VXSrc  <= chip8_rf_vx_vf;
            when chip8_fsm_state_decode =>
                o_PCWrite   <= '0';
                o_IRWrite   <= '0';
                o_RRWrite   <= '1';
                o_RFWrite   <= '0';
                o_RF_VXSrc  <= chip8_rf_vx_normal;
                case i_InstrOpcode is
                    when chip8_instr_opcode_StoreImm =>
                        o_ALUOp     <= chip8_alu_add;
                        o_ALU_VXSrc <= chip8_alu_vx_zero;
                        o_ALU_VYSrc <= chip8_alu_vy_imm;
                    when chip8_instr_opcode_AddImm =>
                        o_ALUOp     <= chip8_alu_add;
                        o_ALU_VXSrc <= chip8_alu_vx_normal;
                        o_ALU_VYSrc <= chip8_alu_vy_imm;
                    when chip8_instr_opcode_ALUExec =>
                        o_ALUOp     <= i_InstrSub;
                        o_ALU_VXSrc <= chip8_alu_vx_normal;
                        o_ALU_VYSrc <= chip8_alu_vy_normal;
                   when others =>
                        o_ALUOp     <= chip8_alu_nop;
                        o_ALU_VXSrc <= chip8_alu_vx_normal;
                        o_ALU_VYSrc <= chip8_alu_vy_normal;
                end case;
            when chip8_fsm_state_writeVX =>
                o_PCWrite   <= '0';
                o_IRWrite   <= '0';
                o_RRWrite   <= '0';
                o_RFWrite   <= '1';
                o_ALUOp     <= chip8_alu_nop;
                o_ALU_VXSrc <= chip8_alu_vx_normal;
                o_ALU_VYSrc <= chip8_alu_vy_normal;
                o_RF_VXSrc  <= chip8_rf_vx_normal;
            when chip8_fsm_state_writeVF =>
                o_PCWrite   <= '0';
                o_IRWrite   <= '0';
                o_RRWrite   <= '0';
                o_RFWrite   <= '1';
                o_ALUOp     <= chip8_alu_nop;
                o_ALU_VXSrc <= chip8_alu_vx_normal;
                o_ALU_VYSrc <= chip8_alu_vy_normal;
                o_RF_VXSrc  <= chip8_rf_vx_vf;
            when others =>
                o_PCWrite   <= '0';
                o_IRWrite   <= '0';
                o_RRWrite   <= '0';
                o_RFWrite   <= '0';
                o_ALUOp     <= chip8_alu_nop;
                o_ALU_VXSrc <= chip8_alu_vx_normal;
                o_ALU_VYSrc <= chip8_alu_vy_normal;
                o_RF_VXSrc  <= chip8_rf_vx_vf;
        end case;
    end process;
end architecture;