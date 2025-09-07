library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.chip8_const_pkg.all;
use work.chip8_types_pkg.all;
use work.chip8_tb_functions_pkg.all;

entity CHIP8_ALU_TB is
end CHIP8_ALU_TB;

architecture SIM of CHIP8_ALU_TB is

    signal wi_VX, wi_VY: std_logic_vector(CHIP8_WORD_SIZE-1 downto 0);
    signal wi_ALUCtrl: chip8_alu_op_t;
    signal wo_ALUResult: std_logic_vector(CHIP8_WORD_SIZE-1 downto 0);
    signal wo_Flag: std_logic;
    
begin

    DUT: entity work.CHIP8_ALU(RTL)
    port map(
        i_VX => wi_VX,
        i_VY => wi_VY,
        i_ALUCtrl => wi_ALUCtrl,
        o_ALUResult => wo_ALUResult,
        o_Flag => wo_Flag
    );

    process is

        variable v_VX, v_VY: unsigned(CHIP8_WORD_SIZE-1 downto 0);
        variable v_ALUFunctionResult: std_logic_vector(CHIP8_WORD_SIZE downto 0);

    begin
        -- initialise variables
        v_VX := (others => '0');
        v_VY := (others => '0');
        v_ALUFunctionResult := (others => '0');

        -- chip8_alu_add tests
        wi_ALUCtrl <= chip8_alu_add;

        for i in 0 to 255 loop
            for j in 0 to 255 loop
                v_VX := to_unsigned(i, wi_VX'length);
                v_VY := to_unsigned(j, wi_VY'length);
                wi_VX <= std_logic_vector(v_VX);
                wi_VY <= std_logic_vector(v_VY);
                
                v_ALUFunctionResult := chip8_tb_alu_add_func(VX => v_VX,
                                                            VY => v_VY);
                wait for 1 ns;

                assert(wo_ALUResult = v_ALUFunctionResult(CHIP8_WORD_SIZE-1 downto 0))
                    report integer'image(i) & "+" & integer'image(j) & " failed" severity failure;

                assert(wo_Flag = v_ALUFunctionResult(CHIP8_WORD_SIZE))
                    report integer'image(i) & "+" & integer'image(j) & " carry failed" severity failure;
            end loop;
        end loop;

        wi_VX <= (others => '0');
        wi_VY <= (others => '0');
        wait for 1 ns;

        -- chip8_alu_sub tests
        wi_ALUCtrl <= chip8_alu_sub;

        for i in 0 to 255 loop
            for j in 0 to 255 loop
                v_VX := to_unsigned(i, wi_VX'length);
                v_VY := to_unsigned(j, wi_VY'length);
                wi_VX <= std_logic_vector(v_VX);
                wi_VY <= std_logic_vector(v_VY);
                
                v_ALUFunctionResult := chip8_tb_alu_sub_func(VX => v_VX,
                                                            VY => v_VY);
                wait for 1 ns;

                assert(wo_ALUResult = v_ALUFunctionResult(CHIP8_WORD_SIZE-1 downto 0))
                    report integer'image(i) & "-" & integer'image(j) & " failed" severity failure;

                assert(wo_Flag /= v_ALUFunctionResult(CHIP8_WORD_SIZE))
                    report integer'image(i) & "-" & integer'image(j) & " borrow failed" severity failure;
            end loop;
        end loop;

        wait;

    end process;
end architecture;