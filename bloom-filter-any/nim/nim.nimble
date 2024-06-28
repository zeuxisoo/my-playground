# Package

version       = "0.1.0"
author        = "Zeuxis"
description   = "A new awesome nimble package"
license       = ""
srcDir        = "src"
bin           = @["nim"]


# Dependencies

requires "nim >= 1.6.14"
requires "https://github.com/nim-lang/bigints" # ca00f6d on May 18
