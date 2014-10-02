-- Mike's Addon, version 1.0

-- slash command
SLASH_MIKE1, SLASH_MIKE2 = '/mike', '/mi';

-- number of search iterations (increasing this will also increase cpu load)
N=10;

-- chat print
function mPrint(s)
  ChatFrame1:AddMessage(s);
end

-- return an array of strings using sep as separator
function mSplit(s, sep) 
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
function mSubTable(t, x, y)
  local a = {}
  for i=x,y do
    a[i-1] = t[i]
  end
  return a;
end

-- array of word to string
function mAToString(a, sep)
  sep = sep or ' ';
  local s = "";
  for x in a do
    s = s .. sep .. a[x];
  end
  return string.sub(s, 2, string.len(s));
end

-- return a string from args in a table, starting from i(default:2) to j(default:end)
function mGetSubargs(a, i, j)
  i = i or 2;
  j = j or table.getn(a);
  return (mAToString(mSubTable(a, i, j)));
end

-- count buffs on a target
function mBuffCount(target)
  local i=1; 
  while UnitBuff(target, i) ~= nil do 
    i=i+1;
  end
  return i-1;
end

-- count debuffs on a target
function mDebuffCount(target)
  local i=1; 
  while UnitDebuff(target, i) ~= nil do 
    i=i+1;
  end
  return i-1;
end

-- cast s1 if target isn't debuffed, else s2
function mCastIfDebuffed(debuff, s1, s2)
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
function mMassBuff(spellName, checkString)
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
function mMassDebuff(spellName, checkString)
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
function mCheckHp(perc) 
  return (UnitHealth("target")/UnitHealthMax("target")) < (perc/100.0);
end

-- cast a spell on  nearest friendly player if his/her hp % is < than perc
function mMassHeal(spellName, perc)
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
function mLifeSpell(perc, s1, s2) 
  if mCheckHp(perc) then
    CastSpellByName(s1);
  else
    CastSpellByName(s2);
  end
end

-- target nearest enemy and attack
function mTargetAttack()
  TargetNearestEnemy();
  AttackTarget();
end

-- cast spell on party member n
function mPartyMemberCast(n, spell)
  TargetUnit("party" .. n);
  CastSpellByName(spell);
  TargetLastTarget();
end

-- print netstats 
function mNetStats()
  local a,b,c = GetNetStats();
  mPrint(string.format("Incoming bandwidth: %.4f kB/s\nOutgoing bandwith: %.4f kB/s\nLatency: %d ms", a, b,c));
end

-- print mem usage
function mMemUsage()
  local m = gcinfo();
  local t = {"kB", "MB", "GB"};
  local i = math.floor(math.log10(m) / 3);
  mPrint(string.format("Memory usage: %.2f %s", m/math.pow(10, i*3), t[i+1]));
end

-- print fps
function mFramerate()
  mPrint(string.format("FPS: %.4f", GetFramerate()));
end

-- trigger UI reload
function mReloadUI()
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
  elseif m[1] == "reset" then
    mPrint("Your instances has been reset");
    ResetInstances();
  elseif m[1] == "rl" then
    mReloadUI();
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
    mPrint("/mike net: print netstats");
    mPrint("/mike fps: print framerate");
    mPrint("/mike mem: print addon memory usage");
    mPrint("/mike reset: reset instances!");
    mPrint("/mike rl: reload user interface");
    mPrint("/mike fortitude: buff stamina on your friends!");
    mPrint("/mike heal <percent> <spellname>: cast an healing spell on nearest player with hp% < percent");
    mPrint("/mike lspell <percent> <s1>,<s2>: cast s1 if target %hp is < percent, else s2");
    mPrint("/mike pcast <n> <spell>: cast spell on party on #n party member");
    mPrint("/mike wpain: cast 'Shadow Word: Pain' if not debuffed, else wand 'Shoot'");
    mPrint("/mike apain: cast 'Shadow Word: Pain' on nearest enemy not debuffed");
    mPrint("/mike sunder: cast 'Sunder Armor' on nearest enemy not debuffed");
    mPrint("/mike tattack: target nearest enemy (like TAB) and auto-attack");
  end
end
