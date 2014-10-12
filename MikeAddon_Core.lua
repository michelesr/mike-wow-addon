--[[

Mike's WoW Addon
Version: 1.0.3
Application Core

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

-- number of search iterations (increasing this will also increase cpu load)
local N=10
local timer = GetTime()
local savedTarget = nil
local castSequences = {};

-- reset timer
function mResetTimer()
  timer = GetTime()
  mPrint("Timer reset!")
end

-- get elapsed time
function mGetElapsedTime()
  return GetTime() - timer
end

-- print elapsed time from addon loading or last timer reset
function mPrintElapsedTime()
  local t = mGetElapsedTime()
  local h = mod(t/3600, 60)
  local m = mod(t/60, 60)
  local s = mod(t, 60)
  mPrint(string.format("Elapsed time --  %.2d:%.2d:%.2d", h, m, s)) 
end

-- save target
function mSaveTarget()
  savedTarget = UnitName("target")
end

-- set custom target
function mSetTarget(name)
  if name then
    savedTarget = name
  end
end

-- restore target
function mRestoreTarget()
  if savedTarget then
    TargetByName(savedTarget)
  end
end

-- print player's position (x,y)
function mPrintPosition()
  local x,y = GetPlayerMapPosition("player")
  local z = GetZoneText()
  mPrint(string.format("%s: %.2f, %.2f", z, x*100, y*100))
end

-- share objective of quest in party chat
function mShareQuestObjective(i)
  local s = "Objectives for quest " ..  GetQuestLogTitle(i) .. ": " 
  SelectQuestLogEntry(i)
  for j=1,GetNumQuestLeaderBoards(i) do
    s = s .. GetQuestLogLeaderBoard(j) .. "; "
  end
  SendChatMessage(s, "party")
end

-- share quests objectives for shared quest in party
function mShareQuestObjectives()
  for i=1,GetNumQuestLogEntries() do
    local j=1
    local b=false
    while (j <= 4 and not b) do
      b = IsUnitOnQuest(i, "party" .. j) 
      j = j + 1
    end
    if b then
      mShareQuestObjective(i)
    end
  end
end

-- share selected quest
function mShareSelectedQuestObjectives()
  mShareQuestObjective(GetQuestLogSelection())
end


-- return reference to cast sequence matching reset time and spells, initializing if not present
function mGetCastSequence(reset, spells)
  local b = false
  local n = getn(spells)
  for x in castSequences do
    local s = castSequences[x]
    if s["reset"] and s["reset"] == reset and getn(s["spells"]) == n then
      local i = 1
      while i <= n and s["spells"][i] == spells[i] do i=i+1 end
      if i > n then 
        return s 
      end
    end
  end
  return mInitializeCastSequence(reset, spells)
end

-- initialize new cast sequence with given reset time and spells and return reference
function mInitializeCastSequence(reset, spells)
  local n = getn(castSequences)
  castSequences[n+1] = {}
  local s = castSequences[n+1]
  s["spells"] = spells
  s["reset"] = reset
  s["index"] = 1
  s["start"] = GetTime()
  return s
end

-- cast spell in sequence, return to first after reset time or casting last
function mCastSequence(reset, spells)
  local s = mGetCastSequence(reset, spells)
  -- reset if time expired or index out of range
  if s["reset"] > 0 and (GetTime() - s["start"]) > s["reset"] or s["index"] > getn(s["spells"]) then
    s["start"] = GetTime()
    s["index"] = 1
  end
  -- cast and increment
  CastSpellByName(s["spells"][s["index"]])
  s["index"] = s["index"] + 1
end

-- cast a random spell from the list
function mCastRandom(spells)
  local n = getn(spells)
  CastSpellByName(spells[math.random(1, n)])
end

-- count buffs on a unit
function mBuffCount(unit)
  local i=1 
  while UnitBuff(unit, i) do 
    i=i+1
  end
  return i-1
end

-- count debuffs on a target
function mDebuffCount(unit)
  local i=1 
  while UnitDebuff(unit, i) do 
    i=i+1
  end
  return i-1
end

-- print target buff icons name
function mPrintBuff(unit)
  for i=1,mBuffCount(unit) do
    local x = UnitBuff(unit, i)
    local y = mPathSplit(x)
    if y then
      mPrint(y[3])
    else
      mPrint(x)
    end
  end
end

-- print target debuff icons name
function mPrintDebuff(unit)
  for i=1,mDebuffCount(unit) do
    local x = UnitDebuff(unit, i)
    local y = mPathSplit(x)
    if y then
      mPrint(y[3])
    else
      mPrint(x)
    end
  end
end

-- cast spell if class match
function mClassCast(classes, spell)
  local c = UnitClass("target")
  if spell and c and string.find(classes, c) then
    CastSpellByName(spell)
  end
end

-- cast s1 if target isn't buffed, else s2
function mCastIfBuffed(buff, s1, s2)
  local n = mBuffCount("target")+1
  local i = 1
  local x = false
  while i < n do
    if string.find(UnitBuff("target", i), buff) then
      x = true
    end i=i+1
  end
  if x and s2 then
    CastSpellByName(s2)
  elseif s1 then
    CastSpellByName(s1)
  end
end

-- cast s1 if target isn't debuffed, else s2
function mCastIfDebuffed(debuff, s1, s2)
  local n = mDebuffCount("target")+1
  local i = 1
  local x = false
  while i < n do
    if string.find(UnitDebuff("target", i), debuff) then
      x = true
    end i=i+1
  end
  if x and s2 then
    CastSpellByName(s2)
  elseif s1 then
    CastSpellByName(s1)
  end
end

-- cast spell with rank appropriate for target lvl
-- maxRank: current max rank of the spell
function mRankCast(maxRank, spell)
  local levels = {1, 2, 14, 26, 38, 50};
  local lvl = UnitLevel("target");
  if lvl then
    for i=maxRank,1,-1 do
      if lvl >= levels[i] and spell then
        CastSpellByName(spell .. "(Rank " .. i .. ")");
        return nil
      end
    end
  end
end

-- cast s1 if lvl is major/equal minLvl, else s2
function mLevelCast(minLvl, s1 , s2)
  local lvl = UnitLevel("target");
  if s1 and lvl and lvl >= minLvl then
    CastSpellByName(s1);
  elseif s2 then
    CastSpellByName(s2);
  end
end

-- cast spell1 if mana is >= than minMana, else s2
function mManaCast(minMana, s1, s2)
  if s1 and UnitMana("player") >= minMana then
    CastSpellByName(s1);
  elseif s2 then
    CastSpellByName(s2);
  end
end

-- cast spell1 if mana% is >= percent, else s2
function mManaPercentCast(percent, s1, s2)
  mManaCast(UnitManaMax("player") * percent / 100.0, s1, s2); 
end

-- buff nearest unbuffed friendly unit with a spell
function mMassBuff(spellName, checkString)
  ClearTarget()
  for i=1,N do
    i=i+1
    TargetNearestFriend()
    local x = true
    local n = mBuffCount("target")+1
    local k = 1
    while k < n do
      if string.find(UnitBuff("target", k),checkString) then
        x=false
      end k=k+1
    end
    if spellName and  x == true and UnitIsPlayer("target") then
      CastSpellByName(spellName)
      return nil
    end
  end 
end

-- cast debuff spell on nearest enemy undebuffed unit
function mMassDebuff(spellName, checkString)
  ClearTarget()
  for i=1,N do
    i=i+1
    TargetNearestEnemy()
    local x = true
    local n = mDebuffCount("target")+1
    local k = 1
    while k < n do
      if string.find(UnitDebuff("target", k),checkString) then
        x=false
      end k=k+1
    end
    if spellName and x == true then
      CastSpellByName(spellName)
      return nil
    end
  end 
end

-- hp check, return true if hp < perc
function mCheckHp(perc) 
  return (UnitHealth("target")/UnitHealthMax("target")) < (perc/100.0)
end

-- cast a spell on nearest friendly player if his/her hp % is < than perc
function mMassHeal(spellName, perc)
  ClearTarget()
  for i=1,N do
    i=i+1
    TargetNearestFriend()
    if spellName and mCheckHp(perc) and UnitIsPlayer("target") then
      CastSpellByName(spellName)
      return nil
    end
  end
end

-- cast s1 if hp is < perc, else s2
function mLifeSpell(perc, s1, s2) 
  if s1 and mCheckHp(perc) then
    CastSpellByName(s1)
  elseif s2 then
    CastSpellByName(s2)
  end
end

-- target nearest enemy and attack
function mTargetAttack()
  TargetNearestEnemy()
  AttackTarget()
end

-- cast spell on party member n
function mPartyMemberCast(n, spell)
  TargetUnit("party" .. n)
  if spell then
    CastSpellByName(spell)
  end
  TargetLastTarget()
end

-- put your gear in your bag
function mGetNaked()
  local k=1
  local bag=0 
  while (k <= 18 and bag <= 4) do
    local slot=1 local max=GetContainerNumSlots(bag)
    while (slot <= max and k <= 18) do
      if not GetContainerItemLink(bag, slot) then
        while not GetInventoryItemLink("player", k) do
          k = k+1
        end
        PickupInventoryItem(k)
        if (bag == 0) then
          PutItemInBackpack()
        else
          PutItemInBag(bag+19)
        end
        k = k+1
      end
      slot = slot + 1
    end
    bag = bag + 1
  end
end

-- return bag and slot index of item matching string
function mGetContainerItemByName(item, printString) 
  printString = printString or "Found Item: "
  for bag = 0,4,1 do
    for slot = 1, GetContainerNumSlots(bag) do
      local name = GetContainerItemLink(bag, slot)
      if name and string.find(name, item) then
        mPrint(printString .. name)
        return bag, slot 
      end
    end
  end
end

-- return an array of {bag, slot} of items matching string
function mGetContainerItemsByName(item, printString) 
  printString = printString or "Found item: "
  local t = {}
  local i = 1
  for bag = 0,4,1 do
    for slot = 1, GetContainerNumSlots(bag) do
      local name = GetContainerItemLink(bag, slot)
      if name and string.find(name, item) then
        mPrint(printString .. name)
        t[i] = {bag, slot} 
        i = i + 1 
      end
    end
  end
  return t
end

-- sell poor quality items to a vendor
function mPoorSellOrDestroy(destroy)
  destroy = destroy or false
  if destroy then
    printString = "Destroying item: "
  else
    printString = "Selling item: "
  end
  local items = mGetContainerItemsByName("ff9d9d9d", printString)
  for x in items do
    if destroy then
      PickupContainerItem(items[x][1], items[x][2])
      DeleteCursorItem()
    else
      UseContainerItem(items[x][1], items[x][2])
    end
  end
end

-- destroy poor quality items
function mPoorDestroy()
  mPoorSellOrDestroy(true)
end

function mPoorSell()
  mPoorSellOrDestroy(false)
end

-- equip w1 on main hand and w2 on off hand
function mEquipHandWeapons(w)
  for i=1,2 do 
    local x,y
    if w[i] then
      x,y = mGetContainerItemByName(w[i], "Equipping item: ")
    end
    if x and y then
      PickupContainerItem(x,y)
      EquipCursorItem(15+i)
    end
  end
end

-- equips items on the appropriate slots 
function mEquipItems(items) 
  for i in items do
    local x,y
    x,y = mGetContainerItemByName(items[i], "Equipping item: ")
    if x and y then
      PickupContainerItem(x,y)
      AutoEquipCursorItem()
    end
  end
end

-- print netstats 
function mNetStats()
  local a,b,c = GetNetStats()
  mPrint(string.format("Incoming bandwidth: %.4f kB/s\nOutgoing bandwith: %.4f kB/s\nLatency: %d ms", a, b,c))
end

-- print mem usage
function mMemUsage()
  local m = gcinfo()
  local t = {"kB", "MB", "GB"}
  local i = math.floor(math.log10(m) / 3)
  mPrint(string.format("Memory usage: %.2f %s", m/math.pow(10, i*3), t[i+1]))
end

-- print fps
function mFramerate()
  mPrint(string.format("FPS: %.4f", GetFramerate()))
end

-- trigger UI reload
function mReloadUI()
  ReloadUI()
end
