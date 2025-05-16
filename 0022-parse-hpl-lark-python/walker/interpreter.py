#!/usr/bin/env python

from typing import cast
from lark import Token, Tree
from lark.visitors import Interpreter

def walk_tree_interpreter(tree: Tree) -> dict:
    interpreter = ConvertDictInterpreter()
    interpreter.visit(tree)

    return interpreter.env

class ConvertDictInterpreter(Interpreter):
    def __init__(self):
        self.env = dict()

    def start(self, tree: Tree):
        self.visit_children(tree)

    def statement(self, tree: Tree):
        self.visit_children(tree)

    def expression_statement(self, tree: Tree):
        self.visit_children(tree)

    def data_line_statement(self, tree: Tree):
        key, value, items = self.visit_children(tree)
        self.env[key] = {
            "description": value,
            "lines": items
        }

    def pair_colon(self, tree: Tree):
        key, value = self.visit_children(tree)
        self.env[key] = value

    def pair_equals(self, tree: Tree):
        key, value = self.visit_children(tree)
        self.env[key] = value

    def key(self, tree: Tree):
        return cast(Token, tree.children[0]).value

    def value(self, tree: Tree):
        return cast(Token, tree.children[0]).value

    def data_key(self, tree: Tree):
        return cast(Token, tree.children[0]).value

    def data_value(self, tree: Tree):
        return cast(Token, tree.children[0]).value

    def data_items(self, tree: Tree):
        return self.visit_children(tree)

    def data_item(self, tree: Tree):
        return cast(Token, tree.children[0]).value

    def number_row(self, tree: Tree):
        if "numbers" not in self.env:
            self.env["numbers"] = []

        nums = []
        for child in tree.children:
            nums.append(cast(Token, child).value)

        self.env["numbers"].append(nums)
