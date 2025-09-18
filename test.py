import argparse
from tools import test_utils

tests = {
    "chip8_alu": {
        "dut_path": "rtl/datapath/alu/alu.vhd",
        "dependencies": ["rtl/pkg/chip8_const.vhd", "rtl/pkg/chip8_types.vhd"],
        "test_module": "alu_test"
    },
    "registerfile": {
        "dut_path": "rtl/datapath/register_file/regfile.vhd",
        "dependencies": ["rtl/pkg/chip8_const.vhd", "rtl/pkg/chip8_types.vhd"],
        "test_module": "regfile_test"
    },
    "decoder": {
        "dut_path": "rtl/control/decoder.vhd",
        "dependencies": ["rtl/pkg/chip8_const.vhd", "rtl/pkg/chip8_types.vhd"],
        "test_module": "decoder_test"
    }
}


def create_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser()
    parser.add_argument('--dut', nargs="+")
    parser.add_argument('--test-names', nargs="+")
    return parser


def check_duts(duts: list) -> list:
    if duts is None:
        return tests.keys()
    else:
        tested_duts = []
        for dut in duts:
            if dut in tests:
                tested_duts.append(dut)
            else:
                raise ValueError(f"No tests defined for {dut} entity.")
        return tested_duts


def run_tests(args: argparse.Namespace):
    duts = check_duts(args.dut)

    for dut_name in duts:
        dut_path = tests[dut_name]["dut_path"]
        dut_deps = tests[dut_name]["dependencies"]
        dut_test_module = tests[dut_name]["test_module"]
        current_test = test_utils.DeviceTester(dut_name, dut_path, dut_deps, dut_test_module, args.test_names)
        current_test.run_test()


if __name__ == "__main__":
    run_tests(create_parser().parse_args())
