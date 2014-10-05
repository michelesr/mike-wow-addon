-- Mike's Addon, version 1.0

-- slash command
SLASH_MIKE1, SLASH_MIKE2 = '/mike', '/mi';

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
  elseif m[1] == "equip" then
    local i = mSplit(mGetSubargs(m, 2), ",");
    mEquipItems(i); 
  elseif m[1] == "wequip" then
    local w = mSplit(mGetSubargs(m, 2), ",");
    mEquipHandWeapons({w[1], w[2]}); 
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
    mPrint("/mike equip <item1>,<item2>,...,<itemN>: equips items");
    mPrint("/mike wequip <w1>,<w2> = equip w1 on main hand and w2 on offhand");
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
