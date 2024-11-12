local M = {}

--- @param path string
--- @return string path
local add_slash_if_needed = function(path)
  if not path:match('/$') then
    vim.notify('Adding a slash to the path', vim.log.levels.INFO)
    return path .. '/'
  else
    return path
  end
end

-- Global variable to store the base directory when working with a
-- multi-project package
--- @type string
local base_dir = ''

M.cfResetBaseDir = function()
  base_dir = ''
end

--- @param new_base_dir string
M.cf = function(new_base_dir)
  -- read the file
  local f = io.open(vim.o.errorfile, 'r')
  if not f then
    vim.notify('Could not open file: ' .. vim.o.errorfile, vim.log.levels.ERROR)
    return
  end

  local content = f:read('*a')
  f:close()

  -- parse it
  local diagnostics = require('ghcid-error-file.parse').parse(content)

  -- eventually update the base directory
  if new_base_dir ~= '' then
    new_base_dir = add_slash_if_needed(new_base_dir)
    vim.notify('Setting relative path to ' .. new_base_dir, vim.log.levels.INFO)
    base_dir = new_base_dir
  end

  -- in any case fix the filenames
  for _, diagnostic in ipairs(diagnostics) do
    diagnostic.filename = base_dir .. diagnostic.filename
  end

  -- remove messages with non-existing files
  local filtered = {}
  local removed_files = {}
  for _, diagnostic in ipairs(diagnostics) do
    if vim.fn.filereadable(diagnostic.filename) == 1 then
      table.insert(filtered, diagnostic)
    else
      table.insert(removed_files, diagnostic.filename)
    end
  end

  -- warn on error
  if #removed_files > 0 then
    local message_start;
    if #removed_files == 1 then
      message_start = 'This file doesn\'t exist: '
    else
      message_start = 'These files don\'t exist: '
    end

    vim.notify(
      message_start .. table.concat(removed_files, ', '),
      vim.log.levels.WARN
    )
  end

  -- update the quickfix list
  vim.fn.setqflist(filtered, ' ')

  -- move to the first error
  if #filtered > 0 then
    vim.cmd('cfirst')
    -- print a message otherwise
  elseif #removed_files == 0 then
    local message = 'All good'
    local new_content, nb_lines = content:gsub('\n', '')
    if nb_lines == 1 then
      message = new_content
    end
    vim.notify(message, vim.log.levels.INFO)
  end
end

return M
