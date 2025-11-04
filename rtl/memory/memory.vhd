library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.chip8_const_pkg.all;
use work.chip8_types_pkg.all;

entity Memory is
    port (
      i_Clk: in std_logic;
      i_Write: in std_logic;
      i_Address: in std_logic_vector(CHIP8_ADDRESS_SIZE-1 downto 0);
      i_Data: in std_logic_vector(CHIP8_WORD_SIZE-1 downto 0);
      o_Data: out std_logic_vector(CHIP8_INSTR_SIZE-1 downto 0)
    );

end entity;

architecture RTL of Memory is

    attribute syn_noprune : boolean;
    attribute syn_noprune of RTL : architecture is true;

    attribute syn_preserve : boolean;
    attribute syn_preserve of RTL : architecture is true;

    signal m_Memory: mem_arr_t := MEM_INIT;
    attribute syn_ramstyle : string;
    attribute syn_ramstyle of m_Memory : signal is "rw_check";

    signal r_Address    : integer range 0 to 2**CHIP8_ADDRESS_SIZE-1;
    signal r_Data       : std_logic_vector(CHIP8_INSTR_SIZE-1 downto 0);
    attribute syn_keep : boolean;
    attribute syn_keep of r_Data : signal is true;

begin

    process(i_Clk) is
    begin
        if rising_edge(i_Clk) then
            r_Address <= to_integer(unsigned(i_Address));
        end if;
    end process;
    
    process(i_Clk) is
    begin

        if rising_edge(i_Clk) then
            if (i_Write = '1') then
                m_Memory(r_Address) <= i_Data;
            end if;
        end if;
    end process;

    o_Data <= m_Memory(r_Address) & m_Memory(r_Address + 1);

end architecture;
