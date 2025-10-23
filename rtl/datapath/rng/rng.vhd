library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.chip8_const_pkg.all;

entity RNG is
    generic(
        SEED: std_logic_vector(CHIP8_WORD_SIZE-1 downto 0) := "00110011"
    );

    port(
        i_Rst : in std_logic;
        i_Clk : in std_logic;
        i_Mask : in std_logic_vector(CHIP8_WORD_SIZE-1 downto 0);
        o_RandomNumber : out std_logic_vector(CHIP8_WORD_SIZE-1 downto 0)
    );
end entity;

architecture RTL of RNG is
    signal r_LFSR : std_logic_vector(CHIP8_WORD_SIZE-1 downto 0);
    signal w_XNOR : std_logic;
begin
    process(i_Rst, i_Clk) is
    begin
        if i_Rst = '1' then
            r_LFSR <= SEED;
        elsif rising_edge(i_Clk) then
            r_LFSR <= r_LFSR(CHIP8_WORD_SIZE-2 downto 0) & w_XNOR;
        end if;
    end process;

    w_XNOR <= r_LFSR(CHIP8_WORD_SIZE-1) xnor r_LFSR(CHIP8_WORD_SIZE-2);
    o_RandomNumber <= r_LFSR and i_Mask;

end architecture;
