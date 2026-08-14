-------------------------------------------------------------------------------
--> Markdown
--
-- No 'textwidth': prettier (via conform) and mdformat (via the pre-commit
-- hooks) decide where these files wrap, and a hard wrap while typing would
-- fight both.
-------------------------------------------------------------------------------
vim.opt_local.spell = true
vim.opt_local.spelllang = 'en_us'

-- Same reason as after/ftplugin/text.lua: prose plus 'wrap' means moving by
-- screen line is what is wanted.
for _, lhs in ipairs({ 'j', 'k', '0', '$' }) do
  vim.keymap.set({ 'n', 'x' }, lhs, 'g' .. lhs, { buffer = true, desc = 'Move by screen line' })
end
