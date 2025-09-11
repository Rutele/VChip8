import os
import cocotb

from pathlib import Path
from cocotb.runner import get_runner
from cocotb.clock import Clock

class DeviceTester():

    def __init__(self, dut_name: str, dut_path: str, dut_deps: list[str], sim_name: str = "ghdl", output_path: str = "../test_out",
                 is_combinational: bool = False):
        self.dut_name = dut_name
        self.dut_path = Path(dut_path)
        self.dut_deps = [Path(path) for path in dut_deps]
        self.output_path = output_path
        self.sim_name = sim_name
        self.test_runner = None
        self.dut_clock = None
        self.is_combinational = is_combinational

        self._validate_paths()
        self._build_device_and_tester()

    def _validate_paths(self):
        if not self.dut_path.exists():
            raise Exception(f"Device file {self.path} does not exist!")
        for path in self.dut_deps:
            if not path.exists():
                raise Exception(f"Dependency file {path} does not exist!")
    
    def _build_device_and_tester(self):
        self.test_runner = get_runner(self.sim_name)
        self.test_runner.build(
            hdl_library="work",
            vhdl_sources = self.dut_deps + [self.dut_path],
            hdl_toplevel = self.dut_name,
            build_args=["--std=08"],
            always=True,
            clean=True,
            verbose=True,
            build_dir=self.output_path,
            waves=True,
            log_file=self.output_path + "/test.log",
        )

    def run_test(self):
        self.test_runner.test(test_module="test_utils", hdl_toplevel=self.dut_name, hdl_toplevel_library="work",
                              test_args=["--std=08"],)


d = DeviceTester("CHIP8_ALU", "..//rtl//datapath//alu//alu.vhd", ["..//rtl//pkg//chip8_const.vhd", "../rtl//pkg//chip8_types.vhd"])
d.run_test()