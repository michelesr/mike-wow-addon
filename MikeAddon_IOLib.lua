--[[

Mike's WoW Addon
Version: 1.0.4
I/O Utilities

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

-- chat print (rgb colors intensity from 0 to 1)
function mPrint(s, r, g, b)
  ChatFrame1:AddMessage(s, r, g, b)
end

-- return an array of strings using sep as separator
function mSplit(s, sep) 
  sep = sep or " "
  local step = string.len(sep)
  local t = {} 
  local i=1
  local start = 1
  local j = string.find(s, sep)
  if j then
    while j do
      t[i] = string.sub(s, start, j-1)
      i = i+1
      start = j+step
      j = string.find(s, sep, start)
    end
  end
  t[i] = string.sub(s, start)
  return t
end

-- split paths
function mPathSplit(s)
  if string.find(s, '\\') then
    return mSplit(s, '\\')
  elseif string.find(s, '/') then
    return mSplit(s, '/')
  end
end

-- return a subtable
function mSubTable(t, x, y)
  local a = {}
  for i=x,y do
    a[i-1] = t[i]
  end
  return a
end

-- array of word to string
function mAToString(a, sep)
  sep = sep or ' '
  local s = ""
  for x in a do
    s = s .. sep .. a[x]
  end
  return string.sub(s, 2, string.len(s))
end

-- return a string from args in a table, starting from i(default:2) to j(default:end)
function mGetSubArgs(a, i, j)
  i = i or 2
  j = j or table.getn(a)
  return (mAToString(mSubTable(a, i, j)))
end
