library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std_unsigned.all;
use work.chip8_const_pkg.all;
use work.chip8_types_pkg.all;

entity RegisterFile_TB is
end RegisterFile_TB;

architecture SIM of RegisterFile_TB is

    signal i_Clk: std_logic := '0'; 
    signal i_Rst: std_logic;
    signal i_SelX, i_SelY: std_logic_vector(REG_SEL_WIDTH-1 downto 0);
    signal i_WriteEnable: std_logic;
    signal i_WriteData: std_logic_vector(REG_DATA_WIDTH-1 downto 0);
    signal o_DataX, o_DataY: std_logic_vector(REG_DATA_WIDTH-1 downto 0);

begin

    DUT: entity work.RegisterFile(RTL)
    port map(
        i_Clk => i_Clk,
        i_Rst => i_Rst,
        i_SelX => i_SelX,
        i_SelY => i_SelY,
        i_WriteEnable => i_WriteEnable,
        i_WriteData => i_WriteData,
        o_DataX => o_DataX,
        o_DataY => o_DataY
    );

    i_Clk <= not i_Clk after 2 ns;

    process is
    begin
        -- Reset the register file and check all locations
        i_Rst <= '1';
        i_SelX <= (others => '0');
        i_SelY <= (others => '0');
        i_WriteEnable <= '0';
        i_WriteData <= (others => '0');

        wait for 10 ns;    
        i_Rst <= '0';
    
        for i in 0 to REG_COUNT-1 loop
            i_SelX <= to_std_logic_vector(i, i_SelX'length);
            wait for 2 ns;
            assert (o_DataX = 0) 
                report "Register V" & to_string(i) & " not zero after reset." 
                severity failure;
        end loop;
        i_SelX <= (others => '0');

        -- Write over all registers using X and check with Y
        i_WriteEnable <= '1';
        i_WriteData <= "01011010";
        wait for 6 ns;
    
        for i in 0 to REG_COUNT-1 loop
            i_SelX <= to_std_logic_vector(i, i_SelX'length);
            i_SelY <= to_std_logic_vector(i, i_SelX'length);
            wait for 4 ns;
            assert (o_DataY = "01011010")
                report "Register V" & to_string(i) & " not written."
                severity failure;
        end loop;
        i_WriteEnable <= '0';
        i_Rst <= '1';
        wait for 6 ns;

        -- Check registers using Y
        i_Rst <= '0';
        for i in 0 to REG_COUNT-1 loop
            i_SelY <= to_std_logic_vector(i, i_SelY'length);
            wait for 4 ns;
            assert (o_DataY = "00000000")
                report "Register V" & to_string(i) & " not accessed via Y."
                severity failure;
        end loop;
        i_SelY <= (others => '0');

        -- Check if under reset we don't write anything
        i_Rst <= '1';
        wait for 6 ns;
        i_WriteData <= "11110000";
        i_WriteEnable <= '1';
        wait for 6 ns;
        
        for i in 0 to REG_COUNT-1 loop
            i_SelX <= to_std_logic_vector(i, i_SelX'length);
            wait for 4 ns;
            assert (o_DataX = "00000000")
                report "Register V" & to_string(i) & " written during reset."
                severity failure;
        end loop;

        wait;
    end process;

end architecture;