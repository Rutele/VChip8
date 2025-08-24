library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.chip8_const_pkg.all;

package chip8_types_pkg is
    
    -- Register File Constants
    type reg_arr_t is array (0 to REG_COUNT-1) of std_logic_vector(REG_DATA_WIDTH-1 downto 0);

end package;

package body chip8_types_pkg is
end package body;
