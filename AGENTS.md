# AGENTS.md

Notes for anyone working in this repo, human or agent. The [README](README.md) covers how it is
wired and what lives where; this file is the part that is easy to get wrong.

## Working here

- `just lint` runs every hook over the whole repo. The same hooks run on commit, through
  [prek](https://github.com/j178/prek) rather than the Python `pre-commit`; `just hooks` installs
  them.
- The formatters gate commits, they are not advisory: stylua, nixfmt, mdformat, shellcheck. Match
  the style of the file you are in and they stay quiet.

## Traps that have cost time before

**`.config/` is an allow-list, not a deny-list.** A new file under `.config/` is invisible to git
until `.gitignore` has a `!` line for it — `git add` refuses it outright. The full procedure is
under "How `~/.config` is wired" in the README. `git check-ignore -v <path>` explains any ignored
path.

**`~/.config/nvim` is a whole-directory symlink into this repo,** so Neovim config edits are live
with no rebuild. Most other `.config` paths are linked file by file, and adding one needs an
`xdg.nix` entry as well as the `.gitignore` line.

**`lazy-lock.json` changes come from `:Lazy` commands, never from starting Neovim.** lazy.nvim calls
`Lock.update()` from exactly three places in `lazy/manage/init.lua` — install, update and clean — so
`:Lazy sync`, which runs all three, rewrites it and a plain startup does not. If it turns up
modified, someone ran one of those deliberately.

**Do not assume you caused a working-tree change.** The repo is in use while you work in it;
`nix-darwin/flake.lock`, `lazy-lock.json` and VS Code's `settings.json` all get modified by their
owners. Stage paths explicitly, never `git add -A`, and ask before reverting something you did not
write — a "stray" pin bump is more likely to be an intended update than an accident.

## Commits

Small and atomic, one logical change each. Subject is `area: imperative summary` — `nvim:`, `zsh:`,
`ci:` — with no prefix when the change spans the repo. The body explains *why*, and states what was
actually measured or verified rather than asserting that it works.

## Comments

Comments describe the current state of the code, in the present tense. No debugging narrative, no
"changed X to Y" history — git has that. Keep the *why* where it is load-bearing and would otherwise
be re-litigated; drop it where the code already says it.

## Verifying

Claims about behaviour are cheap to check here, so check them:

```sh
# Does the config still load?
nvim --headless -u .config/nvim/init.lua "+lua vim.wait(5000)" +qa

# What is actually mapped?
nvim --headless -c 'redir! > /tmp/maps.txt' -c 'silent map' -c 'redir END' -c 'qa!'

# Lint the Lua (lua_ls comes from Mason, it is not on $PATH)
~/.local/share/nvim/mason/bin/lua-language-server \
  --check .config/nvim --checklevel=Hint --logpath=/tmp/luals
```

That last one currently reports 13 problems, none of them real, because `.luarc.json` deliberately
omits `workspace.library` — lazydev owns it inside Neovim. Without it lua_ls cannot see Neovim's or
the plugins' types, so it reports `vim.lsp.Config` as an unknown name once per `after/lsp/` file,
and a few `different-requires` where a local module shares a plugin's name
(`plugins/config/telescope.lua` and `telescope`). To see what the editor sees, copy the tree
somewhere and add the Neovim runtime plus `~/.local/share/nvim/lazy/*/lua` to `workspace.library` in
the copy; that run reports 7, all of them nvim-dap fields that lua_ls cannot infer.

Three things that will hand you a wrong answer:

1. **`VimEnter` fires after every `-c` command,** so `vim.v.vim_did_enter` is 0 inside them.
   Anything that behaves differently once startup is done — `vim.lsp.enable()`'s retroactive attach,
   for one — looks broken. Put the test inside a `VimEnter` callback.
2. **`lua-language-server --check` caches per path.** Re-running it over the same directory can
   report a stale "no problems found". Copy into a fresh directory for each run.
3. **Mason is lazy-loaded** behind nvim-lspconfig, so `:MasonInstall` does not exist in a headless
   run until something pulls it in. `require('mason-registry')` first.

## Neovim

**Per-server LSP settings belong in `after/lsp/<name>.lua`, never `lsp/<name>.lua`.** Every
`lsp/<name>.lua` on the runtimepath merges into a single tier in runtimepath order, and plugin
directories come after the config directory — so a plain `lsp/pyright.lua` here is overridden by the
one nvim-lspconfig ships. `after/lsp/` is a strictly higher tier and extends it instead. See
`:h lsp-config-merge`.

**Per-filetype settings belong in `after/ftplugin/<filetype>.lua`,** not a `FileType` autocmd, and
never an autocmd matching a file glob: `*.txt` also matches Neovim's own help files.

**Keep plugin specs lazy.** Declare `keys` in the lazy.nvim spec rather than mapping inside
`config()`, or the plugin loads at startup regardless. `:Lazy profile` shows the cost.

**Check whether Neovim already does it before adding a plugin.** Commenting (`gc`/`gcc`) and
treesitter folding are built in now. The bottom of `lua/plugins/init.lua` keeps a record of what was
removed and why — add to it rather than deleting the line.

## Spell checking

Two tools with different jobs. Put a word in the right one:

- **typos** (`typos.toml`) — real misspellings in code, everywhere. Runs on commit, in CI, and in
  the editor through `typos-lsp`. `extend-words` is for identifiers that only look wrong.
- **cspell** (`cspell.json`, word list in `.cspell/dotfiles.txt`) — prose and comments, in VS Code.
  Plugin names, option names, jargon.

Neovim's own `zg` writes to `.config/nvim/spell/en.utf-8.add`, which is tracked.
