import os

from pathlib import Path
from test_utils import TestedDevice
from cocotb.runner import get_runner

def test_runner(dev):
    sim = os.getenv("SIM", "ghdl")
    runner = get_runner(sim)

    # proj_path = Path(__file__).resolve().parent

    sources = dev.deps
    sources.append(dev.path)

    runner.test
    runner.build(
        always=True,
        vhdl_sources=sources,
        hdl_toplevel=dev.device_name,
        build_args=["--std=08"],
    )
    #runner.test(hdl_toplevel=dev.device_name, test_module="test_my_design")

if __name__ == "__main__":
    dut = TestedDevice("..//rtl//datapath//alu//alu.vhd", "CHIP8_ALU", ["..//rtl//pkg//chip8_const.vhd", "../rtl//pkg//chip8_types.vhd"])
    test_runner(dut)
