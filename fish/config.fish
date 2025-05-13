
alias wp="which python"
alias zed="open -a /Applications/Zed.app -n"
set -U fish_user_paths /usr/local/bin $fish_user_paths
set -U fish_user_paths $fish_user_paths /Users/brankozivanovic/.cargo/bin

set -Ux PYENV_ROOT $HOME/.pyenv
set -Ux PATH $PYENV_ROOT/bin $PATH

status --is-interactive; and pyenv init - | source

set -x SHELL "fish"

if test -f ~/.config/fish/secrets.fish
    source ~/.config/fish/secrets.fish
end

set fish_greeting ""

fzf --fish | source

