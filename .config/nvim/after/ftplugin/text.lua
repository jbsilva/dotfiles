-------------------------------------------------------------------------------
--> Plain text
--
-- Was a BufEnter/BufWinEnter/TabEnter autocmd matching '*.txt'. That pattern
-- matches file names, and Neovim's own help files are .txt, so every :help
-- page was being spell-checked too. Filetype 'text' is the thing that was
-- actually meant.
--
-- Spell checking: `]s` `[s` to move, `z=` to correct, `zg` to add a word,
-- `zw` to mark one wrong. `:setlocal nospell` turns it off for one buffer.
-------------------------------------------------------------------------------
vim.opt_local.textwidth = 80
vim.opt_local.spell = true
vim.opt_local.spelllang = 'en_us'

-- 'wrap' is on globally, so in prose move by screen line rather than by
-- logical line -- otherwise j skips a whole wrapped paragraph.
for _, lhs in ipairs({ 'j', 'k', '0', '$' }) do
  vim.keymap.set({ 'n', 'x' }, lhs, 'g' .. lhs, { buffer = true, desc = 'Move by screen line' })
end
