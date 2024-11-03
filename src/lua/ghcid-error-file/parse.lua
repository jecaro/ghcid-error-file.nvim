---@class Item
---@field filename string
---@field lnum number
---@field lnum_end number?
---@field col number
---@field end_col number?
---@field text string
---@field type 'E' | 'W'

local M = {}

---@param line string
---@return Item?
local match_message_start = function(line)
  -- src/Options.hs:5:1: error:
  local matched_1 = { line:match('^(.+):(%d+):(%d+): ([ew]).*: ?(.*)$') }
  if #matched_1 > 0 then
    local filename, lnum, col, type, text = unpack(matched_1)

    local current = {
      col = col,
      filename = filename,
      lnum = lnum,
      text = text,
      type = type:upper(),
    }

    return current
  end

  -- src/Options.hs:56:50-53: error:
  local matched_2 = { line:match('^(.+):(%d+):(%d+)-(%d+): ([ew]).*: ?(.*)$') }
  if #matched_2 > 0 then
    local filename, lnum, col, end_col, type, text = unpack(matched_2)

    local current = {
      col = col,
      filename = filename,
      lnum = lnum,
      end_col = end_col,
      text = text,
      type = type:upper(),
    }

    return current
  end

  -- src/Options.hs:(54,1)-(56,45): warning: [-Wincomplete-patterns]
  local matched_3 = {
    line:match('^(.+):%((%d+),(%d+)%)%-%((%d+),(%d+)%): ([ew]).*: ?(.*)$')
  }
  if #matched_3 > 0 then
    local filename, lnum, col, end_lnum, end_col, type, text = unpack(matched_3)

    local current = {
      col = col,
      end_col = end_col,
      end_lnum = end_lnum,
      filename = filename,
      lnum = lnum,
      text = text,
      type = type:upper(),
    }

    return current
  end

  return nil
end

---@param str string
---@return string str
local add_new_line_if_needed = function(str)
  if not str:match('\n$') then
    return str .. '\n'
  else
    return str
  end
end

---@param str string
---@return function(): string
local lines = function(str)
  return str:gmatch('([^\n]*)\n')
end

---@param line string
---@return boolean
local match_carret_diagnostic = function(line)
  return line:match('^ *%d* *|.*$') ~= nil
end

---@param str string
---@return Item[]
M.parse = function(str)
  str = add_new_line_if_needed(str)

  local result = {}

  for line in lines(str) do
    local message_start = match_message_start(line)

    -- Create a new message
    if message_start then
      table.insert(result, message_start)
      -- Append everything else but the content of the carret diagnostic
    elseif not match_carret_diagnostic(line) and #result > 0 then
      local last = result[#result]

      local space = ''
      if last.text ~= '' then
        space = ' '
      end

      last.text = last.text .. space .. line:gsub('^ *', '')
    end
  end

  return result
end

return M
