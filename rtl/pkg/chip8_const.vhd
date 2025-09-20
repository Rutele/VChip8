library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package chip8_const_pkg is

    -- General Constants
    constant CHIP8_ADDRESS_SIZE: integer := 16;
    constant CHIP8_INSTR_SIZE: integer := 16;
    constant CHIP8_WORD_SIZE: integer := 8;

    -- ALU Constants
    constant CHIP8_ALU_CTRL_SIZE: integer := 3;

    -- Register File Constants
    constant REG_COUNT: integer := 16;
    constant REG_DATA_WIDTH: integer := 8;
    constant REG_SEL_WIDTH: integer := 4;

end package;

package body chip8_const_pkg is
end package body;
