from pathlib import Path
from .type_parser import CustomTypeParser

BASE_DIR = Path(__file__).resolve().parents[1]
VHDL_TYPES_PATH = BASE_DIR / "rtl" / "pkg" / "chip8_types.vhd"

if not VHDL_TYPES_PATH.exists():
    raise FileNotFoundError(f"VHDL types file not found: {VHDL_TYPES_PATH}")

custom_types = CustomTypeParser([VHDL_TYPES_PATH])
