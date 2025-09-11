import cocotb

from cocotb.triggers import FallingEdge, Timer
from cocotb.binary import BinaryValue

async def set_alu(dut, op):
    dut.i_ALUCtrl.value = op
    dut.i_VX.value = 0
    dut.i_VY.value = 0
    await Timer(1, "ns")

@cocotb.test()
async def addition_test(dut):
    await set_alu(dut, 1)

    for i in range(0, 256):
        for j in range(0, 256):
            dut.i_VX.value = i
            dut.i_VY.value = j
            expected_flag = int(i+j >= 256)
            await Timer(1, "ns")

            assert ((dut.o_ALUResult.value.integer == (i+j)%256) and \
                    (dut.o_Flag.value.integer == expected_flag)), f"{i} + {j} failed"

@cocotb.test()
async def sub_test(dut):
    await set_alu(dut, 2)

    for i in range(0, 256):
        for j in range(0, 256):
            dut.i_VX.value = i
            dut.i_VY.value = j
            expected_flag = int(not i-j < 0)
            await Timer(1, "ns")
            assert ((dut.o_ALUResult.value.integer == (i-j)%256) and \
                    (dut.o_Flag.value.integer == expected_flag)), f"{i} - {j} failed"

@cocotb.test()
async def and_test(dut):
    await set_alu(dut, 3)

    for i in range(0, 256):
        for j in range(0, 256):
            dut.i_VX.value = i
            dut.i_VY.value = j
            await Timer(1, "ns")

            assert ((dut.o_ALUResult.value.integer == i&j) and \
                    (dut.o_Flag.value.integer == 0)), f"{i} AND {j} failed"
            
@cocotb.test()
async def or_test(dut):
    await set_alu(dut, 4)

    for i in range(0, 256):
        for j in range(0, 256):
            dut.i_VX.value = i
            dut.i_VY.value = j
            await Timer(1, "ns")

            assert ((dut.o_ALUResult.value.integer == i|j) and \
                    (dut.o_Flag.value.integer == 0)), f"{i} OR {j} failed"

@cocotb.test()
async def xor_test(dut):
    await set_alu(dut, 5)

    for i in range(0, 256):
        for j in range(0, 256):
            dut.i_VX.value = i
            dut.i_VY.value = j
            await Timer(1, "ns")

            assert ((dut.o_ALUResult.value.integer == i^j) and \
                    (dut.o_Flag.value.integer == 0)), f"{i} XOR {j} failed"
            
@cocotb.test()
async def sr_test(dut):
    await set_alu(dut, 6)
    
    for i in range(0, 256):
        dut.i_VY.value = i
        expected_flag = i&1
        await Timer(1, "ns")

        assert ((dut.o_ALUResult.value.integer == (i >> 1))) and \
                (dut.o_Flag.value.integer == expected_flag), f"{i} SR failed"

@cocotb.test()
async def sl_test(dut):
    await set_alu(dut, 7)
    
    for i in range(0, 256):
        dut.i_VY.value = i
        expected_flag = (i&(1 << 7)) >> 7
        await Timer(1, "ns")

        assert ((dut.o_ALUResult.value.integer == (i << 1)%256)) and \
                (dut.o_Flag.value.integer == expected_flag), f"{i} SR failed"

