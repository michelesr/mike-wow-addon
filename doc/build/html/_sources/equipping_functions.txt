*******************
Equipping functions
*******************
.. index:: Equipping functions

Here's a list of equipping functions.

.. note:: arguments inside [ ] are optional.

.. note:: Watch out for space after commas!

.. note:: There's no need to put whole item name, you can abbreviate it if the abbreviation is unique.

- **Example**: Reforged Blade of Heroes -> Reforged
- **Example**: Reforged Blade of Heroes -> Heroes

Auto Equipping Items
====================

.. index:: Auto Equipping Items


This will equip items in the appropriate slots ::

	/mi equip <item1>[, <item2>, ..., <itemN>]

..

**Example** ::

	/mi equip Avenger's Breastplate, Belt of Might, Avenger's Crown

..


The command above search for the item in your inventory, if it finds them link will be prompted in the chat and items will be equipped (if possible) in the appropriate slots.

**HINT**: you can also use this function to swap items, in fact, the "equip" function will not do nothing for item not found in your bags, so if you use /mi equip <item1>, <item2> and one of the two item is equipped, it will be swapped with the other item.

**Example** ::

	/mi equip Belt of Might, Belt of The Fallen Emperor, Acid Inscribed Greaves, Avenger's Greaves

..

This will get the belt and the boots on the bag and swap with the ones equipped.

Equipping weapons in right hand
===============================

.. index:: Equipping weapons in right hand

This will equip item1 on main hand and item2 on off hand ::

	/mi wequip <mainweapon>[, <offweapon>]

..

**Example** ::

	/mi wequip Argent Custodian, Ebon Hand

..

Put Equipment in Containers
===========================

.. index:: Put Equipment in Containers

::

	/mi strip

..

This will strip you, putting all your equipment in your containers.

.. note:: containers refer to backpack and additional bags, while inventory refers as equipped items, as Blizzard API states.

