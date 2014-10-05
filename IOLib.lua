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