zplug 'zplug/zplug', hook-build:'zplug --self-manage'
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-history-substring-search"
zplug "zsh-users/zsh-syntax-highlighting"

# To insert emoji, type ctrl-s. Dependencies: jq fzf peco
zplug "b4b4r07/emoji-cli"

#zplug "arzzen/calc.plugin.zsh"
#zplug "b4b4r07/enhancd"
#zplug "djui/alias-tips"
#zplug "hchbaw/auto-fu.zsh", at:pu
#zplug "hkupty/ssh-agent"
#zplug "jimmijj/zsh-syntax-highlighting"
#zplug "joshuarubin/zsh-homebrew"
#zplug "jreese/zsh-titles"
#zplug "lukechilds/zsh-nvm"
zplug "modules/environment", from:prezto
zplug "modules/terminal", from:prezto
zplug "modules/tmux", from:prezto
zplug "modules/editor", from:prezto
zplug "modules/history", from:prezto
zplug "modules/directory", from:prezto
zplug "modules/spectrum", from:prezto
zplug "modules/utility", from:prezto
zplug "modules/completion", from:prezto
zplug "modules/git", from:prezto
zplug "modules/gpg", from:prezto
zplug "modules/node", from:prezto
zplug "modules/homebrew", from:prezto
zplug "modules/osx", from:prezto
zplug "modules/prompt", from:prezto
#zplug "modules/ruby", from:prezto
#zplug "mollifier/anyframe"
#zplug "mollifier/cd-gitroot"
#zplug "mrowa44/emojify", as:command, of:emojify
#zplug "olivierverdier/zsh-git-prompt", of:"*.sh"
#zplug "psprint/history-search-multi-word"
#zplug "psprint/zsh-select"
#zplug "rimraf/k"
#zplug "rupa/z", of:"*.sh"
#zplug "stedolan/jq", from:gh-r, as:command, rename-to:jq
#zplug "zsh-users/zaw"

# Color output
zstyle ':prezto:*:*' color 'yes'

# Set the key mapping style to 'emacs' or 'vi'.
zstyle ':prezto:module:editor' key-bindings 'vi'

# Theme
zplug "jbsilva/prompt_jbs", use:prompt_jbs_setup, from:github, as:theme
zstyle ':prezto:module:prompt' theme 'sorin'
