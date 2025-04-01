#!/usr/bin/env python

from typing import Union, cast
from lark import Discard, Token, Transformer, Tree

def walk_tree_transformer(tree: Tree) -> dict:
    transformer = WalkToDictTransformer()
    result = transformer.transform(tree)

    return result

class WalkToDictTransformer(Transformer):
    def number_row(self, numbers: list[Token]):
        return [number.value for number in numbers]

    def asterisks(self, asterisks: list[Token]):
        return Discard

    def key(self, keys: list[Token]):
        return keys[0].value

    def value(self, values: list[Token]):
        return values[0].value

    def pair_colon(self, pair_colons: list[Token]):
        return { pair_colons[0]: pair_colons[1] }

    def pair_equals(self, pair_colons: list[Token]):
        return { pair_colons[0]: pair_colons[1] }

    def data_key(self, keys: list[Token]):
        return keys[0].value

    def data_value(self, values: list[Token]):
        return values[0].value

    def data_items(self, items: list[Token]):
        return [item for item in items]

    def data_item(self, items: list[Token]):
        return items[0].value

    def expression_statement(self, expressions: list[Token]):
        return expressions[0] if len(expressions) > 0 else None

    def data_line_statement(self, data_lines: list[Token]):
        data_line = {
            data_lines[0]: {
                "description": data_lines[1],
                "lines": data_lines[2]
            }
        }
        return data_line

    def statement(self, statements: list[Token]):
        return statements[0]

    def start(self, starts: list[Token]):
        result: dict[str, Union[str, list]] = { "numbers": [] }
        result_numbers = result["numbers"]

        for start in starts:
            if isinstance(start, dict):
                result |= start

            if isinstance(start, list):
                cast(list, result_numbers).append(start)

        return result
