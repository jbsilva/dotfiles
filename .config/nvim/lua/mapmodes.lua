-------------------------------------------------------------------------------
--> Utility function to get mapmodes with the traditional names
-- Check `:help map-table`
-------------------------------------------------------------------------------
local M = {}

-- These only name the mode. vim.keymap.set already defaults to a
-- non-remapping mapping, so there is nothing else to pass.
--
-- For the rare mapping that does have to go through other mappings, put
-- `{ remap = true }` in `opts`. Not `noremap = false`: vim.keymap.set ignores
-- that and forces noremap whenever `remap` is unset.
local function bind(mode)
  return function(lhs, rhs, opts)
    vim.keymap.set(mode, lhs, rhs, opts)
  end
end

M.noremap = bind({ 'n', 'v', 'o' })
M.nnoremap = bind('n')
M.vnoremap = bind('v')
M.xnoremap = bind('x')
M.inoremap = bind('i')
M.onoremap = bind('o')

return M
