local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local parse = require('ghcid-error-file.parse').parse

local T = new_set()

local all_good = [[All good (2 modules, at 21:51:33)]]

T["all_good"] = function()
  local qflist = parse(all_good)
  eq(qflist, {})
end

local example_1 = [[src/Options.hs:5:1: error:
    parse error (possibly incorrect indentation or mismatched brackets)
  |
5 | import Prelude hiding (lines)
  | ^]]

T["example_1"] = function()
  local qflist = parse(example_1)
  local expected = {
    {
      filename = 'src/Options.hs',
      lnum = '5',
      col = '1',
      text = 'parse error (possibly incorrect indentation or mismatched brackets)',
      type = 'E',
    }
  }
  eq(qflist, expected)
end

local example_2 = [[src/Options.hs:56:50-53: error:
    • Couldn't match type ‘Bool’ with ‘[Char]’
      Expected: String
        Actual: Bool
    • In the second argument of ‘(<>)’, namely ‘True’
      In the expression: "You must define a rule" <> True
      In an equation for ‘render’:
          render MissingRule = "You must define a rule" <> True
   |
56 | render MissingRule = "You must define a rule" <> True
   |                                                  ^^^^]]

T["example_2"] = function()
  local qflist = parse(example_2)
  local expected = {
    {
      filename = 'src/Options.hs',
      lnum = '56',
      col = '50',
      end_col = '53',
      text =
      '• Couldn\'t match type ‘Bool’ with ‘[Char]’ Expected: String Actual: Bool • In the second argument of ‘(<>)’, namely ‘True’ In the expression: "You must define a rule" <> True In an equation for ‘render’: render MissingRule = "You must define a rule" <> True',
      type = 'E',
    }
  }
  eq(qflist, expected)
end

local example_3 = [[src/Options.hs:(54,1)-(56,45): warning: [-Wincomplete-patterns]
    Pattern match(es) are non-exhaustive
    In an equation for ‘render’:
        Patterns of type ‘Error’ not matched: Coucou
   |
54 | render (MustBeInt str) = str <> " argument must be an int"
   | ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^...]]

T["example_3"] = function()
  local qflist = parse(example_3)
  local expected = {
    {
      filename = 'src/Options.hs',
      lnum = '54',
      end_lnum = '56',
      col = '1',
      end_col = '45',
      text =
      '[-Wincomplete-patterns] Pattern match(es) are non-exhaustive In an equation for ‘render’: Patterns of type ‘Error’ not matched: Coucou',
      type = 'W',
    }
  }
  eq(qflist, expected)
end

T["multiple errors"] = function()
  local qflist = parse(example_1 .. '\n' .. example_2 .. '\n' .. example_3)
  local expected = {
    {
      filename = 'src/Options.hs',
      lnum = '5',
      col = '1',
      text = 'parse error (possibly incorrect indentation or mismatched brackets)',
      type = 'E',
    },
    {
      filename = 'src/Options.hs',
      lnum = '56',
      col = '50',
      end_col = '53',
      text =
      '• Couldn\'t match type ‘Bool’ with ‘[Char]’ Expected: String Actual: Bool • In the second argument of ‘(<>)’, namely ‘True’ In the expression: "You must define a rule" <> True In an equation for ‘render’: render MissingRule = "You must define a rule" <> True',
      type = 'E',
    },
    {
      filename = 'src/Options.hs',
      lnum = '54',
      end_lnum = '56',
      col = '1',
      end_col = '45',
      text =
      '[-Wincomplete-patterns] Pattern match(es) are non-exhaustive In an equation for ‘render’: Patterns of type ‘Error’ not matched: Coucou',
      type = 'W',
    }
  }
  eq(qflist, expected)
end

return T
