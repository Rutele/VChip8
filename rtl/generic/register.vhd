library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.chip8_const_pkg.all;

entity GenericRegister is
    generic (
        WIDTH : integer := CHIP8_WORD_SIZE
    );
    port (
        i_Clk  : in  std_logic;
        i_Rst  : in  std_logic;
        i_Write: in  std_logic;
        i_D    : in  std_logic_vector(WIDTH-1 downto 0);
        o_Q    : out std_logic_vector(WIDTH-1 downto 0)
    );
end entity;

architecture RTL of GenericRegister is

    attribute syn_noprune : boolean;
    attribute syn_noprune of RTL : architecture is true;

begin
    process(i_Clk)
    begin
        if rising_edge(i_Clk) then
            if i_Rst = '1' then
                o_Q <= (others => '0');
            elsif i_Write = '1' then
                o_Q <= i_D;
            end if;
        end if;
    end process;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.chip8_const_pkg.all;

entity GenericRegisterLogic is
    port (
        i_Clk  : in  std_logic;
        i_Rst  : in  std_logic;
        i_Write: in  std_logic;
        i_D    : in  std_logic;
        o_Q    : out std_logic
    );
end entity;

architecture RTL of GenericRegisterLogic is

    attribute syn_noprune : boolean;
    attribute syn_noprune of RTL : architecture is true;

begin
    process(i_Clk)
    begin
        if rising_edge(i_Clk) then
            if i_Rst = '1' then
                o_Q <= '0';
            elsif i_Write = '1' then
                o_Q <= i_D;
            end if;
        end if;
    end process;
end architecture;
