library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.chip8_const_pkg.all;
use work.chip8_types_pkg.all;
use work.chip8_decoder_types_pkg.all;

entity Datapath is
    port(
        i_Clk: in std_logic;
        i_Rst: in std_logic;
        i_Instruction: in std_logic_vector(CHIP8_INSTR_SIZE-1 downto 0);
        o_Address: out std_logic_vector(CHIP8_ADDRESS_SIZE-1 downto 0)
    );
end entity;

architecture RTL of Datapath is

    -- Instruction signals
    signal w_InstrTyped    : chip8_instr_opcode_t;
    signal w_InstrSubTyped : chip8_alu_op_t;
    signal w_Imm           : std_logic_vector(CHIP8_WORD_SIZE-1 downto 0);
    signal w_RF_InstrSelX  : std_logic_vector(REG_SEL_WIDTH-1 downto 0);
    signal w_RF_InstrSelY  : std_logic_vector(REG_SEL_WIDTH-1 downto 0);

    -- Register File signals
    signal w_RF_SelX       : std_logic_vector(REG_SEL_WIDTH-1 downto 0);

    -- Internal Registers
    signal r_IR : std_logic_vector(CHIP8_INSTR_SIZE-1 downto 0);
    signal r_RR : std_logic_vector(CHIP8_WORD_SIZE-1 downto 0);
    signal r_VF : std_logic;

    -- Decoder outputs
    signal w_SelSignals   : chip8_select_signals_t;
    signal w_WriteSignals : chip8_write_signals_t;
    signal w_ALUOp        : chip8_alu_op_t;

    -- Unpacked signals
    signal w_ALU_VXSel : std_logic;
    signal w_ALU_VYSel : std_logic;
    signal w_RF_VXSel  : std_logic;
    signal w_PCWrite, w_IRWrite, w_RRWrite, w_RFWrite : std_logic;

    -- RF/ALU Data signals
    signal w_RFOutX, w_RFOutY, w_RFData,
           w_ALU_DataX, w_ALU_DataY, w_ALU_Result : std_logic_vector(CHIP8_WORD_SIZE-1 downto 0);
    signal w_ALU_VF : std_logic;


begin

    -- Instruction signals typing/extraction
    w_InstrTyped    <= inst_msb_to_inst_type(r_IR(CHIP8_INSTR_SIZE-1 downto 12));
    w_InstrSubTyped <= inst_lsb_to_instsub_type(r_IR(3 downto 0));
    w_Imm           <= r_IR(CHIP8_WORD_SIZE-1 downto 0);
    w_RF_InstrSelX  <= r_IR(11 downto 8);
    w_RF_InstrSelY  <= r_IR(7 downto 4);

    
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

    -- Unpack decoder records
    w_ALU_VXSel <= alu_vx_src_to_signal(w_SelSignals.alu_vx);
    w_ALU_VYSel <= alu_vy_src_to_signal(w_SelSignals.alu_vy);
    w_RF_VXSel <= rf_vx_src_to_signal(w_SelSignals.rf_vx);

    w_PCWrite   <= w_WriteSignals.PCWrite;
    w_IRWrite   <= w_WriteSignals.IRWrite;
    w_RRWrite   <= w_WriteSignals.RRWrite;
    w_RFWrite   <= w_WriteSignals.RFWrite;

    MUX_ALUVX: entity work.MUX2(RTL)
    port map(
        i_Sel => w_ALU_VXSel,
        i_Data1 => w_RFOutX,
        i_Data2 => (others => '0'),
        o_Data => w_ALU_DataX
    );

    MUX_ALUVY: entity work.MUX2(RTL)
    port map(
        i_Sel => w_ALU_VYSel,
        i_Data1 => w_RFOutY,
        i_Data2 => w_Imm,
        o_Data => w_ALU_DataY
    );

    MUX_RFVX: entity work.MUX2(RTL)
    generic map(
        DATA_WIDTH => CHIP8_RF_SEL_SIZE
    )
    port map(
        i_Sel => w_RF_VXSel,
        i_Data1 => w_RF_InstrSelX,
        i_Data2 => (others => '0'), -- Add VF (modify ALU)
        o_Data => w_RF_SelX
    );

    MUX_RF_DATA: entity work.MUX2(RTL)
    port map(
        i_Sel => w_RF_VXSel,
        i_Data1 => r_RR,
        i_Data2 => (CHIP8_WORD_SIZE-2 downto 0 => '0') & r_VF,
        o_Data => w_RFData
    );

    RegisterFile: entity work.RegisterFile(RTL)
    port map(
        i_Clk => i_Clk,
        i_Rst => i_Rst,
        i_Selx => w_RF_SelX,
        i_SelY => w_RF_InstrSelY,
        i_WriteEnable => w_RFWrite,
        i_WriteData => w_RFData,
        o_DataX => w_RFOutX,
        o_DataY => w_RFOutY
    );

    ALU: entity work.CHIP8_ALU(RTL)
    port map(
        i_VX => w_ALU_DataX,
        i_VY => w_ALU_DataY,
        i_ALUCtrl => w_ALUOp,
        o_ALUResult => w_ALU_Result,
        o_Flag => w_ALU_VF
    );

    PC: entity work.ProgramCounter(RTL)
    port map(
        i_Clk => i_Clk,
        i_Rst => i_Rst,
        i_Write => w_PCWrite,
        o_InstrAddress => o_Address
    );

    RR: entity work.GenericRegister(RTL)
    port map(
        i_Clk => i_Clk,
        i_Rst => i_Rst,
        i_Write => w_RRWrite,
        i_D => w_ALU_Result,
        o_Q => r_RR
    );

    IR: entity work.GenericRegister(RTL)
    generic map(
        WIDTH => CHIP8_INSTR_SIZE
    )
    port map(
        i_Clk => i_Clk,
        i_Rst => i_Rst,
        i_Write => w_IRWrite,
        i_D => i_Instruction,
        o_Q => r_IR
    );

    FR: entity work.GenericRegisterLogic(RTL)
    port map(
        i_Clk => i_Clk,
        i_Rst => i_Rst,
        i_Write => w_RRWrite,
        i_D => w_ALU_VF,
        o_Q => r_VF
    );

    
end architecture;
