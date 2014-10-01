-- Mike's Addon, version 1.0

-- slash command
SLASH_MIKE1, SLASH_MIKE2 = '/mike', '/mi';

-- number of search iterations (increasing this will also increase cpu load)
N=10;

-- chat print
function mprint(s)
  ChatFrame1:AddMessage(s);
end

-- return an array of strings using sep as separator
function msplit(s, sep) 
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
function msubtable(t, x, y)
  local a = {}
  for i=x,y do
    a[i-1] = t[i]
  end
  return a;
end

-- array of word to string
function matostring(a, sep)
  sep = sep or ' ';
  local s = "";
  for x in a do
    s = s .. sep .. a[x];
  end
  return string.sub(s, 2, string.len(s));
end

-- return a string from args in a table
function mgetsubargs(a)
  return (matostring(msubtable(a, 2, table.getn(a))));
end

-- count buffs on a target
function mbuffcount(target)
  local i=1; 
  while UnitBuff(target, i) ~= nil do 
    i=i+1;
  end
  return i-1;
end

-- count debuffs on a target
function mdebuffcount(target)
  local i=1; 
  while UnitDebuff(target, i) ~= nil do 
    i=i+1;
  end
  return i-1;
end

-- buff all unbuffed friends with a spell
function mmassbuff(spellname, checkstring)
  local i=1; local goon = true;
  while i <= N and goon do
    i=i+1; TargetNearestFriend();
    local x = true;
    local n = mbuffcount("target")+1;
    local k = 1;
    while k < n do
      if string.find(UnitBuff("target", k),checkstring) ~= nil then
        x=false;
      end k=k+1;
    end
    if x == true and UnitIsPlayer("target") then
      CastSpellByName(spellname);
      goon = false;
    end
  end 
end

-- cast dbfspell if debuff is not active on target, else altspell
function mcastifdebuffed(debuff, dbfspell, altspell)
  local n = mdebuffcount("target")+1;
  local i = 1;
  local x = false;
  while i < n do
    if string.find(UnitDebuff("target", i), debuff) ~= nil then
      x = true;
    end i=i+1;
  end
  if x then
    CastSpellByName(altspell);
  else
    CastSpellByName(dbfspell);
  end
end

-- cast dbfspell on all near enemy units
function mmassdebuff(spellname, checkstring)
  local i = 1; local goon = true;
  while i <= N and goon do
    i=i+1; TargetNearestEnemy();
    local x = true;
    local n = mdebuffcount("target")+1;
    local k = 1;
    while k < n do
      if string.find(UnitDebuff("target", k),checkstring) ~= nil then
        x=false;
      end k=k+1;
    end
    if x == true then
      CastSpellByName(spellname);
      goon = false;
    end
  end 
end

-- heal nearest friendly player if his/her hp % is < than perc
function mmassheal(spellname, perc)
  local i = 1; local goon = true;
  while i <= N and goon do
    i=i+1; TargetNearestFriend();
    if (UnitHealth("target")/UnitHealthMax("target") < (perc/100.0) and (UnitIsPlayer("target"))) then
      CastSpellByName(spellname);
      goon = false;
    end
  end
end

-- print netstats 
function mnetstats()
  local a,b,c = GetNetStats();
  mprint(string.format("Incoming bandwidth: %.4f kB/s\nOutgoing bandwith: %.4f kB/s\nLatency: %d ms", a, b,c));
end

-- print mem usage
function mmemusage()
  local m = gcinfo();
  local t = {"kB", "MB", "GB"};
  local i = math.floor(math.log10(m) / 3);
  mprint(string.format("Memory usage: %.2f %s", m/math.pow(10, i*3), t[i+1]));
end

-- print fps
function mframerate()
  mprint(string.format("FPS: %.4f", GetFramerate()));
end

-- slash command menu
function SlashCmdList.MIKE(msg, editbox)
  local m = msplit(msg);
  if m[1] == "net" then
    mnetstats();
  elseif m[1] == "mem" then
    mmemusage();
  elseif m[1] == "fps" then
    mframerate();
  elseif m[1] == "reset" then
    mprint("Your instances has been reset");
    ResetInstances();
  elseif m[1] == "print" then
    mprint(mgetsubargs(m));
  elseif m[1] == "fortitude" then
    mmassbuff("Power Word: Fortitude", "Fort");
  elseif m[1] == "heal" then
    sn = matostring(msubtable(m, 3, table.getn(m)));
    mmassheal(sn, tonumber(m[2]));
  elseif m[1] == "wpain" then
    mcastifdebuffed("Pain", "Shadow Word: Pain", "Shoot");
  elseif m[1] == "apain" then
    mmassdebuff("Shadow Word: Pain", "Pain");
  elseif m[1] == "sunder" then
    mmassdebuff("Sunder Armor", "Sunder");
  else 
    mprint("Mike's Addon");
    mprint("Usage: /mike <arg> OR /mi <arg>");
    mprint("/mike net: print netstats");
    mprint("/mike fps: print framerate");
    mprint("/mike mem: print addon memory usage");
    mprint("/mike reset: reset instances!");
    mprint("/mike fortitude: buff stamina on your friends!");
    mprint("/mike heal <percent> <spellname>: cast heal on next player with hp% < percent");
    mprint("/mike wpain: cast 'Shadow Word: Pain' if not debuffed, else wand 'Shoot'");
    mprint("/mike apain: cast 'Shadow Word: Pain' on nearest enemy not debuffed");
    mprint("/mike sunder: cast 'Sunder Armor' on nearest enemy not debuffed");
  end
end
