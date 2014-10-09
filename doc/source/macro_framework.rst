Macro framework
===============

Following functions are suited for macro writing.

**NOTE**: watch out for spaces after comma!

**NOTE**: <buff_icon_name> and <debuff_icon_name> can be client dependent (for example Mac client could be different from Windows client)

Spam heals based on HP
======================

::

	/mike heal <percent> <spellname>

..

This will cast the selected spell on nearest friendly player with HP percent inferior to <percent>.

**Example** ::

	/mike heal 80 Flash Heal
	/mike heal 50 Holy Light

..

The first will cast "Flash Heal" on nearest friendly player with less than 80% HP.

The first will cast "Holy Light" on nearest friendly player with less than 50% HP.

Cast spell based on HP
======================

::

	/mike lspell <percent> <spell1>, <spell2>

..

This will check for your target HP, and will cast <spell1> if its HP percent is inferior to <percent>, otherwise, will cast <spell2>.

**Example** ::

	/mike lspell 20 Execute, Heroic Strike
	/mike lspell 50 Heal, Lesser Heal

..

The first will cast Execute if target has less than 20% HP, else Heroic Strike. 

The second will cast Heal if target has less than 50% HP, else Lesser Heal.

Class based cast
================

::

	/mike ccast <class1> <class2> ... <classN>, <spell>

..

This will cast the selected <spell> only if target's class match with classes provided.

**Example** ::

	/mike ccast Warrior Rogue Paladin, Blessing of Might
	/mike ccast Mage Warlock Priest, Blessing of Wisdom

..

**HINT**: you can put multiple ccast in a single macro, to cast different spell on different classes, like i did on the example.

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

Buff/Debuff based cast
======================

You can write macro to cast spell based of target status (buffed/unbuffed with a specified buff/debuff)

See "Buff/Debuff spamming" for information about <buff_icon_name> and <debuff_icon_name>

::

	/mike bcast <buff_icon_name>, <spell1>, <spell2>

..

This will cast <spell1> if target is not buffed with buff represented by <buff_icon_name>, else <spell2>.

**Example** ::

	/mike bcast Fortitude, Power Word: Fortitude, Power Word: Shield 

..

This will cast "Power Word: Fortitude" if target is unbuffed with a buff that contains 'Fortitude' in its icon name, else "Power Word: Shield"

**NOTE**: in this example, i used 'Fortitude' as <buff_icon_name> instead of the entire icon name, you can do it if you want (this will also check for Prayer of Fortitude buffs) !

::

	/mike dcast <debuff_icon_name>, <spell1>, <spell2>

..

This will cast <spell1> if target is not debuffed with debuff represented by <debuff_icon_name>, else <spell2>

**Example** ::

	/mike dcast Pain, Shadow Word: Pain, Mind Blast

..

This will cast "Shadow Word: Pain" if target is not debuffed with a debuff with contains 'Pain' in its icon name, else will cast "Mind Blast" 
