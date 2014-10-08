Macro framework
===============

Following functions are suited for macro writing.

NOTE: watch out for spaces after comma!

Spam heals based on HP
======================

::

	/mike heal <percent> <spellname>

..

This will cast the selected spell on nearest friendly player with HP percent inferior to <percent>.

Examples ::

	/mike heal 80 Flash Heal
	/mike heal 50 Holy Light

..

Cast spell based on HP
======================

::

	/mike lspell <percent> <spell1>, <spell2>

..

This will check for your target HP, and will cast <spell1> if its HP percent is inferior to <percent>, otherwise, will cast <spell2>.

Examples ::

	/mike lspell 20 Execute, Heroic Strike
	/mike lspell 50 Heal, Lesser Heal

..

Buff/Debuff spamming
====================

You can write a macro to cast buff on nearest unbuffed player o debuff to nearest undebuffed unit.

In order to do this, you must know how did Blizzard named the icon that represents the buff/debuff.

Here you got 2 functions to help you with discovering buff/debuffs icon names ::

	/mike pbuff
	/mike pdebuff

..

These 2 functions will operate on your target (or you if you don't have a target) and will print on chat the list of buff/debuff names. You can use that names to write the following macros. ::

	/mike mbuff <spell>, <buff_icon_name>

..

This will cast <spell> on nearest friendly player that is unbuffed with buff represented by <buff_icon_name>. ::

	/mike mdebuff <spell>, <debuff_icon_name>

..

This will cast <spell> on nearest enemy unit that is undebuffed with debuff represented by <debuff_icon_name>.

NOTE: watch out for spaces after comma!

NOTE: <buff_icon_name> and <debuff_icon_name> can be client dependent (for example Mac client could be different from Windows client)
