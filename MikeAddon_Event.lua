--[[

Mike's WoW Addon
Version: 1.0.4
Event handler

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

local version = "1.0.4"
local frame = CreateFrame("FRAME", "MikeAddonFrame")
local debug = false

local ATK_DOD = "You attack. (.+) dodges."
local SPL_DOD = "Your (.+) was dodged"
local FISH_MSG = "Your skill in Fishing has increased to (.+)"
local MOUNT_MSG = "ounted"

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")

local function mEventHandler()
  if debug then
    mPrint(event .. " " .. tostring(arg1) .. " " ..  tostring(arg2) ..  " " .. tostring(arg3) .. " " .. tostring(arg4) .. " " ..
           tostring(arg5) .. " " .. tostring(arg6) .. " " .. tostring(arg7) .. " " .. tostring(arg8) .. " " .. tostring(arg9) .. " " ..
           tostring (arg10))
  end
  if event == "ADDON_LOADED" and arg1 == "MikeAddon" then
    if not MikeConfig then
        MikeConfig = { overpower = false, fishing = false, autodismount = false }
    end
    if not MikePlayerConfig then
        MikePlayerConfig = { mount = nil, trackerWarning = false }
    end
    if not MikeData then
        MikeData = {
            fishing = { fishes = 0, points = 0 }
        }
    end
    mPrint("Mike's Addon v" .. version .. " loaded. See options with /mi", 1, 1, 0)
    if UnitClass("player") == "Warrior" then
      if MikeConfig.overpower then
        frame:RegisterEvent("CHAT_MSG_COMBAT_SELF_MISSES")
        frame:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
        mPrint("Mike's Addon: Overpower script loaded", 1, 1, 0)
      else
        mPrint("Mike's Addon: Overpower script not loaded, load with /mi op on", 1, 1, 0)
      end
    end
    if MikeConfig.fishing then
      frame:RegisterEvent("CHAT_MSG_SKILL")
      frame:RegisterEvent("CHAT_MSG_LOOT")
      frame:RegisterEvent("COMBAT_TEXT_UPDATE")
      frame:RegisterEvent("UI_ERROR_MESSAGE")
      frame:RegisterEvent("UI_INFO_MESSAGE")
      mPrint("Mike's Addon: Fishing script loaded", 1, 1, 0)
    end
    if MikeConfig.autodismount then
      frame:RegisterEvent("UI_ERROR_MESSAGE")
      mPrint("Mike's Addon: Auto dismount loaded", 1, 1, 0)
    end
    if MikePlayerConfig.trackerWarning then
      local playerIsDead = UnitIsDeadOrGhost("player")
      frame:RegisterEvent("PLAYER_DEAD")
      frame:RegisterEvent("PLAYER_UNGHOST")
      frame:RegisterEvent("PLAYER_ALIVE")
      mPrint("Mike's Addon: tracker warning loaded", 1, 1, 0)
    end
  elseif event == "PLAYER_TARGET_CHANGED" then
    mTargetResetCastSequence()
  elseif event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED" then
    mCombatResetCastSequence()
  elseif (event == "CHAT_MSG_SPELL_SELF_DAMAGE"  and string.find(arg1, SPL_DOD) or
          event == "CHAT_MSG_COMBAT_SELF_MISSES" and string.find(arg1, ATK_DOD)) and
         UnitLevel("player") >= 12 then
    mEPrint("<Overpower>", 1, 1, 0)
    mPrint("Your target has dodged! Overpower!", 1, 1, 0)
    PlaySound("RaidWarning")
  end
  if MikeConfig.fishing then
    if event == "COMBAT_TEXT_UPDATE" then
      if arg1 == "SPELL_CAST" and arg2 == "Fishing" then
        mStartFishing()
      else
        mStopFishing()
      end
    elseif event == "UI_ERROR_MESSAGE" or event == "UI_INFO_MESSAGE" then
      mStopFishing()
    elseif event == "CHAT_MSG_LOOT" then
      mOnFishCatch()
    elseif event == "CHAT_MSG_SKILL" and string.find(arg1, FISH_MSG) then
      mOnFishPointGain()
    end
  end
  if MikeConfig.autodismount and UnitLevel("player") >= 40 then
    if event == "UI_ERROR_MESSAGE" and string.find(arg1, MOUNT_MSG) then
      if MikePlayerConfig.mount then
        mCancelPlayerBuff(MikePlayerConfig.mount)
      else
        mPrint("Mike's Addon: auto dismount is enabled but mount isn't setted, " ..
               'use "/mi ad mount <mountBuff>" to set the mount for this player', 1, 1, 0)
      end
    end
  end
  if MikePlayerConfig.trackerWarning then
    if event == "PLAYER_DEAD" then
      playerIsDead = true
    end
    if playerIsDead and (event == "PLAYER_ALIVE" or event == "PLAYER_UNGHOST") then
      mTrackerWarning()
    end
  end
end

frame:SetScript("OnEvent", mEventHandler)
