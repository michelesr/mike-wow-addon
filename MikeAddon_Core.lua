--[[

Mike's WoW Addon
Version: 1.0.4
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
local fishing = { active = false }
local debug = false

-- trigger UI reload
function mReloadUI()
  ReloadUI()
end

-- switch windowed/fullscreen mode
function mWindowSwitch()
  SetCVar("gxWindow", mod(GetCVar("gxWindow") + 1, 2))
  RestartGx()
end

function mWindowMaximizeSwitch()
  SetCVar("gxMaximize", mod(GetCVar("gxMaximize") + 1, 2))
  RestartGx()
end

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
  mPrint("Saved Target: " .. savedTarget)
end

-- set custom target
function mSetTarget(name)
  if name then
    savedTarget = name
  end
  mPrint("Saved Target: " .. savedTarget)
end

-- restore target
function mRestoreTarget()
  if savedTarget then
    TargetByName(savedTarget)
  end
end

-- print player's position (x,y)
function mPrintPosition()
  local map = C_Map.GetBestMapForUnit("player")
  if map then
    local position = C_Map.GetPlayerMapPosition(map, "player")
    local z = GetZoneText()
    mPrint(string.format("%s: %.2f, %.2f", z, position.x*100, position.y*100))
  else
    mPrint("Can't get position")
  end
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
function mGetCastSequence(reset, combat, target, spells)
  local b = false
  local n = getn(spells)
  for x,y in pairs(castSequences) do
    local s = castSequences[x]
    if s["reset"] and s["reset"] == reset and getn(s["spells"]) == n and
       s["combat"] == combat and s["target"] == target then
      local i = 1
      while i <= n and s["spells"][i] == spells[i] do i=i+1 end
      if i > n then
        return s
      end
    end
  end
  return mInitializeCastSequence(reset, combat, target, spells)
end

-- initialize new cast sequence with given reset time and spells and return reference
function mInitializeCastSequence(reset, combat, target, spells)
  local n = getn(castSequences)
  castSequences[n+1] = {}
  local s = castSequences[n+1]
  s["combat"] = combat
  s["target"] = target
  s["spells"] = spells
  s["reset"] = reset
  s["index"] = 1
  s["start"] = GetTime()
  return s
end

-- parse arguments for cast sequence
function mParseResetArgs(args)
  local rtime
  local combat = false
  local target = false
  if string.find(args, "reset") then
    args = mSplit(args, "=")[2]
  end
  args = mSplit(args, "/")
  for x,y in pairs(args) do
    if args[x] == "combat" then
      combat = true
    elseif args[x] == "target" then
      target = true
    elseif not rtime and tonumber(args[x]) then
      rtime = tonumber(args[x])
    end
  end
  if not rtime then
    rtime = 0
  end
  return rtime, combat, target
end

function mTriggerResetCastSequence(trigger)
  for x,y in pairs(castSequences) do
    local s = castSequences[x]
    if s[trigger] then
      mCastSequenceReset(s)
    end
  end

end

-- reset cast sequence to call on target change
function mTargetResetCastSequence()
  mTriggerResetCastSequence("target")
end


-- reset cast sequence to call on combat enter/leave
function mCombatResetCastSequence()
  mTriggerResetCastSequence("combat")
end

-- reset cast sequence
function mCastSequenceReset(s)
  s["start"] = GetTime()
  s["index"] = 1
end

-- cast spell in sequence
function mCastSequence(args, spells)
  local reset, combat, target = mParseResetArgs(args)
  --mPrint(tostring(reset) .. " " .. tostring(combat) .. " " .. tostring(target))
  local s = mGetCastSequence(reset, combat, target, spells)
  -- reset if time expired or index out of range
  if s["reset"] > 0 and (GetTime() - s["start"]) > s["reset"] or s["index"] > getn(s["spells"]) then
    mCastSequenceReset(s)
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

-- return UnitBuff function ifBuff, else UnitDebuff function
function mUnitBD(isBuff)
  if isBuff then
    return UnitBuff
  else
    return UnitDebuff
  end
end

function mBDCount(isBuff, unit)
  local i=1
  while mUnitBD(isBuff)(unit, i) do
    i=i+1
  end
  return i-1
end

-- count buffs on a unit
function mBuffCount(unit)
  return mBDCount(true, unit)
end

-- count debuffs on a target
function mDebuffCount(unit)
  return mBDCount(false, unit)
end

function mBDPrint(isBuff, unit)
  for i=1,mBDCount(isBuff, unit) do
    local x = mUnitBD(isBuff)(unit, i)
    local y = mPathSplit(x)
    if y then
      mPrint(y[3])
    else
      mPrint(x)
    end
  end
end

-- print target buff icons name
function mPrintBuff(unit)
  mBDPrint(true, unit)
end

-- print target debuff icons name
function mPrintDebuff(unit)
  mBDPrint(false, unit)
end

-- conditional cast
function mConditionalCast(cond, s1, s2)
  if s1 and cond then
    CastSpellByName(s1)
  elseif s2 then
    CastSpellByName(s2)
  end
end

-- cast spell if class match
function mClassCast(classes, spell)
  local c = UnitClass("target")
  mConditionalCast(c and string.find(classes, c), spell)
end

function mHasBD(isBuff, unit, buff)
  local n = mBDCount(isBuff, unit)+1
  local i = 1
  while i < n do
    if string.find(mUnitBD(isBuff)(unit, i), buff) then
      return i
    end i=i+1
  end
end

-- return buff index or nil
function mHasBuff(unit, buff)
  return mBDCount(true, unit, buff)
end

-- return debuff index or nil
function mHasDebuff(unit, debuff)
  return mBDCount(false, unit, debuff)
end

function mCastIfBD(isBuff, buff, s1, s2)
  mConditionalCast(not mHasBD(isBuff,"target", buff), s1, s2)
end

-- cast s1 if target isn't buffed, else s2
function mCastIfBuffed(buff, s1, s2)
  mCastIfBD(true, buff, s1, s2)
end

-- cast s1 if target isn't debuffed, else s2
function mCastIfDebuffed(debuff, s1, s2)
  mCastIfBD(false, debuff, s1, s2)
end

-- cast s1 if buff/debuff is found and is major/minor of count
-- op can be '<' or '>'
function mCastIfBDCount(isBuff, buff, op, count, s1, s2)
  local i = mHasBD(isBuff, "target", buff)
  if i then
    local b, c = mUnitBD(isBuff)("target", i)
    if b and c and mOrdinalOperation(op, c, count) and s1 then
      CastSpellByName(s1)
      return
    end
  end
  if s2 then
      CastSpellByName(s2)
  end
end

function mCastIfBuffCount(buff, op, count, s1, s2)
  mCastIfBDCount(true, buff, op, count, s1, s2)
end

function mCastIfDebuffCount(debuff, op, count, s1, s2)
  mCastIfBDCount(false, debuff, op, count, s1, s2)
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
  mConditionalCast(lvl and lvl >= minLvl, s1, s2)
end

-- cast spell1 if mana is >= than minMana, else s2
function mManaCast(minMana, s1, s2)
  mConditionalCast(UnitPower("player") >= minMana, s1, s2)
end

-- cast spell1 if mana% is >= percent, else s2
function mManaPercentCast(percent, s1, s2)
  mManaCast(UnitPowerMax("player") * percent / 100.0, s1, s2);
end

function mMassBD(isBuff, spellName, checkString)
  ClearTarget()
  for i=1,N do
    i=i+1
    if isBuff then
      TargetNearestFriend()
    else
      TargetNearestEnemy()
    end
    local x = not isBuff or isBuff and UnitIsPlayer("target")
    local n = mBDCount(isBuff, "target")+1
    local k = 1
    while k < n do
      if string.find(mUnitBD(isBuff)("target", k),checkString) then
        x=false
      end k=k+1
    end
    if spellName and x then
      CastSpellByName(spellName)
      return nil
    end
  end
end

-- buff nearest unbuffed friendly unit with a spell
function mMassBuff(spellName, checkString)
  mMassBD(true, spellName, checkString)
end

-- cast debuff spell on nearest enemy undebuffed unit
function mMassDebuff(spellName, checkString)
  mMassBD(false, spellName, checkString)
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
  mConditionalCast(mCheckHp(perc), s1, s2)
end

-- target nearest enemy and attack
function mTargetAttack()
  TargetNearestEnemy()
  AttackTarget()
end

-- target nearest enemy and cast spell
function mTargetEnemyCast(spell)
  TargetNearestEnemy()
  CastSpellByName(spell)
end

-- target nearest friend and cast spell
function mTargetFriendCast(spell)
  TargetNearestFriend()
  CastSpellByName(spell)
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

-- return bag and slot index of item matching string
function mGetContainerItemByName(item, printString)
  local x =  mGetContainerItemsByName(item, printString)[1]
  if x then return x[1], x[2] end
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
  for x,y in pairs(items) do
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
  for i,j in pairs(items) do
    local x,y
    x,y = mGetContainerItemByName(items[i], "Equipping item: ")
    if x and y then
      PickupContainerItem(x,y)
      AutoEquipCursorItem()
    end
  end
end

-- return stance index by name or nil if not found
function mGetStanceByName(name)
  for i=1,GetNumShapeshiftForms() do
    local a,b = GetShapeshiftFormInfo(i)
    if string.find(b, name) then
      return i
    end
  end
end

-- return a list of indexes from a list of stance names
function mGetStancesIndex(stances)
  local s = {}
  for x,y in pairs(stances) do
    s[x] = mGetStanceByName(stances[x])
  end
  return s
end

-- stance switch
function mStanceSwitch(stances)
  local s = mGetStancesIndex(stances)
  for x,y in pairs(s) do
    local a,b,c,d = GetShapeshiftFormInfo(s[x])
    if c == 1 then
      CastShapeshiftForm(s[mod(x, getn(s)) + 1])
      return nil
    end
  end
  CastShapeshiftForm(s[1])
end

-- cast a random stance from the player ones
local function mStanceRandomNoArg()
  local a,b,c,n,f
  n = GetNumShapeshiftForms()
  while not f or c do
    f = math.random(1, n)
    a,b,c = GetShapeshiftFormInfo(f)
  end
  CastShapeshiftForm(f)
end

-- cast a random stance from list o from all
function mStanceRandom(stances)
  if stances and getn(stances) > 1 then
    local n, x, y, z, a
    local s = mGetStancesIndex(stances)
    n = getn(s)
    while not x or a do
      x = math.random(1, n)
      y,z,a = GetShapeshiftFormInfo(s[x])
    end
    CastShapeshiftForm(s[x])
  else
    mStanceRandomNoArg()
  end
end

-- search item in the Auction House
function mSearchContainerItemAuction(bag,slot)
  local itemLink = GetContainerItemLink(bag,slot)
  if itemLink then
    local name = mGetItemName(itemLink)
    mPrint("Searching: " .. name)
    QueryAuctionItems(name)
  end
end

local bagIndex = 0
local slotIndex = 1

-- reset search indexes (see below)
function mResetSearchIndex()
  mPrint("Resetting auction search index")
  bagIndex = 0
  slotIndex = 1
end

-- update the index to get next item
function mUpdateAuctionIndex()
  slotIndex = slotIndex + 1
  if slotIndex > GetContainerNumSlots(bagIndex) then
    slotIndex = 1
    bagIndex = mod(bagIndex + 1, 5)
  end
end

-- search next container item in the Auction House
function mIncrementalAuctionSearch()
  mSearchContainerItemAuction(bagIndex, slotIndex)
  mUpdateAuctionIndex()
end

-- post next container item in the Auction House post slot
function mIncrementalAuctionPost()
  PickupContainerItem(bagIndex, slotIndex)
  ClickAuctionSellItemButton()
  mUpdateAuctionIndex()
end

-- print netstats
function mNetStats()
  local a,b,c = GetNetStats()
  mPrint(string.format("Incoming bandwidth: %.4f kB/s\nOutgoing bandwidth: %.4f kB/s\nLatency: %d ms", a, b,c))
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

-- enable overpower warning
function mEnableOverpower()
  MikeConfig.overpower = true
  mReloadUI()
end

-- disable overpower warning
function mDisableOverpower()
  MikeConfig.overpower = false
  mReloadUI()
end

-- enable auto dismount
function mEnableAutoDismount()
  MikeConfig.autodismount = true
  mReloadUI()
end

-- disable auto dismount
function mDisableAutoDismount()
  MikeConfig.autodismount = false
  mReloadUI()
end

-- print auto dismount script status on console
function mPrintAutoDismountStatus()
  local s
  if MikeConfig.autodismount then
    s = "ON"
  else
    s = "OFF"
  end
  mPrint("Auto dismount script is " .. s)
end

-- print overpower script status on console
function mPrintOverpowerStatus()
  local s
  if MikeConfig.overpower then
    s = "ON"
  else
    s = "OFF"
  end
  mPrint("Overpower script is " .. s)
end

-- enable fishing warning
function mEnableFishing()
  MikeConfig.fishing = true
  mReloadUI()
end

-- disable fishing warning
function mDisableFishing()
  MikeConfig.fishing = false
  mReloadUI()
end

-- print fishing script status on console
function mPrintFishingStatus()
  local s
  if MikeConfig.fishing then
    s = "ON"
  else
    s = "OFF"
  end
  mPrint("Fishing script is " .. s)
end

-- enable tracker warning
function mEnableTrackerWarning()
  MikePlayerConfig.trackerWarning = true
  mReloadUI()
end

-- disable tracker warning
function mDisableTrackerWarning()
  MikePlayerConfig.trackerWarning = false
  mReloadUI()
end

-- print tracker warning script status on console
function mPrintTrackerWarningStatus()
  local s
  if MikePlayerConfig.trackerWarning then
    s = "ON"
  else
    s = "OFF"
  end
  mPrint("Tracker warning script is " .. s)
end

-- print unit stats
function mPrintUnitStats(unit)
  if UnitName(unit) then
    mPrint(UnitName(unit) .. " "  .. UnitLevel(unit) .. " " ..  UnitClass(unit))
    mPrint("HP: " .. UnitHealth(unit) .. "/" ..  UnitHealthMax(unit))
    mPrint("MP: " .. UnitPower(unit) .. "/" .. UnitPowerMax(unit))
  end
end

-- print fish stats
function mFishStats()
  mPrint("Fishes: " .. tostring(MikeData.fishing.fishes))
  mPrint("Points: " .. tostring(MikeData.fishing.points))
  mPrint("Fishes per points: " .. tostring(MikeData.fishing.fishes / MikeData.fishing.points))
end

-- launch when a fish is catched
function mOnFishCatch()
    MikeData.fishing.fishes = MikeData.fishing.fishes + 1
    mFishStats()
end

-- launch when a fishing skill point is earned
function mOnFishPointGain()
    MikeData.fishing.points = MikeData.fishing.points + 1
end

-- reset fish stats
function mFishReset()
    MikeData.fishing.points = 0
    MikeData.fishing.fishes = 0
end

-- print tracker warning
function mTrackerWarning()
  local msg = "Don't forget to enable your tracker!"
  if not UnitIsDeadOrGhost("player") then
    mEPrint(msg, 1, 1, 0)
    mPrint(msg, 1, 1, 0)
  end
end
