#!/usr/bin/env python3
"""Generate Level4..Level8 in the legacy Mario Objects XML format.

Grid: 64 x 29 tiles (16px), Y counts from the level bottom (y=0 = floor row).
Design rules (engine quirks + keeping the geometry beatable):
- Mario always spawns at pixel x=20 on the bottom row -> solid start zone.
- Ground is BlockGrass (walking monsters only recognize grass/question tops).
- Pits at most 4 tiles wide (a full jump spans ~8 tiles); climbs at most
  4 tiles tall (jump apex ~4.5 tiles); no ceiling above a required jump.
- Pipes are 2 tiles wide + 2 tall; keep >= 4 tiles of flat ground between a
  pipe (or a drop) and the next pit so a hop over one can't land in a pit.
- Monsters/pipes only stand on flat grass; exit near the right edge.
"""

import os

OUT = "/Users/admin/Private/Mario-Game/MarioSwift/Sources/MarioKit/Resources/Levels"
WIDTH = 64

QI_COIN, QI_MUSH, QI_FLOWER, QI_LIFE = 0, 13, 18, 23
PIRANHA_FISH, PIRANHA_FIRE = 1, 2


class Level:
    def __init__(self):
        self.objects = []

    def add(self, oname, x, y, i1=0, i2=0, i3=0, b1=False, b2=False, b3=False):
        assert 0 <= x < WIDTH and 0 <= y < 29, f"{oname} out of grid: {x},{y}"
        self.objects.append((oname, x, y, i1, i2, i3, b1, b2, b3))

    # -- terrain helpers ---------------------------------------------------
    def ground(self, pits=()):
        """Grass floor row with the given (start, width) pit columns removed."""
        holes = set()
        for start, width in pits:
            assert width <= 4, f"pit too wide at {start}"
            holes.update(range(start, start + width))
        for x in range(WIDTH):
            if x not in holes:
                self.add("BlockGrass", x, 0)

    def solid_column(self, x, height):
        for y in range(1, height + 1):
            self.add("BlockSolid", x, y)

    def steps_up(self, x0, count):
        """Staircase rising left to right: heights 1..count."""
        for i in range(count):
            self.solid_column(x0 + i, i + 1)

    def steps_down(self, x0, count):
        for i in range(count):
            self.solid_column(x0 + i, count - i)

    def brick_row(self, x0, x1, y):
        for x in range(x0, x1 + 1):
            self.add("BlockBrick", x, y)

    def coin_line(self, x0, x1, y):
        for x in range(x0, x1 + 1):
            self.add("CoinBlock", x, y)

    def coin_arc(self, x0, y):
        for i, dy in enumerate((0, 1, 2, 1, 0)):
            self.add("CoinBlock", x0 + i, y + dy)

    # -- fixtures ----------------------------------------------------------
    def mario(self):
        self.add("Mario", 1, 1)

    def exit(self, x=61, y=1):
        self.add("ExitBlock", x, y)

    def pipe(self, x, piranha=0):
        """Pipe standing on the ground; occupies columns x..x+1."""
        self.add("BlockPipeUp", x, 1, i1=piranha)

    def question(self, x, y, item=QI_COIN):
        self.add("BlockQuestion", x, y, i1=item)

    def hidden(self, x, y, item=QI_LIFE):
        self.add("BlockQuestionHidden", x, y, i1=item)

    def goomba(self, x):
        self.add("MonsterGoomba", x, 1)

    def koopa(self, x):
        self.add("MonsterKoopa", x, 1)

    def platform(self, x, y, distance, horizontal=False, reversed_=False):
        self.add("BlockMoving", x, y, i1=distance, i2=1 if horizontal else 0, b1=reversed_)

    def write(self, name):
        lines = [
            '<?xml version="1.0" encoding="utf-8"?>',
            '<root xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'
            ' xmlns:xsd="http://www.w3.org/2001/XMLSchema">',
        ]
        for o in self.objects:
            oname, x, y, i1, i2, i3, b1, b2, b3 = o
            lines += [
                "  <Object>",
                f"    <OName>{oname}</OName>",
                f"    <X>{x}</X>",
                f"    <Y>{y}</Y>",
                f"    <Int1>{i1}</Int1>",
                f"    <Int2>{i2}</Int2>",
                f"    <Int3>{i3}</Int3>",
                f"    <Bool1>{str(b1).lower()}</Bool1>",
                f"    <Bool2>{str(b2).lower()}</Bool2>",
                f"    <Bool3>{str(b3).lower()}</Bool3>",
                "  </Object>",
            ]
        lines.append("</root>")
        with open(os.path.join(OUT, name), "w") as f:
            f.write("\n".join(lines))
        print(f"{name}: {len(self.objects)} objects")


# ---------------------------------------------------------------- Level 4
# "Rolling Meadows" — a gentle warm-up: two small pits, a few goombas,
# question blocks with the first power-up, one quiet pipe.
lv = Level()
lv.ground(pits=[(21, 3), (39, 3)])
lv.question(8, 4, QI_COIN)
lv.question(9, 4, QI_MUSH)
lv.question(10, 4, QI_COIN)
lv.brick_row(11, 12, 4)
lv.coin_arc(20, 3)  # over pit 1
lv.pipe(30)  # quiet pipe, far from both pits
lv.coin_line(30, 33, 5)
lv.coin_arc(38, 3)  # over pit 2
lv.brick_row(46, 47, 4)
lv.question(48, 4, QI_COIN)
lv.hidden(26, 4, QI_LIFE)
lv.goomba(15)
lv.goomba(36)
lv.koopa(50)
lv.exit()
lv.mario()
lv.write("Level4.xml")

