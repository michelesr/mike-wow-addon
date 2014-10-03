-- Mike's Addon, version 1.0

-- slash command
SLASH_MIKE1, SLASH_MIKE2 = '/mike', '/mi';

-- number of search iterations (increasing this will also increase cpu load)
local N=10;
local timer = GetTime();

-- chat print
function mPrint(s)
  ChatFrame1:AddMessage(s);
end

-- reset timer
local function mResetTimer()
  timer = GetTime();
  mPrint("Timer reset!");
end

-- get elapsed time
local function mGetElapsedTime()
  return GetTime() - timer;
end

-- print elapsed time from addon loading or last timer reset
local function mPrintElapsedTime()
  local t = mGetElapsedTime();
  local h = mod(t/3600, 60);
  local m = mod(t/60, 60);
  local s = mod(t, 60);
  mPrint(string.format("Elapsed time --  %.2d:%.2d:%.2d", h, m, s)); 
end

-- print player's position (x,y)
local function mPrintPosition()
  local x,y = GetPlayerMapPosition("player");
  local z = GetZoneText();
  mPrint(string.format("%s: %.2f, %.2f", z, x*100, y*100));
end

-- share objective of quest in party chat
local function mShareQuestObjective(i)
  local s = "Objectives for quest " ..  GetQuestLogTitle(i) .. ": "; 
  SelectQuestLogEntry(i);
  for j=1,GetNumQuestLeaderBoards(i) do
    s = s .. GetQuestLogLeaderBoard(j) .. "; ";
  end
  SendChatMessage(s, "party");
end

-- share quests objectives for shared quest in party
local function mShareQuestObjectives()
  for i=1,GetNumQuestLogEntries() do
    local j=1; local b=false;
    while (j <= 4 and not b) do
      b = IsUnitOnQuest(i, "party" .. j); 
      j = j + 1;
    end
    if b then
      mShareQuestObjective(i);
    end
  end
end

local function mShareSelectedQuestObjectives()
  mShareQuestObjective(GetQuestLogSelection());
end


-- return an array of strings using sep as separator
local function mSplit(s, sep) 
  sep = sep or "%s";
  local t = {}; i=1;
  local start = 1;
  local j = string.find(s, sep);
  if j then
    while j  do
      t[i] = string.sub(s, start, j-1);
      i = i+1; start = j+1;
      j = string.find(s, sep, start);
    end
  end
  t[i] = string.sub(s, start, j);
  return t;
end

-- return a subtable
local function mSubTable(t, x, y)
  local a = {}
  for i=x,y do
    a[i-1] = t[i]
  end
  return a;
end

-- array of word to string
local function mAToString(a, sep)
  sep = sep or ' ';
  local s = "";
  for x in a do
    s = s .. sep .. a[x];
  end
  return string.sub(s, 2, string.len(s));
end

-- return a string from args in a table, starting from i(default:2) to j(default:end)
local function mGetSubargs(a, i, j)
  i = i or 2;
  j = j or table.getn(a);
  return (mAToString(mSubTable(a, i, j)));
end

-- count buffs on a target
local function mBuffCount(target)
  local i=1; 
  while UnitBuff(target, i) ~= nil do 
    i=i+1;
  end
  return i-1;
end

-- count debuffs on a target
local function mDebuffCount(target)
  local i=1; 
  while UnitDebuff(target, i) ~= nil do 
    i=i+1;
  end
  return i-1;
end

-- cast s1 if target isn't debuffed, else s2
local function mCastIfDebuffed(debuff, s1, s2)
  local n = mDebuffCount("target")+1;
  local i = 1;
  local x = false;
  while i < n do
    if string.find(UnitDebuff("target", i), debuff) ~= nil then
      x = true;
    end i=i+1;
  end
  if x then
    CastSpellByName(s2);
  else
    CastSpellByName(s1);
  end
end

