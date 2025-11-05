# Brain Braiser

An Amiga game I wrote back in 1990!

![Menu](https://github.com/LutzGrosshennig/amiga-brain-braiser/blob/master/Images/Menu.jpg)
![Game](https://github.com/LutzGrosshennig/amiga-brain-braiser/blob/master/Images/Game.jpg)

The game is written in 100% assembly (Profimat Amiga) but contains a nice collection of macros to make the source more readable.
Runs fine on a stock Amiga 500 with Kickstart 1.2 and above.

Original description from 1990 (translated to English below).

# Function

Brain Braiser is a thinking and strategy game.

A 12 × 13 tile playing field is generated and filled with random numbers between -9 and +9, plus two kinds of special squares. Player 1 can move horizontally on the field, whereas Player 2 can only move vertically. The aim of the game is to achieve the highest possible score. The simplest way to do this is to always occupy the highest-value tile in the current row or column, but if you do that you will lose very quickly, because your opponent can then plan more than five moves ahead and lure you into a trap. A running clock limits turn time, so with short time settings you must act very quickly.

Additional special squares can be used strategically. One type are the Xchange squares (marked with a large X), which swap the point totals of Player 1 and Player 2 — allowing a player who is behind to "steal" their opponent’s hard-earned points. The other type are Zero squares (square value is 0); these invert the signs of all numbers on the board (a -9 becomes 9, etc.). If a player's clock runs out, the other player receives a 15-point bonus and gets the next move. If a player can no longer move because their row or column is completely filled, their opponent receives a 25-point bonus and the game ends.

# The Setup Menu

In the setup menu, which appears before each new game, you can choose whether to play against the computer or prefer a human opponent. You can also set the control type separately for each player. In a string gadget you can conveniently set the maximum move duration (default 400 / corresponds to 8 seconds). If you want to set the clock yourself, please note: the clock is decremented 50 times per second. So you must multiply the number of seconds by 50 to get the correct value for the clock. In addition, you can set the number of joysticks available.

# Controls

Player 1 controls the cursor with the left Alt key, left Amiga key and the spacebar, or via a joystick in Port 2. Player 2 controls the cursor with the up and down arrow keys and the spacebar, or via a joystick in Port 2. If two joysticks are present and configured, Player 1 uses the joystick in Port 2 and Player 2 uses the joystick in Port 1.

# Special Keys

Pressing P toggles pause mode on or off. Pressing ESC terminates the game at any time.

# The Computer

If you choose to play against the computer, it always takes the role of Player 2, i.e., it always plays vertically. Because the computer opponent’s algorithm is not very sophisticated (so you have less typing to do), it has a compensating advantage: for the computer an X-field counts as 10 points instead of swapping the players’ scores as it would for a human player. In addition, the computer always jumps directly to its target tile, which can be a surprising effect for an inattentive player.

# General

I omitted a high-score list when I noticed that achieved scores varied greatly. This is due to the playing field being filled with random numbers; it can easily happen that not a single 9, positive or negative, appears in a game, so there’s no good chance to get a high score. Thus the achieved score depends more on luck than on the player’s skill. The game does, however, have a learning effect: if you play it often, you become able to perceive and process a whole row of information (values) at once.

# About the Program

The program is written 100% in assembler (Profimat Amiga), which allowed a very short and compact program (approx. 18 kB or about 8 kB packed). The program is also split into two so-called hunks that, when the program is loaded, automatically place the program code into possible FAST RAM and the graphics and sound data into CHIP RAM. Multitasking is switched off during gameplay. However, when you are in the setup or game-over mode, multitasking is active again. Also, everything is carefully cleaned up when exiting the program, so you can load the game alongside other things without having to worry about getting a visit from a gentleman from India (GURU!!!).

Except for one exception, only operating system routines are used (which are more than sufficient for this type of game), so there should be no compatibility problems with newer Kickstarts (1.3/2.0) or possible turbo cards. The exception is the initialization of the vertical blank interrupt (which occurs every time the screen is redrawn — 50 times per second on PAL Amigas), which I programmed "by hand"; however, since that routine is only called after multitasking has been disabled, this should not cause problems either. (The old interrupt address is saved and reinstalled when the program exits.)

If you intend to assemble the source with your assembler, please note: the ALIGN instruction is equivalent to the EVEN instruction used by most assemblers. Otherwise consult your assembler’s manual; the instruction causes the following source code to be placed at an even address. Also, the IBYTES instruction is used, which is a specialty of Profimat and lets you embed data directly in the source. I don’t know a solution for other assemblers because I’m not familiar with them, but maybe one of the readers has an idea.

One final tip: if you use two joysticks, you can also control the mouse pointer via the keyboard (right Amiga key + arrow keys; for larger distances also hold the right Shift key), which saves you the bother of unplugging and replugging between mouse and joystick.

Have fun with the program.

Lutz Großhennig, Schwanewede, 29.06.1990
