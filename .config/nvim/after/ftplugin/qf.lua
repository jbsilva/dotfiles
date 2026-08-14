-------------------------------------------------------------------------------
--> Quickfix and location list
--
-- Entries are one long line each (path, position, then the message), and the
-- window is short, so truncating at the edge hides the part that matters.
-------------------------------------------------------------------------------
vim.opt_local.wrap = true

-- The list is a jump target, not a place to sit: no relative numbers, and no
-- cursorline fighting the quickfix highlight of the current entry.
vim.opt_local.relativenumber = false
vim.opt_local.number = false
