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

local frame = CreateFrame("FRAME", "MikeAddonFrame")
frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:RegisterEvent("PLAYER_LEAVE_COMBAT")
local function mEventHandler(...)
  if event == "PLAYER_TARGET_CHANGED" then
    mTargetResetCastSequence()
  elseif event == "PLAYER_LEAVE_COMBAT" then
    mCombatResetCastSequence()
  end
end
frame:SetScript("OnEvent", mEventHandler)
