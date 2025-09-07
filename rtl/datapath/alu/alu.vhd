library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.chip8_const_pkg.all;
use work.chip8_types_pkg.all;

entity CHIP8_ALU is
    port(
        i_VX, i_VY:     in std_logic_vector(CHIP8_WORD_SIZE-1 downto 0);
        i_ALUCtrl:      in chip8_alu_op_t;
        o_ALUResult:    out std_logic_vector(CHIP8_WORD_SIZE-1 downto 0);
        o_UniF:           out std_logic    -- Universal flag interpreted based on the instruction
    );
end CHIP8_ALU;

architecture RTL of CHIP8_ALU is
    signal w_Result: std_logic_vector(CHIP8_WORD_SIZE downto 0);
    signal w_Flag: std_logic;
begin

    process(all) is
    begin
        -- Default assignments
        w_Result <= (others => '0');
        w_Flag <= '0';

        case i_ALUCtrl is
            when chip8_alu_add =>
                w_Result <= std_logic_vector(unsigned('0' & i_VX) + unsigned('0' & i_VY));
                w_Flag <= w_Result(CHIP8_WORD_SIZE); -- Carry flag
            when chip8_alu_sub =>
                w_Result <= std_logic_vector(unsigned('0' & i_VX) - unsigned('0' & i_VY));
                w_Flag <= '1' when (unsigned(i_VX) >= unsigned(i_VY)) else '0';-- Set when no borrow occurs
            when chip8_alu_and =>
                w_Result <= '0' & (i_VX and i_VY);
            when chip8_alu_or =>
                w_Result <= '0' & (i_VX or i_VY);
            when chip8_alu_xor =>
                w_Result <= '0' & (i_VX xor i_VY);
            when chip8_alu_sr =>
                w_Result <= std_logic_vector(shift_right(unsigned('0' & i_VY), 1));
                w_Flag <= i_VY(0); -- Set the flag to the LSB prior to the shift
            when chip8_alu_sl =>
                w_Result <= std_logic_vector(shift_left(unsigned('0' & i_VY), 1));
                w_Flag <= i_VY(CHIP8_WORD_SIZE-1); -- Set the flag to the MSB prior to the shift
            when others =>
                w_Result <= (others => '0');
                w_Flag <= '0';
        end case;
    end process;

    o_ALUResult <= w_Result(CHIP8_WORD_SIZE-1 downto 0);
    o_UniF <= w_Flag;

end architecture RTL;
