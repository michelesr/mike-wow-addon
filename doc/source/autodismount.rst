*********
Auto Dismount
*********

.. index:: single: Auto Dismount

The auto dismount script can be used in order to auto dismount when an action
can't be performed mounted.

In order to work properly it must be enabled and a mount has to be setted.

The state of the script and the setted mount can be seen with::

  /mi ad

To enable it use::

	/mi ad on

To disable::

	/mi ad off

To set the mount::

  /mi ad mount <mountBuff>

Where mountBuff is the name, for the current character, of the buff to dispel in
order to dismount.

Example::

  /mi ad mount Ability_Mount_RidingHorse

**HINT**: you can find mountBuff by printing all your buffs, running this
command with yourself selected as target::

  /mi pbuff
