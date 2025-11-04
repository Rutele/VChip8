library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.chip8_const_pkg.all;

entity MUX2 is
  generic (
    DATA_WIDTH : integer := CHIP8_WORD_SIZE
  );
  port (
    i_Sel : in std_logic;
    i_Data1 : in std_logic_vector(DATA_WIDTH-1 downto 0);
    i_Data2 : in std_logic_vector(DATA_WIDTH-1 downto 0);
    o_Data : out std_logic_vector(DATA_WIDTH-1 downto 0)
  );
end entity;

architecture RTL of MUX2 is

  attribute syn_noprune : boolean;
  attribute syn_noprune of RTL : architecture is true;

begin

    process(i_Sel, i_Data1, i_Data2) is
    begin
        case i_Sel is
            when '0' => o_Data <= i_Data1;
            when '1' => o_Data <= i_Data2;
            when others => o_Data <= (others => '0');
        end case;
    end process;

end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.chip8_const_pkg.all;

entity MUX4 is
  generic (
    DATA_WIDTH : integer := CHIP8_WORD_SIZE
  );
  port (
    i_Sel   : in std_logic_vector(1 downto 0);
    i_Data1 : in std_logic_vector(DATA_WIDTH-1 downto 0);
    i_Data2 : in std_logic_vector(DATA_WIDTH-1 downto 0);
    i_Data3 : in std_logic_vector(DATA_WIDTH-1 downto 0);
    i_Data4 : in std_logic_vector(DATA_WIDTH-1 downto 0);
    o_Data  : out std_logic_vector(DATA_WIDTH-1 downto 0)
  );
end entity;

architecture RTL of MUX4 is

  attribute syn_noprune : boolean;
  attribute syn_noprune of RTL : architecture is true;

begin

    process(i_Sel, i_Data1, i_Data2, i_Data3) is
    begin
        case i_Sel is
            when "00" => o_Data <= i_Data1;
            when "01" => o_Data <= i_Data2;
            when "10" => o_Data <= i_Data3;
            when "11" => o_Data <= i_Data4;
            when others => o_Data <= (others => '0');
        end case;
    end process;

end architecture;

