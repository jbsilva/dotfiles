local M = {}

---------------------------------------------------------------------------
--> Pickers
--
-- Called from the `keys` table in the plugin spec rather than mapped here, so
-- fzf-lua stays lazy: lazy.nvim binds a stub and only loads it on the first
-- press.
--
-- Stepping out of the tree first: a picker opened while the cursor is in
-- NvimTree would otherwise open the file in the tree's own window.
---------------------------------------------------------------------------
local function leave_tree()
  if vim.bo.filetype == 'NvimTree' then
    vim.cmd.wincmd('l')
  end
end

function M.pick(name, opts)
  leave_tree()
  require('fzf-lua')[name](opts)
end

-- Ctrl-p: tracked + untracked files in a repo, every file outside one.
--
-- git_files defaults to `git ls-files --exclude-standard`, which is tracked
-- only; --others --cached adds untracked files while still honouring
-- .gitignore. That is what telescope's show_untracked = true did.
--
-- Outside a repo git_files errors rather than returning empty, so the fallback
-- is a pcall the same way it was under telescope.
function M.project_files()
  leave_tree()
  local fzf = require('fzf-lua')
  local ok = pcall(fzf.git_files, {
    cmd = 'git ls-files --exclude-standard --others --cached',
  })
  if not ok then
    fzf.files()
  end
end

function M.config()
  local actions = require('fzf-lua.actions')

  require('fzf-lua').setup({
    winopts = {
      -- Prompt at the top with the list below it, as sorting_strategy
      -- 'ascending' plus prompt_position 'top' did under telescope.
      height = 0.85,
      width = 0.85,
      preview = { layout = 'flex' },
    },

    -- fzf itself already binds esc to abort, ctrl-j/ctrl-k to down/up and tab
    -- to toggle+down, so only the quickfix keys need saying. ctrl-q and ctrl-s
    -- are the telescope bindings; ctrl-s is fzf-lua's split by default.
    actions = {
      files = {
        ['enter'] = actions.file_edit_or_qf,
        ['ctrl-q'] = actions.file_sel_to_qf,
        ['ctrl-s'] = actions.file_sel_to_qf,
        ['ctrl-v'] = actions.file_vsplit,
        ['ctrl-t'] = actions.file_tabedit,
      },
    },

    fzf_opts = {
      ['--layout'] = 'reverse',
    },
  })
end

return M
