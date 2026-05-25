vim.pack.add({"https://github.com/Shatur/neovim-ayu"})

require('ayu').setup({
        overrides = function()
          if vim.o.background == "dark" then
            return {
              Statement = { bold = true, fg = "#10b0fe" },
              Operator = { fg = "#ff6d7e" },
              Title = { fg = "#10b0fe" },
              -- Type = { fg = "#ff6d7e" },
              LineNr = { fg = "#274670" },
              Directory = { fg = "#16A883" },
              Constant = { fg = "#ff78ff" },
            }
          else
            return {
              Structure = { bg = "#10b0fe" },
              -- Delimiter = { fg = "#FF7729" },
              Special = { fg = "#FF7729" },
              -- Special = { fg = "#029E29" },
              -- Statement = { fg = "#10b0fe" },
              -- Statement = { italic = true  },
              Directory = { fg = "#029E92" },
              String = { fg = "#029E29" },
              Operator = { fg = "#ff6d7e" },
              Title = { fg = "#10b0fe" },
              CursorLineNr = { fg = "#FA4420" },
              LineNr = { fg = "#274670" },
              -- PreProc = { fg = "#FA4420" },
              -- MatchParen = { fg = "#ff00ff" },
              Constant = { fg = "#ff00ff" },
              ["@variable.builtin"] = { fg = "#029E92" },
              Function = { fg = "#029E92" },
            }
          end
        end,
      })

