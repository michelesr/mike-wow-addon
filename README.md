MikeWoWAddon
==============

A simple collections of script for WoW game (version 1.12 vanilla)

This is a collection of simple scripts that i use in the game for simplify some thing, for a example targetting and buffin, applying DoT, etc. 

Installation
============

Clone the repo or download the zip, put it in your AddOn folder of your WoW client, rename the folder to MikeAddon, and you're good to go. 

        cd <YourWowFolder>/Interface/AddOns/
        git clone https://github.com/michelesr/mike-wow-addon/ MikeAddon
        
Update with
        
        git pull origin master

Usage
=====

Use the slash commands or bind it to a macro!
        
        /mike OR /mi
        /mike net: print netstats
        /mike fps: print framerate
        /mike mem: print addon memory usage
        /mike pos: print player position (x,y)
        /mike timer: get elapsed time since ui load or timer reset
        /mike treset: reset timer
        /mike ireset: reset instances
        /mike rl: reload user interface
        /mike qshare: share quest objectives with party
        /mike qss: share the quest that is selected (highlighted) in the quest log
        /mike psell: sell poor quality items
        /mike pdestroy: destroy without confirm all poor quality items
        /mike strip: get naked!
        /mike fortitude: buff stamina on your friends!
        /mike heal <percent> <spellname>: cast an healing spell on nearest player with hp% < percent
        /mike lspell <percent> <s1>,<s2>: cast s1 if target %hp is < percent, else s2
        /mike pcast <n> <spell>: cast spell on party on #n party member
        /mike wpain: cast 'Shadow Word: Pain' if not debuffed, else wand 'Shoot'
        /mike apain: cast 'Shadow Word: Pain' on nearest enemy not debuffed
        /mike sunder: cast 'Sunder Armor' on nearest enemy not debuffed
        /mike tattack: target nearest enemy (like TAB) and auto-attack
