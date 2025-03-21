#!/usr/bin/env python

import argparse
from enum import Enum
from pprint import pprint
from lark import Lark

from walker import walk_tree_handcraft, walk_tree_visitor, walk_tree_interpreter

class Walker(Enum):
    HANDCRAFT = 1
    VISITOR = 2
    INTERPRETER = 3

def read_content(file_path) -> str:
    with open(file_path, 'r') as f:
        return f.read()

def parse_tree(grammar: str, data: str, pretty: bool = False) -> None:
    parser = Lark(grammar, start="start")
    tree = parser.parse(data)

    print(tree.pretty() if pretty else tree)

def walk_tree(grammar: str, data: str, walker: Walker) -> None:
    parser = Lark(grammar, start="start")
    tree = parser.parse(data)
    env = dict()

    # match statement may better but version limited
    if walker == Walker.HANDCRAFT.value:
        env = walk_tree_handcraft(tree)
    elif walker == Walker.VISITOR.value:
        env = walk_tree_visitor(tree)
    elif walker == Walker.INTERPRETER.value:
        env = walk_tree_interpreter(tree)
    else:
        raise ValueError('Unknown convert tree walker')

    pprint(env)

def main() -> None:
    grammar = read_content('grammar/hpl.lark')
    data = read_content('sample/hpl.txt')

    parser = argparse.ArgumentParser()
    parser.add_argument('--parse', help="print parsed tree", action="store_true")
    parser.add_argument('--pretty', help="print parsed tree as pretty", action="store_true")
    parser.add_argument('--walker', help="set the default tree walker", default=Walker.HANDCRAFT.value, type=int)
    args = parser.parse_args()

    if args.parse:
        parse_tree(grammar, data, pretty=False)
        return

    if args.pretty:
        parse_tree(grammar, data, pretty=True)
        return

    walk_tree(grammar, data, args.walker)

if __name__ == "__main__":
    main()
