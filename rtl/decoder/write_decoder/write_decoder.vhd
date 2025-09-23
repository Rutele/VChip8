library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.chip8_types_pkg.all;
use work.chip8_decoder_types_pkg.all;

entity WriteDecoder is
    port(
        i_FSMState : in chip8_fsm_state_t;
        o_WriteSignals : out chip8_write_signals_t
    );
end entity;

architecture RTL of WriteDecoder is
    signal w_WriteSignals : chip8_write_signals_t;
begin

    process(i_FSMState) is
    begin

        w_WriteSignals <= CHIP8_WRITE_DEFAULT;

        case i_FSMState is
            when chip8_fsm_state_reset =>
                w_WriteSignals.IRWrite <= '1';
            when chip8_fsm_state_fetch =>
                w_WriteSignals.PCWrite <= '1';
                w_WriteSignals.IRWrite <= '1';
            when chip8_fsm_state_decode =>
                w_WriteSignals.RRWrite <= '1';
            when chip8_fsm_state_writeVX | chip8_fsm_state_writeVF =>
                w_WriteSignals.RFWrite <= '1';
            when others =>
                null;
        end case;
    end process;

    o_WriteSignals <= w_WriteSignals;
    
end architecture;
