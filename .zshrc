# sw1's Zoomer Shell config

# Prompt
autoload -U colors && colors
git_branch() {
	git symbolic-ref --short HEAD 2> /dev/null
}
precmd() {
	RPROMPT="%B%{$fg[green]%}$(git_branch)%b"
}
setopt prompt_subst
PROMPT="%B%{$fg[cyan]%}[%{$fg[white]%}%n%{$fg[cyan]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[cyan]%}]%{$reset_color%}$%b "

# Save history in cache
HISTFILE=~/.cache/zsh/histfile
HISTSIZE=10000
SAVEHIST=10000
setopt INC_APPEND_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE

# Keep credentials out of history: skip commands that look like they contain a secret
zshaddhistory() {
	local cmd=${(L)1}
	local -a patterns=(
		'(token|secret|passw(or)?d|api[_-]?key|access[_-]?key|auth)[a-z0-9_]*='
		'--?(password|passwd|token|secret)[= ]'
		'authorization:'
		'bearer +[a-z0-9._~+/=-]{10,}'
		'(ghp|gho|ghs|ghu)_[a-z0-9]{20,}|github_pat_|glpat-|xox[baprs]-'
		'sk-[a-z0-9_-]{20,}|hf_[a-z0-9]{20,}|akia[0-9a-z]{16}'
		'://[^/ @]+:[^/ @]+@'
		'-----begin [a-z ]*private key'
	)
	local p
	for p in $patterns; do
		[[ $cmd =~ $p ]] && return 1
	done
	return 0
}

alias sudo=doas
alias pdf="devour zathura"
alias nano=nvim

export CHROME_EXECUTABLE=/bin/chromium
export MOZ_DBUS_REMOTE=1

# Path (entries shared with .zprofile are inherited via login shell; these are terminal-only additions)
export PATH="$PATH:$HOME/.local/share/gem/ruby/3.0.0/bin"
export PATH="$PATH:$HOME/fvm/default/bin"

# Vi mode
bindkey -v
KEYTIMEOUT=5

# Tab complete - only regenerate dump if older than 24h
autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
	compinit
else
	compinit -C
fi
zstyle ':completion:*' menu select
zmodload zsh/complist
_comp_options+=(globdots)

# Use vim keys in tab complete menu
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# Change cursor shape for different vi modes
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'
  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins
    echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q'
preexec() { echo -ne '\e[5 q' ;}

ZSH_AUTOSUGGEST_HISTORY_IGNORE="*(token|secret|passw|api_key|apikey)*"
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null
# Load zsh-syntax-highlighting; should be last
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null

# >>> mamba initialize >>>
# !! Contents within this block are managed by 'micromamba shell init' !!
export MAMBA_EXE='/usr/bin/micromamba';
export MAMBA_ROOT_PREFIX='/home/sw1/.local/share/mamba';
__mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__mamba_setup"
else
    alias micromamba="$MAMBA_EXE"
fi
unset __mamba_setup
# <<< mamba initialize <<<

## [Completion]
## Completion scripts setup. Remove the following line to uninstall
[[ -f /home/sw1/.dart-cli-completion/zsh-config.zsh ]] && . /home/sw1/.dart-cli-completion/zsh-config.zsh || true
## [/Completion]

# >>> juliaup initialize >>>
# !! Contents within this block are managed by juliaup !!
path=('/home/sw1/.juliaup/bin' $path)
export PATH
# <<< juliaup initialize <<<

# conda - lazy-loaded to avoid ~330ms subprocess cost on every shell start
conda() {
    unfunction conda
    __conda_setup="$('/usr/bin/conda' 'shell.zsh' 'hook' 2>/dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    elif [ -f "/usr/etc/profile.d/conda.sh" ]; then
        . "/usr/etc/profile.d/conda.sh"
    else
        export PATH="/usr/bin:$PATH"
    fi
    unset __conda_setup
    conda "$@"
}


# Added by Antigravity CLI installer
export PATH="/home/sw1/.local/bin:$PATH"

# start Claude Code in its own folder, so the trust prompt only shows once
alias c='cd ~/claude && claude'
