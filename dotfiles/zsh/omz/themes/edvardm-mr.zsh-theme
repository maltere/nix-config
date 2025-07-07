local user='%{$fg_bold[white]%}%n'

prompt_user() {
    if [ $UID -eq 0 ]; then
        echo "%{$fg_bold[red]%}%n"
    else
        echo "%{$fg_bold[white]%}%n"
    fi
}

PROMPT='$(prompt_user) %{$reset_color%}%{$fg[white]%}@%m%{$fg_bold[red]%} ➜ %{$fg_bold[green]%} %{$fg_bold[white]%}%~ %{$fg_bold[blue]%}$(git_prompt_info)%{$fg_bold[blue]%} % %{$reset_color%}'

ZSH_THEME_GIT_PROMPT_PREFIX="git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"

