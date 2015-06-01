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
        MikeConfig = {
            overpower = false
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
end
frame:SetScript("OnEvent", mEventHandler)
