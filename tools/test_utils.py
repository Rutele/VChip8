import sys
from pathlib import Path
from cocotb.runner import get_runner

class DeviceTester():

    def __init__(self, dut_name: str, dut_path: str, dut_deps: list[str], test_module: str,
                 test_cases: str | list[str] | None, sim_name: str = "ghdl", output_path: str = "test_out",):

        self.dut_name = dut_name
        self.dut_path = Path(dut_path)
        self.dut_deps = [Path(path) for path in dut_deps]
        self.test_module = test_module
        self.output_path = output_path + f"//{dut_name}"
        self.sim_name = sim_name
        self.test_cases = test_cases
        self.test_runner = None

        self._validate_paths()
        self._build_device_and_tester()
        self._insert_module_path()

    def _validate_paths(self):
        if not self.dut_path.exists():
            raise Exception(f"Device file {self.dut_path} does not exist!")
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
            log_file=self.output_path + f"/{self.dut_name}_test.log",
        )

    def _insert_module_path(self):
        test_module_path = self.dut_path.parent.resolve()
        sys.path.insert(0, str(test_module_path))

    def run_test(self):
        self.test_runner.test(test_module=self.test_module, hdl_toplevel=self.dut_name, hdl_toplevel_library="work",
                              test_args=["--std=08"], plusargs=[f"--wave={self.dut_name}_test_waveform.ghw"], waves=True,
                              test_dir=self.output_path, build_dir=self.output_path, testcase=self.test_cases)
