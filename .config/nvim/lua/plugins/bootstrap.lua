-------------------------------------------------------------------------------
--> Bootstrap lazy.nvim
--
-- Replaces wbthomason/packer.nvim, which was archived in August 2023.
-- lazy.nvim clones itself into stdpath('data')/lazy/lazy.nvim and is added to
-- the runtimepath *before* anything else, so it must run before plugin specs
-- are evaluated.
--
-- Docs: https://lazy.folke.io/
-------------------------------------------------------------------------------
local M = {}

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'

function M.ensure_lazy()
  if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local repo = 'https://github.com/folke/lazy.nvim.git'
    local out = vim.fn.system({
      'git',
      'clone',
      '--filter=blob:none',
      '--branch=stable',
      repo,
      lazypath,
    })

    if vim.v.shell_error ~= 0 then
      vim.api.nvim_echo({
        { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
        { out, 'WarningMsg' },
        { '\nPress any key to exit...' },
      }, true, {})
      vim.fn.getchar()
      os.exit(1)
    end
  end

  vim.opt.rtp:prepend(lazypath)
end

return M
