#!/usr/bin/env python

from typing import cast
from lark import Token, Tree
from lark.visitors import Visitor_Recursive

def walk_tree_visitor(tree: Tree) -> dict:
    visitor = WalkToDictVisitor()
    visitor.visit_topdown(tree)

    return visitor.env

class WalkToDictVisitor(Visitor_Recursive):
    def __init__(self):
        self.env = dict()
        self.data_line_key = ""

    def data_line_statement(self, tree: Tree):
        key = cast(Token, tree.children[0].children[0]).value
        value = cast(Token, tree.children[1].children[0]).value

        self.data_line_key = key
        self.env[key] = {
            "description": value,
            "lines": []
        }

    def pair_colon(self, tree: Tree):
        key = cast(Token, tree.children[0].children[0]).value
        value = cast(Token, tree.children[1].children[0]).value
        self.env[key] = value

    def pair_equals(self, tree: Tree):
        key = cast(Token, tree.children[0].children[0]).value
        value = cast(Token, tree.children[1].children[0]).value
        self.env[key] = value

    def data_items(self, tree: Tree):
        for child in tree.children:
            self.env[self.data_line_key]["lines"].append(
                cast(Token, child.children[0]).value
            )

    def number_row(self, tree: Tree):
        if "numbers" not in self.env:
            self.env["numbers"] = []

        self.env["numbers"].append(
            [cast(Token, child).value for child in tree.children]
        )