-- buff nearest unbuffed friendly unit with a spell
local function mMassBuff(spellName, checkString)
  ClearTarget();
  local i=1; local goon = true;
  while i <= N and goon do
    i=i+1; TargetNearestFriend();
    local x = true;
    local n = mBuffCount("target")+1;
    local k = 1;
    while k < n do
      if string.find(UnitBuff("target", k),checkString) ~= nil then
        x=false;
      end k=k+1;
    end
    if x == true and UnitIsPlayer("target") then
      CastSpellByName(spellName);
      goon = false;
    end
  end 
end


-- cast debuff spell on nearest enemy undebuffed unit
local function mMassDebuff(spellName, checkString)
  ClearTarget();
  local i = 1; local goon = true;
  while i <= N and goon do
    i=i+1; TargetNearestEnemy();
    local x = true;
    local n = mDebuffCount("target")+1;
    local k = 1;
    while k < n do
      if string.find(UnitDebuff("target", k),checkString) ~= nil then
        x=false;
      end k=k+1;
    end
    if x == true then
      CastSpellByName(spellName);
      goon = false;
    end
  end 
end

-- hp check, return true if hp < perc
local function mCheckHp(perc) 
  return (UnitHealth("target")/UnitHealthMax("target")) < (perc/100.0);
end

-- cast a spell on  nearest friendly player if his/her hp % is < than perc
local function mMassHeal(spellName, perc)
  ClearTarget();
  local i = 1; local goon = true;
  while i <= N and goon do
    i=i+1; TargetNearestFriend();
    if mCheckHp(perc) and UnitIsPlayer("target") then
      CastSpellByName(spellName);
      goon = false;
    end
  end
end

-- cast s1 if hp is < perc, else s2
local function mLifeSpell(perc, s1, s2) 
  if mCheckHp(perc) then
    CastSpellByName(s1);
  else
    CastSpellByName(s2);
  end
end

-- target nearest enemy and attack
local function mTargetAttack()
  TargetNearestEnemy();
  AttackTarget();
end

-- cast spell on party member n
local function mPartyMemberCast(n, spell)
  TargetUnit("party" .. n);
  CastSpellByName(spell);
  TargetLastTarget();
end

-- put your gear in your bag
local function mGetNaked()
  local k=1; local bag=0; 
  while (k <= 18 and bag <= 4) do
    local slot=1; local max=GetContainerNumSlots(bag)
    while (slot <= max and k <= 18) do
      if not GetContainerItemLink(bag, slot) then
        while not GetInventoryItemLink("player", k) do
          k = k+1;
        end
        PickupInventoryItem(k);
        if (bag == 0) then
          PutItemInBackpack();
        else
          PutItemInBag(bag+19);
        end
        k = k+1;
      end
      slot = slot + 1;
    end
    bag = bag + 1;
  end
end

-- sell poor quality items to a vendor
local function mPoorSellOrDestroy(destroy)
  destroy = destroy or false;
  for bag=0,4,1 do
    for slot=1,GetContainerNumSlots(bag) do
      local name = GetContainerItemLink(bag, slot);
      if name and string.find(name, "ff9d9d9d") then
        if destroy then
          mPrint("Destroying item: " .. name);
          PickupContainerItem(bag,slot);
          DeleteCursorItem();
        else
          mPrint("Selling item: " .. name);
          UseContainerItem(bag, slot)
        end
      end
    end
  end
end

-- destroy poor quality items
local function mPoorDestroy()
  mPoorSellOrDestroy(true);
end

local function mPoorSell()
  mPoorSellOrDestroy(false);
end

-- print netstats 
local function mNetStats()
  local a,b,c = GetNetStats();
  mPrint(string.format("Incoming bandwidth: %.4f kB/s\nOutgoing bandwith: %.4f kB/s\nLatency: %d ms", a, b,c));
end

-- print mem usage
local function mMemUsage()
  local m = gcinfo();
  local t = {"kB", "MB", "GB"};
  local i = math.floor(math.log10(m) / 3);
  mPrint(string.format("Memory usage: %.2f %s", m/math.pow(10, i*3), t[i+1]));
