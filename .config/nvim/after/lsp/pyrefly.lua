-------------------------------------------------------------------------------
--> pyrefly
--
-- Meta's Python type checker. Like ty, much faster than pyright and still
-- young, so it is not the default -- see the python_type_checkers list in
-- plugins/config/lsp.lua and :PyTypeChecker.
--
-- nvim-lspconfig supplies cmd, filetypes and root_markers.
-------------------------------------------------------------------------------
---@type vim.lsp.Config
return {
  -- nvim-lspconfig notifies on every exit, including the clean one on quit or
  -- on :PyTypeChecker switching away, which is a popup each time. Report only
  -- an actual crash.
  on_exit = function(code, _, _)
    if code == 0 then
      return
    end
    vim.schedule(function()
      vim.notify('pyrefly exited with code ' .. code, vim.log.levels.WARN)
    end)
  end,

  -- Unused imports and variables arrive tagged Unnecessary rather than as a
  -- configurable rule, and ruff already reports them (F401, F841). Without
  -- this every one is reported twice.
  handlers = {
    ['textDocument/publishDiagnostics'] = function(err, result, ctx)
      if result and result.diagnostics then
        result.diagnostics = vim.tbl_filter(function(d)
          return not (
            d.tags and vim.tbl_contains(d.tags, vim.lsp.protocol.DiagnosticTag.Unnecessary)
          )
        end, result.diagnostics)
      end
      vim.lsp.handlers['textDocument/publishDiagnostics'](err, result, ctx)
    end,
  },
}
