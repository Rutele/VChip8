library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.chip8_const_pkg.all;

package chip8_types_pkg is
    -- TYPES
    -- ALU Types
    type chip8_alu_op_t is (chip8_alu_nop, chip8_alu_add, chip8_alu_sub,
                            chip8_alu_and, chip8_alu_or, chip8_alu_xor,
                            chip8_alu_sr, chip8_alu_sl);
    -- Register File Types
    type reg_arr_t is array (0 to REG_COUNT-1) of std_logic_vector(REG_DATA_WIDTH-1 downto 0);

    -- Instruction Decoder Types
    type chip8_instr_opcode_t is (chip8_instr_opcode_StoreImm, chip8_instr_opcode_ALUExec,
                                  chip8_instr_opcode_AddImm, chip8_instr_opcode_Illegal);

    type chip8_fsm_state_t is (chip8_fsm_state_fetch, chip8_fsm_state_decode,
                               chip8_fsm_state_writeVX, chip8_fsm_state_writeVF);

    type chip8_alu_vx_t is (chip8_alu_vx_normal, chip8_alu_vx_zero);
    type chip8_alu_vy_t is (chip8_alu_vy_normal, chip8_alu_vy_imm, chip8_alu_vy_pc);
    type chip8_rf_vx_src_t is (chip8_rf_vx_normal, chip8_rf_vx_vf);

    --FUNCTIONS
    function inst_msb_to_inst_type(inst_msb: std_logic_vector(3 downto 0)) return chip8_instr_opcode_t;
    function inst_lsb_to_instsub_type(inst_lsb: std_logic_vector(3 downto 0)) return chip8_alu_op_t;
    function alu_vx_src_to_signal(src: chip8_alu_vx_t) return std_logic;
    function rf_vx_src_to_signal(src: chip8_rf_vx_src_t) return std_logic;
    function alu_vy_src_to_signal(src: chip8_alu_vy_t) return std_logic_vector;

end package;

package body chip8_types_pkg is

    function inst_msb_to_inst_type(inst_msb: std_logic_vector(3 downto 0)) return chip8_instr_opcode_t is
    begin
        case inst_msb is
            when "0110" => return chip8_instr_opcode_StoreImm;
            when "0111" => return chip8_instr_opcode_AddImm;
            when "1000" => return chip8_instr_opcode_ALUExec;
            when others => return chip8_instr_opcode_Illegal;
        end case;
    end function;

    function inst_lsb_to_instsub_type(inst_lsb: std_logic_vector(3 downto 0)) return chip8_alu_op_t is
    begin
        case inst_lsb is
            when "0000" => return chip8_alu_add; -- TODO: Check if decoder supports it (setting VX and VY src)
            when "0001" => return chip8_alu_or;
            when "0010" => return chip8_alu_and;
            when "0011" => return chip8_alu_xor;
            when "0100" => return chip8_alu_add;
            when "0110" => return chip8_alu_sr;
            when "0101" => return chip8_alu_sub;
            when "0111" => return chip8_alu_sub; -- TODO: Check if decoder supports it (setting VX and VY src)
            when "1110" => return chip8_alu_sl;
            when others => return chip8_alu_nop;
        end case;
    end function;

    function alu_vx_src_to_signal(src: chip8_alu_vx_t) return std_logic is
    begin
        case src is
            when chip8_alu_vx_normal => return '0';
            when chip8_alu_vx_zero => return '1';
            when others => return '0';
        end case;
    end function;

    function rf_vx_src_to_signal(src: chip8_rf_vx_src_t) return std_logic is
    begin
        case src is
            when chip8_rf_vx_normal => return '0';
            when chip8_rf_vx_vf => return '1';
            when others => return '0';
        end case;
    end function;

    function alu_vy_src_to_signal(src: chip8_alu_vy_t) return std_logic_vector is
    begin
        case src is
            when chip8_alu_vy_normal => return "00";
            when chip8_alu_vy_imm => return "01";
            when chip8_alu_vy_pc => return "10";
            when others => return "00";
        end case;
    end function;
        
end package body;
