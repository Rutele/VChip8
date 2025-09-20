library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.chip8_const_pkg.all;
use work.chip8_types_pkg.all;

entity Datapath is
    port(
        i_Clk: in std_logic;
        i_Rst: in std_logic;
        i_Instruction: in std_logic_vector(CHIP8_INSTR_SIZE-1 downto 0);
        o_Address: out std_logic_vector(CHIP8_ADDRESS_SIZE-1 downto 0)
    );
end entity;

architecture RTL of Datapath is

    signal w_InstrTyped : chip8_instr_opcode_t;
    signal w_InstrSubTyped : chip8_alu_op_t;
    signal w_Imm : std_logic_vector(CHIP8_WORD_SIZE-1 downto 0);
    signal w_SelX : std_logic_vector(REG_SEL_WIDTH-1 downto 0);
    signal w_SelY : std_logic_vector(REG_SEL_WIDTH-1 downto 0);
    signal w_RFOutX : std_logic_vector(CHIP8_WORD_SIZE-1 downto 0);
    signal w_RFOutY : std_logic_vector(CHIP8_WORD_SIZE-1 downto 0);

    -- ALU out signals
    signal w_ALUResult : std_logic_vector(CHIP8_WORD_SIZE-1 downto 0);
    signal w_ALUFlag : std_logic;

    -- Decoder out signals
    signal w_PCWrite : std_logic;                  
    signal w_IRWrite : std_logic;                  
    signal w_RRWrite : std_logic;                  
    signal w_RFWrite : std_logic;                  
    signal w_ALUOp : chip8_alu_op_t;               
    signal w_ALU_VXSrc : chip8_alu_vx_t;
    signal w_ALU_VYSrc : chip8_alu_vy_t;
    signal w_RF_VXSrc : chip8_rf_vx_src_t;

    -- Values in registers
    signal r_RRValue : std_logic_vector(CHIP8_WORD_SIZE-1 downto 0);
    signal r_IRValue : std_logic_vector(CHIP8_INSTR_SIZE-1 downto 0);
    signal r_FRValue : std_logic;

    -- MUX Select Signals
    signal w_ALU_VXSel : std_logic;
    signal w_ALU_VYSel : std_logic_vector(1 downto 0);
    signal w_ALU_DataX : std_logic_vector(CHIP8_WORD_SIZE-1 downto 0);
    signal w_ALU_DataY : std_logic_vector(CHIP8_WORD_SIZE-1 downto 0);

begin

    -- Type conversions
    w_InstrTyped <= inst_msb_to_inst_type(r_IRValue(CHIP8_INSTR_SIZE-1 downto 12));
    w_InstrSubTyped <= inst_lsb_to_instsub_type(r_IRValue(3 downto 0));
    w_Imm <= r_IRValue(CHIP8_WORD_SIZE-1 downto 0);

    -- Data Selection
    w_SelX <= r_IRValue(11 downto 8);
    w_SelY <= r_IRValue(7 downto 4);

    w_ALU_VXSel <= alu_vx_src_to_signal(w_ALU_VXSrc);
    w_ALU_VYSel <= alu_vy_src_to_signal(w_ALU_VYSrc);

    MUX_ALUVX: entity work.MUX2(RTL)
    port map(
        i_Sel => w_ALU_VXSel,
        i_Data1 => w_RFOutX,
        i_Data2 => (others => '0'),
        o_Data => w_ALU_DataX
    );

    MUX_ALUVY: entity work.MUX3(RTL)
    port map(
        i_Sel => w_ALU_VYSel,
        i_Data1 => w_RFOutY,
        i_Data2 => w_Imm,
        i_Data3 => o_Address(7 downto 0), -- Resolve the issue with the address
        o_Data => w_ALU_DataY
    );

    RegisterFile: entity work.RegisterFile(RTL)
    port map(
        i_Clk => i_Clk,
        i_Rst => i_Rst,
        i_SelX => w_SelX,
        i_SelY => w_SelY,
        i_WriteEnable => w_RFWrite,
        i_WriteData => r_RRValue,
        o_DataX => w_RFOutX,
        o_DataY => w_RFOutY
    );

    Decoder: entity work.InstructionDecoder(RTL)
    port map(
        i_Clk => i_Clk,
        i_Rst => i_Rst,
        i_InstrOpcode => w_InstrTyped,
        i_InstrSub => w_InstrSubTyped,
        o_PCWrite  => w_PCWrite,
        o_IRWrite => w_IRWrite,
        o_RRWrite => w_RRWrite,
        o_RFWrite => w_RFWrite,
        o_ALUOp => w_ALUOp,
        o_ALU_VXSrc => w_ALU_VXSrc,
        o_ALU_VYsrc => w_ALU_VYSrc,
        o_RF_VXSrc => w_RF_VXSrc
    );

    ALU: entity work.CHIP8_ALU(RTL)
    port map(
        i_VX => w_ALU_DataX,
        i_VY => w_ALU_DataY,
        i_ALUCtrl => w_ALUOp,
        o_ALUResult => w_ALUResult,
        o_Flag => w_ALUFlag
    );

    RR: entity work.GenericRegister(RTL)
    port map (
        i_Clk => i_Clk,
        i_Rst => i_Rst,
        i_Write => w_RRWrite,
        i_D => w_ALUResult,
        o_Q => r_RRValue
    );

    PC: entity work.GenericRegister(RTL)
    generic map(
        WIDTH => 16
    )
    port map (
        i_Clk => i_Clk,
        i_Rst => i_Rst,
        i_Write => w_PCWrite,
        i_D => (others => '0'), --TODO Change with branching instructions
        o_Q => o_Address
    );

    IR: entity work.GenericRegister(RTL)
    generic map(
        WIDTH => CHIP8_INSTR_SIZE
    )
    port map (
        i_Clk => i_Clk,
        i_Rst => i_Rst,
        i_Write => w_IRWrite,
        i_D => i_Instruction,
        o_Q => r_IRValue
    );

    FR: entity work.GenericRegisterLogic(RTL) -- TODO TMP solution, change to bigger ALU output
    port map (
        i_Clk => i_Clk,
        i_Rst => i_Rst,
        i_Write => w_IRWrite,
        i_D => w_ALUFlag,
        o_Q => r_FRValue
    );

end architecture;
