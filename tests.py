from tools import test_utils

alu_tester = test_utils.DeviceTester("chip8_alu", 
                                     "rtl/datapath/alu/alu.vhd", 
                                     ["rtl/pkg/chip8_const.vhd", "rtl/pkg/chip8_types.vhd"],
                                     "alu_test")

regfile_test = test_utils.DeviceTester("registerfile",
                                        "rtl/datapath/register_file/regfile.vhd", 
                                        ["rtl/pkg/chip8_const.vhd", "rtl/pkg/chip8_types.vhd"],
                                        "regfile_test")

#alu_tester.run_test()
regfile_test.run_test()