# ---------------------------------------------------------------- Level 5
# "Goomba Gorge" — wider pits, first stairs, a fish piranha, more traffic.
lv = Level()
lv.ground(pits=[(14, 4), (30, 4), (49, 4)])
lv.question(7, 4, QI_MUSH)
lv.brick_row(8, 9, 4)
lv.coin_line(14, 17, 4)  # over pit 1
lv.hidden(20, 4, QI_LIFE)
lv.steps_up(22, 3)  # stairs 22..24, vault or climb, drop at 25
lv.coin_arc(29, 4)  # over pit 2
lv.steps_down(35, 3)  # 3-high wall to vault at 35, stepping down
lv.pipe(41, PIRANHA_FISH)
lv.coin_line(49, 52, 5)  # over pit 3
lv.question(56, 4, QI_FLOWER)
lv.goomba(11)
lv.goomba(27)
lv.koopa(45)
lv.goomba(58)
lv.exit()
lv.mario()
lv.write("Level5.xml")

# ---------------------------------------------------------------- Level 6
# "Sky Bridges" — open-sky pits, a brick bridge with a coin payout and a
# bonus platform above it, a piranha pair to hop in one flight.
lv = Level()
lv.ground(pits=[(12, 4), (26, 4), (45, 3)])
lv.coin_line(12, 15, 4)  # over pit 1
lv.brick_row(17, 22, 5)  # bridge over solid ground; walk under or ride it
lv.coin_line(18, 21, 6)  # payout on top of the bridge
lv.platform(18, 9, 32)  # bonus lift above the bridge
lv.coin_line(17, 20, 12)
lv.coin_arc(25, 4)  # over pit 2
lv.pipe(33, PIRANHA_FISH)  # pipe pair: one brave jump or two hops
lv.pipe(37, PIRANHA_FIRE)
lv.coin_line(45, 47, 4)  # over pit 3
lv.hidden(9, 4, QI_LIFE)
lv.add("BlockBrick", 52, 4)
lv.question(53, 4, QI_FLOWER)
lv.add("BlockBrick", 54, 4)
lv.goomba(8)
lv.koopa(19)
lv.goomba(24)
lv.goomba(31)
lv.koopa(41)
lv.goomba(56)
lv.exit()
lv.mario()
lv.write("Level6.xml")

# ---------------------------------------------------------------- Level 7
# "Brick Bastion" — island hops, a rampart to storm, fire piranhas and a
# koopa welcome committee. One mushroom and one hidden life to find.
lv = Level()
lv.ground(pits=[(10, 3), (18, 3), (38, 4)])
lv.coin_line(10, 12, 4)  # over pit 1 (island at 13..17)
lv.coin_line(18, 20, 4)  # over pit 2
lv.question(23, 4, QI_MUSH)
lv.brick_row(22, 24, 4)
lv.steps_up(28, 4)  # rampart 28..31 rising to 4 high
lv.solid_column(32, 4)  # battlement top, then a cliff drop at 33
lv.coin_arc(37, 4)  # over pit 3
lv.pipe(46, PIRANHA_FIRE)
lv.hidden(50, 4, QI_LIFE)
lv.pipe(54, PIRANHA_FIRE)
lv.brick_row(56, 58, 4)
lv.question(57, 8, QI_FLOWER)
lv.koopa(8)
lv.goomba(21)
lv.goomba(26)
lv.goomba(44)
lv.koopa(52)
lv.goomba(59)
lv.exit()
lv.mario()
lv.write("Level7.xml")

# ---------------------------------------------------------------- Level 8
# "The Gauntlet" — a triple pit chain over islands, a tower to storm, then
# a fire piranha corridor with a koopa escort. One mushroom, one hidden
# life, no second chances.
lv = Level()
lv.ground(pits=[(8, 3), (16, 3), (24, 3)])
lv.coin_line(8, 10, 4)  # pit chain: islands at 11..15 and 19..23
lv.coin_line(16, 18, 4)
lv.coin_line(24, 26, 4)
lv.hidden(28, 4, QI_LIFE)
lv.steps_up(32, 4)  # tower 32..35 rising to 4 high
lv.solid_column(36, 4)
lv.question(40, 4, QI_MUSH)  # breather after the cliff drop
lv.pipe(43, PIRANHA_FIRE)  # the corridor: fire, fire, fish
lv.pipe(52, PIRANHA_FIRE)
lv.pipe(56, PIRANHA_FISH)
lv.coin_arc(46, 4)
lv.goomba(6)
lv.goomba(13)
lv.koopa(21)
lv.goomba(30)
lv.koopa(48)
lv.goomba(59)
lv.exit(62, 1)
lv.mario()
lv.write("Level8.xml")

# ------------------------------------------------------------ LevelManager
manager = """<?xml version="1.0" encoding="utf-8"?>
<LevelManager xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <CurrentLevelIndex>0</CurrentLevelIndex>
  <MarioLives>5</MarioLives>
  <LevelFilePaths>
    <string>lev1.xml</string>
    <string>Level2.xml</string>
    <string>Level3.xml</string>
    <string>Level4.xml</string>
    <string>Level5.xml</string>
    <string>Level6.xml</string>
    <string>Level7.xml</string>
    <string>Level8.xml</string>
  </LevelFilePaths>
</LevelManager>"""
with open(os.path.join(OUT, "LevelManager.xml"), "w") as f:
    f.write(manager)
print("LevelManager.xml: 8 levels")
