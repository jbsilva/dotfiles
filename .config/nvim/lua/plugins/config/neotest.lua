local M = {}

function M.setup()
  vim.api.nvim_create_user_command('Neotest', function()
    require('neotest').run.run()
  end, { desc = 'Neotest: run nearest test' })
  vim.api.nvim_create_user_command('NeotestFile', function()
    require('neotest').run.run(vim.fn.expand('%'))
  end, { desc = 'Neotest: run the current file' })
  vim.api.nvim_create_user_command('NeotestStop', function()
    require('neotest').run.stop()
  end, { desc = 'Neotest: stop the nearest test' })

  ---------------------------------------------------------------------------
  --> Keymaps
  ---------------------------------------------------------------------------
  local remap = require('mapmodes')
  local nnoremap = remap.nnoremap

  nnoremap('<leader>tf', function()
    require('neotest').run.run(vim.fn.expand('%'))
  end, { desc = 'Neotest: run all tests in file' })

  nnoremap('<leader>tn', function()
    require('neotest').run.run()
  end, { desc = 'Neotest: run nearest test' })

  nnoremap('<leader>tl', function()
    require('neotest').run.run_last()
  end, { desc = 'Neotest: run last test' })

  nnoremap('<leader>ts', function()
    require('neotest').summary.toggle()
  end, { desc = 'Neotest: toggle summary' })

  nnoremap('<leader>to', function()
    require('neotest').output.open({ enter = true })
  end, { desc = 'Neotest: show test output' })
end

function M.config()
  require('neotest').setup({
    adapters = {
      require 'neotest-plenary',
      require 'neotest-rust'
      require('neotest-python')({
        dap = { justMyCode = false },
      }),
      require('neotest-vim-test')({
        ignore_file_types = { 'python', 'vim', 'lua' },
      }),
    },
  })
end

return M
