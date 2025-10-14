library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std_unsigned.all;
use work.chip8_const_pkg.all;
use work.chip8_types_pkg.all;

entity RegisterFile is
    port (
        i_Clk : in std_logic;
        i_Rst : in std_logic;
        i_SelX : in std_logic_vector(REG_SEL_WIDTH-1 downto 0);
        i_SelY : in std_logic_vector(REG_SEL_WIDTH-1 downto 0);
        i_WriteEnable : in std_logic;
        i_WriteData : in std_logic_vector(REG_DATA_WIDTH-1 downto 0);
        o_DataX : out std_logic_vector(REG_DATA_WIDTH-1 downto 0);
        o_DataY : out std_logic_vector(REG_DATA_WIDTH-1 downto 0)
    );
end RegisterFile;

architecture RTL of RegisterFile is

    attribute syn_noprune : boolean;
    attribute syn_noprune of RTL : architecture is true;

    signal r_Registers: reg_arr_t;

begin

    process(i_Clk, i_Rst) is
    begin
        if rising_edge(i_Clk) then
            if i_Rst = '1' then
                r_Registers <= (others => (others => '0'));
            elsif i_WriteEnable = '1'
                then r_Registers(to_integer(i_SelX)) <= i_WriteData;
            end if;
        end if;
    end process;

    o_DataX <= r_Registers(to_integer(i_SelX));
    o_DataY <= r_Registers(to_integer(i_SelY));

end architecture;
