library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.chip8_const_pkg.all;

package chip8_decoder_types_pkg is
    -- TYPES
    type chip8_fsm_state_t is (chip8_fsm_state_fetch, chip8_fsm_state_decode,
                               chip8_fsm_state_writeVX, chip8_fsm_state_writeVF,
                               chip8_fsm_state_reset);
    -- Select Signals Types
    type chip8_alu_vx_t is (chip8_alu_vx_normal, chip8_alu_vx_zero);
    type chip8_alu_vy_t is (chip8_alu_vy_normal, chip8_alu_vy_imm);
    type chip8_rf_vx_src_t is (chip8_rf_vx_normal, chip8_rf_vx_vf);

    type chip8_select_signals_t is record
        alu_vx : chip8_alu_vx_t;
        alu_vy : chip8_alu_vy_t;
        rf_vx  : chip8_rf_vx_src_t;
    end record chip8_select_signals_t;

    constant CHIP8_SELECT_DEFAULT : chip8_select_signals_t := (
        alu_vx => chip8_alu_vx_normal,
        alu_vy => chip8_alu_vy_normal,
        rf_vx => chip8_rf_vx_normal
    );

    -- Write Signals Types
    type chip8_write_signals_t is record
        PCWrite : std_logic;
        IRWrite : std_logic;
        RRWrite : std_logic;
        RFWrite : std_logic;
    end record chip8_write_signals_t;

    constant CHIP8_WRITE_DEFAULT : chip8_write_signals_t := (
        PCWrite => '0',
        IRWrite => '0',
        RRWrite => '0',
        RFWrite => '0'
    );

    -- FUNCTIONS
    function alu_vx_src_to_signal(src: chip8_alu_vx_t) return std_logic;
    function alu_vy_src_to_signal(src: chip8_alu_vy_t) return std_logic;
    function rf_vx_src_to_signal(src: chip8_rf_vx_src_t) return std_logic;

end package;

package body chip8_decoder_types_pkg is

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

    function alu_vy_src_to_signal(src: chip8_alu_vy_t) return std_logic is
    begin
        case src is
            when chip8_alu_vy_normal => return '0';
            when chip8_alu_vy_imm => return '1';
            when others => return '0';
        end case;
    end function;

end package body;
