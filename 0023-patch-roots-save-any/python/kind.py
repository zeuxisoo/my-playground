#!/usr/bin/env python

from enum import Enum

Quality = Enum('Quality', [
    ('Normal', 0),
    ('Good', 1),
    ('Better', 2),
    ('Best', 3),
])

Tool = Enum('Tool', [
    ('None', 0),
	('Handaxe', 100),
	('Axe', 200),
	('Hamme', 300),
	('Wate', 400),
	('Hoe', 500),
	('Sickle', 600),
	('Shears', 700),
	('Milke', 800),
	('Brush', 900),
	('Harpoon', 1000),
	('FishingRod', 1100),
	('Flute', 1200),
	('Torch', 1300),
])
