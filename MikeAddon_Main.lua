--[[

Mike's WoW Addon
Version: 1.0
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
  elseif m[1] == "timer" then
    mPrintElapsedTime()
  elseif m[1] == "treset" then
    mResetTimer()
  elseif m[1] == "ireset" then
    mPrint("Your instances has been reset")
    ResetInstances()
  elseif m[1] == "tsave" then
    mSaveTarget()
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
  elseif m[1] == "heal" then
    local sn = mGetSubArgs(m, 3)
    mMassHeal(sn, tonumber(m[2]))
  elseif m[1] == "lspell" then
    local perc = m[2]
    local spells = mSplit(mGetSubArgs(m, 3), ", ")
    mLifeSpell(tonumber(perc), spells[1], spells[2])
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
    mPrint("Mike's Addon", 1, 1, 0)
    mPrint("Usage: /mike <arguments> OR /mi <arguments>")
    mPrint("System informations", 1, 1, 0)
    mPrint("/mike net: print net stats")
    mPrint("/mike fps: print framerate")
    mPrint("/mike mem: print addons memory usage")
    mPrint("/mike pos: print player position")
    mPrint("Timer function", 1, 1, 0)
    mPrint("/mike timer: get elapsed time from ui load or timer reset")
    mPrint("/mike treset: reset timer")
    mPrint("Target save & restore functions:", 1, 1, 0)
    mPrint("/mike tsave: save current target name")
    mPrint("/mike trestore: target unit with saved name")
    mPrint("System functions", 1, 1, 0)
    mPrint("/mike ireset: reset instances")
    mPrint("/mike rl: reload user interface")
    mPrint("Quest objective party sharing", 1, 1, 0)
    mPrint("/mike qshare: share objectives of common quests in party")
    mPrint("/mike qss: share objectives for the quest that is selected (highlighted) in the quest log")
    mPrint("Poor items management", 1, 1, 0)
    mPrint("/mike psell: sell poor quality items")
    mPrint("/mike pdestroy: destroy without confirm all poor quality items")
    mPrint("Equipping function", 1, 1, 0)
    mPrint("/mike equip <item1>, <item2>, ..., <itemN>: equips items")
    mPrint("/mike wequip <w1>, <w2>: equip w1 on main hand and w2 on offhand")
    mPrint("/mike strip: put your equip in the inventory")
    mPrint("Macro framework", 1, 1, 0)
    mPrint("/mike heal <percent> <spellname>: cast an healing spell on nearest player with hp% < percent")
    mPrint("/mike lspell <percent> <s1>, <s2>: cast s1 if target %hp is < percent, else s2")
    mPrint("/mike pbuff: print buff icon names (needed for pbuff) of your target (or you)")
    mPrint("/mike pdebuff: print debuff icon names (needed for pdebuff) of your target (or you)")
    mPrint("/mike mbuff <spell>, <buff_icon_name>: buff nearest unbuffed friendly player")
    mPrint("/mike mdebuff <spell>, <buff_icon_name>: debuff nearest unbuffed enemy unit")
    mPrint("/mike pcast <n> <spell>: cast spell party member number n")
    mPrint("Premade macro functions", 1, 1, 0)
    mPrint("/mike tattack: target nearest enemy (like TAB) and auto-attack")
    mPrint("/mike sunder: cast 'Sunder Armor' on nearest enemy not debuffed")
    mPrint("/mike fortitude: cast 'Power Word: Fortitude' on nearest unbuffed friendly player")
    mPrint("/mike wpain: cast 'Shadow Word: Pain' if not debuffed, else wand 'Shoot'")
    mPrint("/mike apain: cast 'Shadow Word: Pain' on nearest enemy not debuffed")
  end
end
