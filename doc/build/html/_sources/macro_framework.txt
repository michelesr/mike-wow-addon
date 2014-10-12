***************
Macro framework
***************

Following functions are suited for macro writing.

.. note:: arguments inside [ ] are optional.

.. note:: watch out for spaces after comma!

.. note:: <buff_icon_name> and <debuff_icon_name> can be client dependent (for example Mac client could be different from Windows client)

.. note:: <spell> refers to spell name as you seen it in the tooltip, if rank is not specified will be cast the highest. 

**HINT**: to specify rank for spell use this syntax

::

	Spell Name(Rank X)

..

**Example**::

	Smite(Rank 2)

..

Castsequence
============

If you played latest version of WoW you sure have used at least one time /castsequence macro, but in vanilla there's not castsequence, so...

::

	/mike castsequence <reset_time> <spell1>, <spell2>[, <spell3>, ..., <spellN>]

..

This will cast <spell1>, then <spell2>, then ..., then <spellN> then again <spell1>, etc.

The <reset_time> is the number of second that have to pass before the macro will restart casting from <spell1>, however, if you cast all the spell before that time you will restart from spell1 even if time is not expired.

**HINT**: set <reset_time> to a word (like *noreset* or *whateryouwant*) or to 0 or to a negative number to **disable** auto reset.

**Example** ::

	/mike castsequence 10 Holy Fire, Mind Blast, Smite, Smite, Mind Blast
	/mike castsequence noreset Smite, Mind Blast
	/mike castsequence ilikepizza Sunder Armor, Heroic Strike 
	/mike castsequence 0 Renew, Power Word: Shield
	/mike castsequence -5 Renew, Smite

..

All the above will cast in sequence without a reset time, except the first that will reset after 10 seconds.


.. note:: blizzard castsequence was something like::

	/castsequence reset=10 Mind Blast, Smite

..

You **can't** set reset like reset=<number>, and also you always have to set it to a value (see HINT) 

Castrandom
==========

::

	/mike castrandom <spell1>, <spell2>[, <spell3>, ..., <spellN>]

..

This will cast a random spell from the ones provided

**Example** ::

	/mike castrandom Smite, Mind Blast, Shadow Word: Pain
	/mike castrandom Flash of Light, Holy Light
	/mike castrandom Shadow Bolt, Curse of Agony

..

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

	/mike lspell <percent> <spell1>[, <spell2>]

..

This will check for your target HP, and will cast <spell1> if its HP percent is inferior to <percent>, otherwise, will cast <spell2>.

**Example** ::

	/mike lspell 20 Execute, Heroic Strike
	/mike lspell 50 Heal, Lesser Heal
	/mike lspell 20 Flash Heal

..

The first will cast Execute if target has less than 20% HP, else Heroic Strike. 

The second will cast Heal if target has less than 50% HP, else Lesser Heal.

The third will cast Flash Heal if target has less than 20% HP.

Class based cast
================

::

	/mike ccast <class1>[ <class2> ... <classN>], <spell>

..

This will cast the selected <spell> only if target's class match with classes provided.

**Example** ::

	/mike ccast Warrior Rogue, Blessing of Might
	/mike ccast Mage Warlock Priest, Blessing of Wisdom
	/mike ccast Paladin, Blessing of Kings

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

	/mike bcast <buff_icon_name>, <spell1>[, <spell2>]

..

This will cast <spell1> if target is not buffed with buff represented by <buff_icon_name>, else <spell2>.

**Example** ::

	/mike bcast Fortitude, Power Word: Fortitude, Power Word: Shield 

..

This will cast "Power Word: Fortitude" if target is unbuffed with a buff that contains 'Fortitude' in its icon name, else "Power Word: Shield"

.. note:: in this example, i used 'Fortitude' as <buff_icon_name> instead of the entire icon name, you can do it if you want (this will also check for Prayer of Fortitude buffs) !

::

	/mike dcast <debuff_icon_name>, <spell1>[, <spell2>]

..

This will cast <spell1> if target is not debuffed with debuff represented by <debuff_icon_name>, else <spell2>

**Example** ::

	/mike dcast Pain, Shadow Word: Pain, Mind Blast

..

This will cast "Shadow Word: Pain" if target is not debuffed with a debuff with contains 'Pain' in its icon name, else will cast "Mind Blast" 

Cast spell based on target lvl
==============================

::

	/mike lvlcast <min_lvl> <spell1>[, <spell2>]

..

This will cast <spell1> if target lvl is major/equal <min_lvl>, else <spell2>.

**Example** ::

	/mike lvlcast 20 Smite

..

This will cast "Smite" only if target is lvl 20+

**HINT**: you can chain this commands in a macro to cast different spells on target of different level range

**Example** ::

	/mike lvlcast 50 Power Word: Fortitude(Rank 6)
	/mike lvlcast 38 Power Word: Fortitude(Rank 5)
	/mike lvlcast 26 Power Word: Fortitude(Rank 4), Power Word: Fortitude(Rank 3)

..

This will cast rank 6 if target is 50+, rank 5 if target is 38-49, rank 4 if target is 26-37, rank 3 else.

.. note:: launching this macro can cause "Another action is in progress" message, this is normal because if you cast the first spell (Rank 6) then you can't cast Rank 5-4 due to cooldown.

Cast appropriate rank for a spell
=================================

::

	/mike rcast <max_rank> <spell>

..

This will cast the appropriate spell rank based on target lvl.

<max_rank> is the highest available rank for <spell>.

+------+------+
| Lvl  | Rank |
+======+======+
| 1    | 1    |
+------+------+
| 2-13 | 2    |
+------+------+
| 14-25| 3    |
+------+------+
| 26-37| 4    |
+------+------+
| 38-49| 5    |
+------+------+
| 50 + | 6    |
+------+------+

**Example**::

	/mike rcast 6 Power Word: Fortitude

..

Mana based spell
================

**HINT**: this macro should work with rage/energy too.

::

	/mike manacast <min_mana> <spell1>[, <spell2>]

..

This will cast <spell1> if your remaining mana is major/equal <min_mana>, else <spell2>

**Example**

::

	/mike manacast 1000 Holy Light
	/mike manacast 200 Flash of Light(Rank 2), Flash of Light(Rank 1)

..

The first will cast Holy Light if you have 1000 or more mana left.

The second will cast Flash of Light: rank 2 if you have 200+ mana left, rank 1 else

Mana percent based spell
========================

**HINT**: this macro should work with rage/energy too.

Same as manacast but this time will be checked in <percent>.

::

	/mike mpcast <mana_percent> <spell1>[, <spell2>]

..

**Example**

::

	/mike mpcast 70 Holy Light
	/mike mpcast 50 Flash of Light(Rank 2), Flash of Light(Rank 1)

..

The first will cast Holy Light if you have 70% or more mana left.

The second will cast Flash of Light: rank 2 if you have 50%+ mana left, rank 1 else
