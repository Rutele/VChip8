from pathlib import Path

class CustomTypeParser:
    
    TYPE_VAL_CHAR_FILTER = {"(", ")", ";", ","}

    def __init__(self, path: str = "../rtl/pkg/chip8_types.vhd"):
        self.path = Path(path)
        self.types: dict[str, dict[str, int]] = {}
        self.tokenized_types: list[list[str]] = []

        self._validate_path()
        self._tokenize_types()
        self._generate_dict()

    def __repr__(self):
        return f"Parsed types: {list(self.types.keys())}"
    
    def _validate_path(self):
        if not self.path.exists():
            raise Exception(f"{self.path} does not exist!")

    def _tokenize_types(self):
        with open(self.path, 'r') as f:
            load_lines = False
            current_type = []

            for line in f:
                line_array = line.split()

                if "type" in line_array and "array" not in line_array and not load_lines:
                    load_lines = True

                if load_lines:
                    current_type.extend(line_array)

                    if ";" in line:
                        self.tokenized_types.append(current_type)
                        current_type = []
                        load_lines = False

    def _generate_dict(self):
        for tokens in self.tokenized_types:
            self._add_type(tokens)

    def _add_type(self, type_tokens: list[str]):
        type_name = type_tokens[1]
        raw_values = type_tokens[3:]

        values = [self._filter_value_names(v) for v in raw_values]
        values = [v for v in values if v]

        self.types[type_name] = {name: idx for idx, name in enumerate(values)}

    def _filter_value_names(self, name: str) -> str:
        return "".join(c for c in name if c not in self.TYPE_VAL_CHAR_FILTER)
