library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.chip8_const_pkg.all;
use work.chip8_types_pkg.all;
use work.chip8_decoder_types_pkg.all;

entity Top is
  port (
    i_Clk : in std_logic;
    i_Rst : in std_logic
  );
end entity;

architecture RTL of Top is

    signal w_Write          : std_logic;
    signal w_Instruction    : std_logic_vector(CHIP8_INSTR_SIZE-1 downto 0);
    signal w_Address        : std_logic_vector(CHIP8_ADDRESS_SIZE-1 downto 0);
    signal w_ALUOp          : chip8_alu_op_t;
    signal w_SelSignals     : chip8_select_signals_t;
    signal w_WriteSignals   : chip8_write_signals_t;
    signal w_InstrTyped     : chip8_instr_opcode_t;
    signal w_InstrSubTyped  : chip8_alu_op_t;

begin

    w_Write <= '0';

    Memory: entity work.Memory(RTL) /* synthesis syn_noprune =1 syn_sle_debug=1 */
    port map(
      i_Clk => i_Clk,
      i_Write => w_Write,
      i_Address => w_Address,
      i_Data => (others => '1'),
      o_Data => w_Instruction
    );

    Datapath: entity work.Datapath(RTL)
    port map(
        i_Clk => i_Clk,
        i_RSt => i_Rst,
        i_Instruction => w_Instruction,
        i_ALUOp => w_ALUOp,
        i_SelSignals => w_SelSignals,
        i_WriteSignals => w_WriteSignals,
        o_Address => w_Address,
        o_InstrTyped => w_InstrTyped,
        o_InstrSubTyped => w_InstrSubTyped
    );

    Decoder: entity work.InstructionDecoder(RTL)
    port map(
        i_Clk => i_Clk,
        i_Rst => i_Rst,
        i_InstrOpcode => w_InstrTyped,
        i_InstrSub => w_InstrSubTyped,
        o_ALUOp => w_ALUOp,
        o_SelSignals => w_SelSignals,
        o_WriteSignals => w_WriteSignals
    );

end architecture;
