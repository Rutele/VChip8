library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.chip8_const_pkg.all;
use work.chip8_types_pkg.all;

entity ALUDecoder_TB is
end entity;

architecture SIM of ALUDecoder_TB is
    signal i_Clk : std_logic := '0';
    signal i_Rst : std_logic;
    signal i_InstrOpcode : chip8_instr_opcode_t;
    signal i_InstrSub : chip8_alu_op_t;
    signal i_FSMState : chip8_fsm_state_t;
    signal o_ALU_VXSrc : std_logic_vector(1 downto 0);
    signal o_ALU_VYSrc : std_logic_vector(1 downto 0);
    signal o_ALUOp : chip8_alu_op_t;
begin

    i_Clk <= not i_Clk after 2 ns;

    DUT: entity work.ALUDecoder(RTL)
    port map(
        i_Clk => i_Clk,
        i_Rst => i_Rst,
        i_InstrOpcode => i_InstrOpcode,
        i_InstrSub => i_InstrSub,
        i_FSMState => i_FSMState,
        o_ALU_VXSrc => o_ALU_VXSrc,
        o_ALU_VYSrc => o_ALU_VYSrc,
        o_ALUOp => o_ALUOp
    );

    process is
    begin
        i_Rst <= '1';
        i_InstrOpcode <= chip8_instr_opcode_store_imm;
        i_InstrSub <= chip8_alu_nop;
        i_FSMState <= chip8_fsm_state_fetch;
        wait for 10 ns;

        -- Check the reset state
        assert (o_ALU_VXSrc = "00")
            report "ALU VX Src not zero on reset" severity failure;
        assert (o_ALU_VYSrc = "00")
            report "ALU VY Src not zero on reset" severity failure;
        assert (o_ALUOp = chip8_alu_add)
            report "ALU Operation not ADD on reset" severity failure;

        i_Rst <= '0';

        -- Check the output during the fetch phase
        wait for 6 ns;
        assert (o_ALU_VXSrc = "10")
            report "ALU VX Src not 10 during fetch" severity failure;
        assert (o_ALU_VYSrc = "11")
            report "ALU VY Src 11 during fetch" severity failure;
        assert (o_ALUOp = chip8_alu_add)
            report "ALU Operation not ADD during fetch" severity failure;

        -- Change InstrSub
        i_InstrSub <= chip8_alu_or;
        wait for 4 ns;
        assert (o_ALUOp = chip8_alu_add)
            report "ALU Operation changed during fetch" severity failure;

        -- Check outputs in decode phase
        -- Store Immediate check
        i_FSMState <= chip8_fsm_state_decode;
        i_InstrOpcode <= chip8_instr_opcode_store_imm;
        wait for 4 ns;
        assert (o_ALU_VXSrc = "00")
            report "ALU VX Src not 00 for store imm" severity failure;
        assert (o_ALU_VYSrc = "01")
            report "ALU VY Src not 01 for store imm" severity failure;
        assert (o_ALUOp = chip8_alu_add)
            report "ALU Operation not ADD for store imm" severity failure;

        -- Add Immediate check
        i_InstrOpcode <= chip8_instr_opcode_add_imm;
        wait for 4 ns;
        assert (o_ALU_VXSrc = "00")
            report "ALU VX Src not 00 for add imm" severity failure;
        assert (o_ALU_VYSrc = "10")
            report "ALU VY Src not 10 for add imm" severity failure;
        assert (o_ALUOp = chip8_alu_add)
            report "ALU Operation not ADD for add imm" severity failure;

        -- ALU Calc check
        -- Store VY in VX check
        i_InstrOpcode <= chip8_instr_opcode_ALU_calc;
        i_InstrSub <= chip8_alu_nop;
        wait for 4 ns;
        assert (o_ALU_VXSrc = "01")
            report "ALU VX Src not 01 for VY store" severity failure;
        assert (o_ALU_VYSrc = "00")
            report "ALU VY Src not 00 for VY store" severity failure;
        assert (o_ALUOp = chip8_alu_add)
            report "ALU Operation not ADD for VY store" severity failure;

        -- Check other ALU operations
        i_InstrSub <= chip8_alu_or;
        wait for 4 ns;
        assert (o_ALUOp = chip8_alu_or)
            report "ALU Operation not OR" severity failure;
        i_InstrSub <= chip8_alu_sub;
        wait for 4 ns;
        assert (o_ALUOp = chip8_alu_sub)
            report "ALU Operation not SUB" severity failure;
        i_InstrSub <= chip8_alu_sr;
        wait for 4 ns;
        assert (o_ALUOp = chip8_alu_sr)
            report "ALU Operation not SR" severity failure;

        -- Check unknown instructions
        i_InstrOpcode <= chip8_instr_opcode_illegal;
        wait for 4 ns;
        assert (o_ALUOp = chip8_alu_nop)
            report "Illegal operation not NOP" severity failure;

        wait;
    end process;

end architecture;