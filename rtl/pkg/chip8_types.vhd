library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.chip8_const_pkg.all;

package chip8_types_pkg is
    -- TYPES
    type reg_arr_t is array (0 to REG_COUNT-1) of std_logic_vector(REG_DATA_WIDTH-1 downto 0);
    type mem_arr_t is array (0 to MEM_SIZE-1) of std_logic_vector(CHIP8_WORD_SIZE-1 downto 0);

    constant MEM_INIT: mem_arr_t := (
        512 => x"60",   -- 60FF
        513 => x"FF",   -- Store FF in V0
        514 => x"61",   -- 61BE
        515 => x"BE",   -- Store BE in V1 
        516 => x"82",   -- 8210
        517 => x"10",   -- Store V1 in V2
        518 => x"70",   -- 7002
        519 => x"02",   -- Add 02 to V0
        520 => x"81",   -- 8124
        521 => x"24",   -- Add V2 to V1
        522 => x"82",   -- 82Y5
        523 => x"15",   -- Sub V1 from V2
        524 => x"81",   -- 8127
        525 => x"27",   -- Sub V2 from V1, store in V2
        526 => x"82",   -- 8XY2
        527 => x"12",   -- Set V2 to V2 AND V1
        528 => x"83",   -- 8XY1
        529 => x"21",   -- Set V3 to V3 OR V1
        530 => x"82",   -- 8XY3
        531 => x"13",   -- Set V2 to V2 XOR V1
        532 => x"80",   -- 8XY6
        533 => x"36",   -- Shift VY right and store in VX
        534 => x"81",   -- 8XYE
        535 => x"3E",   -- Shift VY left and store in VX
        536 => x"C4",   -- CXNN 
        537 => x"FF",   -- Set V4 to RNG AND FF
        538 => x"C5",   -- CXNN
        539 => x"AA",   -- Set V5 to RNG AND AA
        others => x"00"
    );

    type chip8_alu_op_t is (chip8_alu_nop, chip8_alu_add, chip8_alu_sub,
                        chip8_alu_and, chip8_alu_or, chip8_alu_xor,
                        chip8_alu_sr, chip8_alu_sl, chip8_alu_store_vy,
                        chip8_alu_sub_swap);

    type chip8_instr_opcode_t is (chip8_instr_opcode_Illegal, chip8_instr_opcode_StoreImm,
                                  chip8_instr_opcode_ALUExec, chip8_instr_opcode_AddImm,
                                  chip8_instr_opcode_SetRandom);

    --FUNCTIONS
    function inst_msb_to_inst_type(inst_msb: std_logic_vector(3 downto 0)) return chip8_instr_opcode_t;
    function inst_lsb_to_instsub_type(inst_lsb: std_logic_vector(3 downto 0)) return chip8_alu_op_t;

end package;

package body chip8_types_pkg is

    function inst_msb_to_inst_type(inst_msb: std_logic_vector(3 downto 0)) return chip8_instr_opcode_t is
    begin
        case inst_msb is
            when "0110" => return chip8_instr_opcode_StoreImm;
            when "0111" => return chip8_instr_opcode_AddImm;
            when "1000" => return chip8_instr_opcode_ALUExec;
            when "1100" => return chip8_instr_opcode_SetRandom;
            when others => return chip8_instr_opcode_Illegal;
        end case;
    end function;

    function inst_lsb_to_instsub_type(inst_lsb: std_logic_vector(3 downto 0)) return chip8_alu_op_t is
    begin
        case inst_lsb is
            when "0000" => return chip8_alu_store_vy;
            when "0001" => return chip8_alu_or;
            when "0010" => return chip8_alu_and;
            when "0011" => return chip8_alu_xor;
            when "0100" => return chip8_alu_add;
            when "0110" => return chip8_alu_sr;
            when "0101" => return chip8_alu_sub;
            when "0111" => return chip8_alu_sub_swap;
            when "1110" => return chip8_alu_sl;
            when others => return chip8_alu_nop;
        end case;
    end function;
        
end package body;
