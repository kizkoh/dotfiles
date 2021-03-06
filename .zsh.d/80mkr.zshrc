#!/bin/zsh

alias mkr=${HOME}/.go/bin/mkr

autoload -U modify-current-argument
autoload -U split-shell-arguments

complete-mackerel-host () {
    local mode_append_only=0
    local REPLY
    local reply

    local filter="sk"

    split-shell-arguments
    if [ $(($REPLY % 2)) -eq 0 ]; then
        # query by word under cursor
        query_arg="--query=$reply[$REPLY]"
    elif [ -n "${LBUFFER##* }" ]; then
        # query by word jsut before cursor
        query_arg="--query=${LBUFFER##* }"
    else
        # no word detected
        query_arg='--query='
        mode_append_only=1
    fi

    res=$(mkr-hosts-tsv | eval $filter "$query_arg")
    if [ -z "$res" ]; then
        zle reset-prompt
        return 1
    fi

    ip=$(echo "$res" | cut -f1)
    host=$(echo "$res" | cut -f2)

    if [ $mode_append_only = 1 ]; then
        LBUFFER+="$host"
    else
        modify-current-argument "$host"
    fi

    BUFFER+=" # $ip"

    zle reset-prompt
}
zle -N complete-mackerel-host
bindkey '^X^M' complete-mackerel-host
