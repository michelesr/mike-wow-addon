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
frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("ADDON_LOADED")
local function mEventHandler(...)
  if event == "ADDON_LOADED" and arg1 == "MikeAddon" then
    mPrint("Mike's Addon v" .. version .. " loaded. See options with /mi", 1, 1, 0)
  elseif event == "PLAYER_TARGET_CHANGED" then
    mTargetResetCastSequence()
  elseif event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED" then
    mCombatResetCastSequence()
  end
end
frame:SetScript("OnEvent", mEventHandler)
