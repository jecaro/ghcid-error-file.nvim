vim.cmd.packadd('mini.nvim')

-- Add the src directory to 'runtimepath' to be able to use 'lua' files
vim.cmd([[let &rtp.=','.getcwd().'/src']])

require('mini.test').setup({
  collect = {
    find_files = function()
      return vim.fn.globpath('./', './src/**/*_test.lua', true, true)
    end,
    -- desc contains the name of the file, then the name of the test, and the
    -- scopes
    -- example to focus on example_3 test:
    -- filter_cases = function(case)
    --   return case.desc[2]:match('example_3')
    -- end,
  },
})
