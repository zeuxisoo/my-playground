#!/usr/bin/env python

from enum import Enum, auto

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

class Entity(Enum):
    Plant = 0
    Tree = auto()
    Resource = auto()
    MagneticItem = auto()
    Player = auto()
    Inventory = auto()
    SeedInventory = auto()
    Currency = auto()
    ShippingBin = auto()
    NPC = auto()
    Weather = auto()
    Animal = auto()
    AnimalHerd = auto()
    GrassStarter = auto()
    Bed = auto()
    WildPlantPatch = auto()
    IrrigationPump = auto()
    PachaStatue = auto()
    Nanny = auto()
    Idea = auto()
    Building = auto()
    TallGrass = auto()
    PickableItem = auto()
    TileableDecoration = auto()
    FenceDoor = auto()
    WaterWell = auto()
    Decoration = auto()
    BeeHive = auto()
    RacingLeague = auto()
    ReflectionStatue = auto()
    FirePit = auto()
    Score = auto()
    ManualProducer = auto()
    AutoProducer = auto()
    StorageBox = auto()
    Dashboard = auto()
    SchoolWorkshop = auto()
    PlantNursery = auto()
    FollowingPetData = auto()
    QuestManager = auto()
    Calendar = auto()
    IrrigationTrench = auto()
    IrrigationExtender = auto()
    TotemOffering = auto()
    CaveRoom = auto()
    CaveTorch = auto()
    CavePaint = auto()
    Trading = auto()
    LimitedStockShop = auto()
    MainStory = auto()
    UniqueDataManager = auto()
    Fence = auto()
    ProsperityObjects = auto()
    Butcher = auto()
    TrapSpot = auto()
    ItemGrower = auto()
    Olla = auto()
