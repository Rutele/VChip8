library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.chip8_const_pkg.all;


package chip8_tb_functions_pkg is
    function chip8_tb_alu_add_func (VX: unsigned(CHIP8_WORD_SIZE-1 downto 0);
                                    VY: unsigned(CHIP8_WORD_SIZE-1 downto 0))
                                    return std_logic_vector;

    function chip8_tb_alu_sub_func (VX: unsigned(CHIP8_WORD_SIZE-1 downto 0);
                                    VY: unsigned(CHIP8_WORD_SIZE-1 downto 0))
                                    return std_logic_vector;
end package;

package body chip8_tb_functions_pkg is
    function chip8_tb_alu_add_func  (VX: unsigned(CHIP8_WORD_SIZE-1 downto 0);
                                     VY: unsigned(CHIP8_WORD_SIZE-1 downto 0))
                                     return std_logic_vector is

            variable v_VX, v_VY, v_Result: unsigned(CHIP8_WORD_SIZE downto 0) := (others => '0');

            begin
                v_VX := '0' & VX;
                v_VY := '0' & VY;
                v_Result := v_VX + v_VY;
                return std_logic_vector(v_Result);
            end chip8_tb_alu_add_func;

    function chip8_tb_alu_sub_func  (VX: unsigned(CHIP8_WORD_SIZE-1 downto 0);
                                     VY: unsigned(CHIP8_WORD_SIZE-1 downto 0))
                                     return std_logic_vector is

                variable v_VX, v_VY, v_Result: unsigned(CHIP8_WORD_SIZE downto 0) := (others => '0');

                begin
                    v_VX := '0' & VX;
                    v_VY := '0' & VY;
                    v_Result := v_VX - v_VY;
                    return std_logic_vector(v_Result);
                end chip8_tb_alu_sub_func;

end package body;