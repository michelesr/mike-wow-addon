--[[

Mike's WoW Addon 
Version: 1.0.4
Application Main CLI UI

License:
  This program is free software; you can redistribute it and/or
  modify it under the terms of the GNU General Public License
  as published by the Free Software Foundation; either version 3
  of the License, or (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program(see LICENSE); if not, write to the Free Software
  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

]]

local version = "1.0.3"

-- slash command
SLASH_MIKE1, SLASH_MIKE2 = '/mike', '/mi'

-- slash command menu
function SlashCmdList.MIKE(msg, editbox)
  local m = mSplit(msg)
  if m[1] == "net" then
    mNetStats()
  elseif m[1] == "mem" then
    mMemUsage()
  elseif m[1] == "fps" then
    mFramerate()
  elseif m[1] == "pos" then
    mPrintPosition()
  elseif m[1] == "window" then
    mWindowSwitch()
  elseif m[1] == "timer" then
    mPrintElapsedTime()
  elseif m[1] == "treset" then
    mResetTimer()
  elseif m[1] == "ireset" then
    mPrint("Your instances has been reset")
    ResetInstances()
  elseif m[1] == "tsave" then
    mSaveTarget()
  elseif m[1] == "tcustom" then
    mSetTarget(mGetSubArgs(m, 2));
  elseif m[1] == "trestore" then
    mRestoreTarget()
  elseif m[1] == "rl" then
    mReloadUI()
  elseif m[1] == "qshare" then
    mShareQuestObjectives()
  elseif m[1] == "qss" then
    mShareSelectedQuestObjectives()
  elseif m[1] == "psell" then
    mPoorSell()
  elseif m[1] == "pdestroy" then
    mPoorDestroy()
  elseif m[1] == "strip" then
    mGetNaked()
  elseif m[1] == "equip" then
    mEquipItems(mSplit(mGetSubArgs(m, 2), ", ")) 
  elseif m[1] == "wequip" then
    local w = mSplit(mGetSubArgs(m, 2), ", ")
    mEquipHandWeapons({w[1], w[2]}) 
  elseif m[1] == "print" then
    mPrint(mGetSubArgs(m))
  elseif m[1] == "fortitude" then
    mMassBuff("Power Word: Fortitude", "Fort")
  elseif m[1] == "castsequence" then
   if string.find(m[2], "reset") or tonumber(m[2]) then
     mCastSequence(m[2], mSplit(mGetSubArgs(m, 3), ", "))
   else
     mCastSequence("", mSplit(mGetSubArgs(m), ", "))
   end
  elseif m[1] == "castrandom" then
    local spells = mSplit(mGetSubArgs(m), ", ")
    mCastRandom(spells)
  elseif m[1] == "stance" then
    local stances = mSplit(mGetSubArgs(m), ", ")
    mStanceSwitch(stances)
  elseif m[1] == "stancerandom" then
    if m[2] then
      mStanceRandom(mSplit(mGetSubArgs(m), ", "))
    else
      mStanceRandom()
    end
  elseif m[1] == "heal" then
    local sn = mGetSubArgs(m, 3)
    mMassHeal(sn, tonumber(m[2]))
  elseif m[1] == "lspell" then
    local spells = mSplit(mGetSubArgs(m, 3), ", ")
    mLifeSpell(tonumber(m[2]), spells[1], spells[2])
  elseif m[1] == "bcast" then
    local x = mSplit(mGetSubArgs(m, 2), ", ")
    mCastIfBuffed(x[1], x[2], x[3]);
  elseif m[1] == "dcast" then
    local x = mSplit(mGetSubArgs(m, 2), ", ")
    mCastIfDebuffed(x[1], x[2], x[3]);
  elseif m[1] == "ccast" then
    local x = mSplit(mGetSubArgs(m, 2), ", ")
    mClassCast(x[1], x[2])
  elseif m[1] == "lvlcast" then
    local spells = mSplit(mGetSubArgs(m, 3), ", ")
    mLevelCast(tonumber(m[2]), spells[1], spells[2])
  elseif m[1] == "rcast" then
    local spell = mGetSubArgs(m, 3)
    mRankCast(tonumber(m[2]), spell)
  elseif m[1] == "manacast" then
    local spells = mSplit(mGetSubArgs(m, 3), ", ")
    mManaCast(tonumber(m[2]), spells[1], spells[2])
  elseif m[1] == "mpcast" then
    local spells = mSplit(mGetSubArgs(m, 3), ", ")
    mManaPercentCast(tonumber(m[2]), spells[1], spells[2])
  elseif m[1] == "pcast" then
    local n = m[2]
    mPartyMemberCast(n, mGetSubArgs(m, 3))
  elseif m[1] == "wpain" then
    mCastIfDebuffed("Pain", "Shadow Word: Pain", "Shoot")
  elseif m[1] == "apain" then
    mMassDebuff("Shadow Word: Pain", "Pain")
  elseif m[1] == "sunder" then
    mMassDebuff("Sunder Armor", "Sunder")
  elseif m[1] == "tattack" then
    mTargetAttack()
  elseif m[1] == "tcast" then
    mTargetEnemyCast(mGetSubArgs(m))
  elseif m[1] == "ftcast" then
    mTargetFriendCast(mGetSubArgs(m))
  elseif m[1] == "pbuff" then
    if UnitName("target") then
      mPrintBuff("target")
    else
      mPrintBuff("player")
    end
  elseif m[1] == "pdebuff" then
    if UnitName("target") then
      mPrintDebuff("target")
    else
      mPrintDebuff("player")
    end
  elseif m[1] == "mbuff" then
    local x = mSplit(mGetSubArgs(m, 2), ", ")
    mMassBuff(x[1], x[2])
  elseif m[1] == "mdebuff" then
    local x = mSplit(mGetSubArgs(m, 2), ", ")
    mMassDebuff(x[1], x[2])
  else 
    mPrint("Mike's Addon v" .. version, 1, 1, 0)
    mPrint("Usage: /mike <arguments> OR /mi <arguments>")
    mPrint("[ ] are for optional (not mandatory) arguments");
    mPrint("System informations", 1, 1, 0)
    mPrint("/mi net: print net stats")
    mPrint("/mi fps: print framerate")
    mPrint("/mi mem: print addons memory usage")
    mPrint("/mi pos: print player position")
    mPrint("Timer function", 1, 1, 0)
    mPrint("/mi timer: get elapsed time from ui load or timer reset")
    mPrint("/mi treset: reset timer")
    mPrint("Target save & restore functions:", 1, 1, 0)
    mPrint("/mi tsave: save current target name")
    mPrint("/mi trestore: target unit with saved name")
    mPrint("/mi tcustom <name>: set custom target to restore");
    mPrint("System functions", 1, 1, 0)
    mPrint("/mi window: Switch between fullscreen and windowed mode")
    mPrint("/mi ireset: reset instances")
    mPrint("/mi rl: reload user interface")
    mPrint("Quest objective party sharing", 1, 1, 0)
    mPrint("/mi qshare: share objectives of common quests in party")
    mPrint("/mi qss: share objectives for the quest that is selected (highlighted) in the quest log")
    mPrint("Poor items management", 1, 1, 0)
    mPrint("/mi psell: sell poor quality items")
    mPrint("/mi pdestroy: destroy without confirm all poor quality items")
    mPrint("Equipping function", 1, 1, 0)
    mPrint("/mi equip <item1>[, <item2>, ..., <itemN>]: equips items")
    mPrint("/mi wequip <w1>[, <w2>]: equip w1 on main hand and w2 on offhand")
    mPrint("/mi strip: put your equip in the inventory")
    mPrint("Macro framework", 1, 1, 0)
    mPrint("/mi tcast <spell>: target nearest enemy unit and cast a spell")
    mPrint("/mi ftcast <spell>: target nearest friendly unit and cast a spell")
    mPrint("/mi castsequence [reset=<sec>/combat/target] <s1>, <s2>[, <s3>, ..., <sN>]: cast spell in sequence")
    mPrint("/mi castrandom <s1>, <s2>[, <s3>, ..., <sN>]: cast a random spell from the list");
    mPrint("/mi stance <s1>, <s2>[, <s3>, ..., <sN>]: cast stance that follow active in the list (or first if last is active or there is no active)")
    mPrint("/mi stancerandom [<s1>, ..., <sN>]: switch to a random unactive stance from list o from all the players one if none is provided")
    mPrint("/mi heal <percent> <spellname>: cast an healing spell on nearest player with hp% < percent")
    mPrint("/mi lspell <percent> <s1>[, <s2>]: cast s1 if target %hp is < percent, else s2")
    mPrint("/mi pbuff: print buff icon names (needed for pbuff) of your target (or you)")
    mPrint("/mi pdebuff: print debuff icon names (needed for pdebuff) of your target (or you)")
    mPrint("/mi mbuff <spell>, <buff_icon_name>: buff nearest unbuffed friendly player")
    mPrint("/mi mdebuff <spell>, <buff_icon_name>: debuff nearest unbuffed enemy unit")
    mPrint("/mi bcast <buff_icon_name>, <s1>[, <s2>]: cast on target s1 if not buffed, else s2");
    mPrint("/mi dcast <debuff_icon_name>, <s1>[, <s2>]: cast on target s1 if not debuffed, else s2");
    mPrint("/mi ccast <class1>[ <class2> ... <classN>], <spell>: cast <spell> on target if its class match"); 
    mPrint("/mi lvlcast <min_lvl> <s1>[, <s2>]: cast spell if target lvl is major/equal <min_lvl>, else s2");
    mPrint("/mi rcast <max_spell_rank> <spell>: check target lvl and cast appropriate rank of the spell");
    mPrint("/mi manacast <min_mana> <s1>[, <s2>]: cast s1 if your mana is at least <min_mana>, else s2");
    mPrint("/mi mpcast <mana_percent> <s1>[, <s2>]: cast s1 if your mana% is at least <percent>, else s2");
    mPrint("/mi pcast <n> <spell>: cast spell party member number n")
    mPrint("Premade macro functions", 1, 1, 0)
    mPrint("/mi tattack: target nearest enemy (like TAB) and auto-attack")
    mPrint("/mi sunder: cast 'Sunder Armor' on nearest enemy not debuffed")
    mPrint("/mi fortitude: cast 'Power Word: Fortitude' on nearest unbuffed friendly player")
    mPrint("/mi wpain: cast 'Shadow Word: Pain' if not debuffed, else wand 'Shoot'")
    mPrint("/mi apain: cast 'Shadow Word: Pain' on nearest enemy not debuffed")
    mPrint("Documentation: https://michelesr.github.io/mi-wow-addon/doc/build/html/main.html", 1, 1, 0); 
  end
end
