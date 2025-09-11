import sys
from tools import test_utils

alu_tester = test_utils.DeviceTester("chip8_alu", 
                                     "rtl/datapath/alu/alu.vhd", 
                                     ["rtl/pkg/chip8_const.vhd", "rtl/pkg/chip8_types.vhd"],
                                     "alu_test")

alu_tester.run_test()
