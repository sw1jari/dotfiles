# Default programs
export EDITOR="nvim"
export TERMINAL="st"
export BROWSER="firefox"
export READER="zathura"

# Fix grey screen in Java applications
export _JAVA_AWT_WM_NONREPARENTING=1

# Path
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH":"$HOME/.pub-cache/bin"
export PATH="$PATH:$HOME/matlab/bin"

# Start Xorg server
[ "$(tty)" = "/dev/tty1" ] && ! pidof Xorg >/dev/null 2>&1  && exec startx



# Added by Antigravity CLI installer
export PATH="/home/sw1/.local/bin:$PATH"
