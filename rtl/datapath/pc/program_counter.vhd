library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.chip8_const_pkg.all;
use work.chip8_types_pkg.all;

entity ProgramCounter is
  port (
    i_Clk : in std_logic;
    i_Rst : in std_logic;
    i_Write : in std_logic;
    o_InstrAddress : out std_logic_vector(CHIP8_ADDRESS_SIZE-1 downto 0)
  );
end entity;

architecture RTL of ProgramCounter is

    attribute syn_preserve : boolean;
    attribute syn_preserve of RTL : architecture is true;

    attribute syn_noprune : boolean;
    attribute syn_noprune of RTL : architecture is true;

    signal w_NextAddress : std_logic_vector(CHIP8_ADDRESS_SIZE-1 downto 0);

begin

    w_NextAddress <= std_logic_vector(unsigned(o_InstrAddress) + 2);

    PC: entity work.GenericRegister(RTL)
    generic map(
        WIDTH => CHIP8_ADDRESS_SIZE
    )
    port map (
        i_Clk => i_Clk,
        i_Rst => i_Rst,
        i_Write => i_Write,
        i_D => w_NextAddress,
        o_Q => o_InstrAddress
    );

end architecture;
