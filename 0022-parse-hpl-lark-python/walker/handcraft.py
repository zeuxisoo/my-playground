#!/usr/bin/env python

from typing import Optional, Union, cast
from lark import Token, Tree

# { str: str }
# { str: { str: str } }
# { str: { str: list } }
# { str: list }
EnvSubValue = Union[str, list[str]]
EnvKey = str
EnvValue = Union[str, dict[EnvKey, EnvSubValue], list[str]]
EnvDict = dict[EnvKey, EnvValue]

def walk_tree_handcraft(tree: Tree) -> EnvDict:
    env = dict()

    if tree.data != "start":
        raise ValueError("Unexpected program start position")

    for child in tree.children:
        walk_tree(cast(Tree, child), env)

    return env

def walk_tree(tree: Tree, env: EnvDict) -> Optional[Union[str, list[str]]]:
    if tree.data == "statement":
        for statement in tree.children:
            walk_tree(statement, env)
    elif tree.data == "expression_statement":
        for expression_statement in tree.children:
            walk_tree(expression_statement, env)
    elif tree.data == "data_line_statement":
        children = tree.children

        key = get_string(walk_tree(children[0], env))
        value = get_string(walk_tree(children[1], env))

        lines = walk_tree(children[2], env)
        assert lines is not None

        env[key] = {
            "description": value,
            "lines": lines
        }
    elif tree.data == "pair_colon" or tree.data == "pair_equals":
        children = tree.children

        key = get_string(walk_tree(children[0], env))
        value = get_string(walk_tree(children[1], env))

        env[key] = value
    elif tree.data == "key" or tree.data == "data_key":
        return cast(Token, tree.children[0]).value
    elif tree.data == "value" or tree.data == "data_value":
        return cast(Token, tree.children[0]).value
    elif tree.data == "data_items":
        items = []
        for child in tree.children:
            item = get_string(walk_tree(child, env))
            items.append(item)
        return items
    elif tree.data == "data_item":
        return cast(Token, tree.children[0]).value
    elif tree.data == "asterisks":
        pass # skip it
    elif tree.data == "number_row":
        row_numbers = []
        for child in tree.children:
            number = cast(Token, child).value
            row_numbers.append(number)

        if "numbers" not in env:
            env["numbers"] = []

        cast(list, env["numbers"]).append(row_numbers)

def get_string(optional_string: Optional[Union[str, list[str]]]) -> str:
    return cast(str, optional_string)
