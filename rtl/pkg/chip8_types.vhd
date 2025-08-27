library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.chip8_const_pkg.all;

package chip8_types_pkg is
    
    -- ALU File Types
    subtype chip8_alu_ctrl_t is std_logic_vector(CHIP8_ALU_CTRL_SIZE-1 downto 0);

    -- Register File Types
    type reg_arr_t is array (0 to REG_COUNT-1) of std_logic_vector(REG_DATA_WIDTH-1 downto 0);

end package;

package body chip8_types_pkg is
end package body;
