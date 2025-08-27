library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.chip8_const_pkg.all;
use work.chip8_types_pkg.all;

entity CHIP8_ALU is
    port(
        i_VX, i_VY: in std_logic_vector(CHIP8_WORD_SIZE-1 downto 0);
        i_ALUCtrl: in std_logic_vector(CHIP8_ALU_CTRL_SIZE-1 downto 0);
        o_ALUData: out std_logic_vector(CHIP8_WORD_SIZE-1 downto 0);
        o_CB: out std_logic    -- Carry or borrow flag
    );
end CHIP8_ALU;

architecture RTL of CHIP8_ALU is

    constant CHIP8_ALU_ADD: chip8_alu_ctrl_t := "000";
    constant CHIP8_ALU_SUB: chip8_alu_ctrl_t := "001";
    constant CHIP8_ALU_AND: chip8_alu_ctrl_t := "010";
    constant CHIP8_ALU_OR:  chip8_alu_ctrl_t := "011";
    constant CHIP8_ALU_XOR: chip8_alu_ctrl_t := "100";
    constant CHIP8_ALU_SR:  chip8_alu_ctrl_t := "101";
    constant CHIP8_ALU_SL:  chip8_alu_ctrl_t := "110";

    signal w_Result: std_logic_vector(CHIP8_WORD_SIZE downto 0);
begin

    process(all) is
    begin
        case i_ALUCtrl is
            when CHIP8_ALU_ADD =>
                w_Result <= ('0' & i_VX) + ('0' & i_VY);
            when CHIP8_ALU_SUB =>
                w_Result <= ('0' & i_VX) - ('0' & i_VY);
            when CHIP8_ALU_AND =>
                w_Result <= '0' & (i_VX and i_VY);
            when CHIP8_ALU_OR =>
                w_Result <= '0' & (i_VX or i_VY);
            when CHIP8_ALU_XOR =>
                w_Result <= '0' & (i_VX xor i_VY);
            when CHIP8_ALU_SR =>
                w_Result <= "00" & i_Vy(CHIP8_WORD_SIZE-1 downto 1);
            when CHIP8_ALU_SL =>
                w_Result <= '0' & i_Vy(CHIP8_WORD_SIZE-1 downto 1) & '0';
            when others =>
                w_Result <= (others => '0');
        end case;

        o_ALUData <= w_Result(CHIP8_WORD_SIZE-1 downto 0);
        o_CB <= w_Result(CHIP8_WORD_SIZE);

    end process;

end architecture;