end

-- print fps
local function mFramerate()
  mPrint(string.format("FPS: %.4f", GetFramerate()));
end

-- trigger UI reload
local function mReloadUI()
  ReloadUI();
end

-- slash command menu
function SlashCmdList.MIKE(msg, editbox)
  local m = mSplit(msg);
  if m[1] == "net" then
    mNetStats();
  elseif m[1] == "mem" then
    mMemUsage();
  elseif m[1] == "fps" then
    mFramerate();
  elseif m[1] == "pos" then
    mPrintPosition();
  elseif m[1] == "timer" then
    mPrintElapsedTime();
  elseif m[1] == "treset" then
    mResetTimer();
  elseif m[1] == "ireset" then
    mPrint("Your instances has been reset");
    ResetInstances();
  elseif m[1] == "rl" then
    mReloadUI();
  elseif m[1] == "qshare" then
    mShareQuestObjectives();
  elseif m[1] == "qss" then
    mShareSelectedQuestObjectives();
  elseif m[1] == "psell" then
    mPoorSell();
  elseif m[1] == "pdestroy" then
    mPoorDestroy();
  elseif m[1] == "strip" then
    mGetNaked();
  elseif m[1] == "print" then
    mPrint(mGetSubargs(m));
  elseif m[1] == "fortitude" then
    mMassBuff("Power Word: Fortitude", "Fort");
  elseif m[1] == "heal" then
    local sn = mGetSubargs(m, 3);
    mMassHeal(sn, tonumber(m[2]));
  elseif m[1] == "lspell" then
    local perc = m[2];
    local spells = mSplit(mGetSubargs(m, 3), ",");
    mLifeSpell(tonumber(perc), spells[1], spells[2]);
  elseif m[1] == "pcast" then
    local n = m[2];
    mPartyMemberCast(n, mGetSubargs(m, 3));
  elseif m[1] == "wpain" then
    mCastIfDebuffed("Pain", "Shadow Word: Pain", "Shoot");
  elseif m[1] == "apain" then
    mMassDebuff("Shadow Word: Pain", "Pain");
  elseif m[1] == "sunder" then
    mMassDebuff("Sunder Armor", "Sunder");
  elseif m[1] == "tattack" then
    mTargetAttack();
  else 
    mPrint("Mike's Addon");
    mPrint("Usage: /mike <arg> OR /mi <arg>");
    mPrint("/mike net: print net stats");
    mPrint("/mike fps: print framerate");
    mPrint("/mike mem: print addon's memory usage");
    mPrint("/mike pos: print player position (x,y)");
    mPrint("/mike timer: get elapsed time since ui load or timer reset");
    mPrint("/mike treset: reset timer");
    mPrint("/mike ireset: reset instances");
    mPrint("/mike rl: reload user interface");
    mPrint("/mike qshare: share objectives of common quests in party");
    mPrint("/mike qss: share objectives for the quest that is selected (highlighted) in the quest log");
    mPrint("/mike psell: sell poor quality items");
    mPrint("/mike pdestroy: destroy without confirm all poor quality items");
    mPrint("/mike strip: put your equip in the inventory");
    mPrint("/mike fortitude: cast 'Power Word: Fortitude' on nearest unbuffed friendly player");
    mPrint("/mike heal <percent> <spellname>: cast an healing spell on nearest player with hp% < percent");
    mPrint("/mike lspell <percent> <s1>,<s2>: cast s1 if target %hp is < percent, else s2");
    mPrint("/mike pcast <n> <spell>: cast spell party member number n");
    mPrint("/mike wpain: cast 'Shadow Word: Pain' if not debuffed, else wand 'Shoot'");
    mPrint("/mike apain: cast 'Shadow Word: Pain' on nearest enemy not debuffed");
    mPrint("/mike sunder: cast 'Sunder Armor' on nearest enemy not debuffed");
    mPrint("/mike tattack: target nearest enemy (like TAB) and auto-attack");
  end
end
