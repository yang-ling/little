#!/usr/bin/env bash

# Safe kill tmux sessions.
echoHeader()
{
    # Blue, underline
    echo -e "\033[0;34;4m${1}\033[0m"
}
echoSection()
{
    echo -e "\033[47;30m${1}\033[0m"
}
echoInfo()
{
    # Green
    echo -e "\033[0;32m${1}\033[0m"
}
echoError()
{
    # Red
    echo -e "\033[0;31m${1}\033[0m"
}

function safe_end_procs {
    old_ifs="$IFS"
    IFS=$'\n'
    if [[ -z "$target_session" ]]; then
        panes=$(tmux list-panes -a -F "#{pane_id} #{pane_current_command} #{session_name}" 2>/dev/null)
    else
        panes=$(tmux list-panes -s -t $target_session -F "#{pane_id} #{pane_current_command} #{session_name}" 2>/dev/null)
    fi
    if [[ $? -eq 0 ]]; then
        is_all_killed="false"
    else
        echoInfo "All killed."
        is_all_killed="true"
    fi
    for pane_set in $panes; do
        pane_id=$(echo "$pane_set" | awk -F " " '{print $1}')
        pane_proc=$(echo "$pane_set" | awk -F " " '{print tolower($2)}')
        session_name=$(echo "$pane_set" | awk -F " " '{print $3}')
        cmd="C-c"
        if [[ "$pane_proc" == "vim" ]]; then
            cmd='":qa" Enter'
        elif [[ "$pane_proc" == "man" ]] || [[ "$pane_proc" == "less" ]] || [[ "$pane_proc" == "newsbeuter" ]]; then
            cmd='"q"'
        elif [[ "$pane_proc" == "bash" ]] || [[ "$pane_proc" == "zsh" ]]; then
            cmd='C-c C-u "exit" Enter'
        elif [[ "$pane_proc" == "ssh" ]]; then
            cmd='Enter "~."'
        fi
        echo $cmd | xargs tmux send-keys -t "$pane_id"
        echoInfo "Kill a pane, id=${pane_id}, proc=${pane_proc}, session name=${session_name}"
    done
    IFS="$old_ifs"
}
usage() {
  echo "usage: $(basename $0) [-t <target_session>] [-c <retry_count>]"
  echo -e "\nOptions:"
  echo -e '\t-t <target_session>\t\tKill target session. All sessions are killed if this argument is not given. You can use tmux ls to check session list'
  echo -e '\t-c <retry_count>\t\tRetry count. Default value is 5'
}

## Main
target_session=""
retry_count=5
while (( "$#" )) ; do
    case "$1" in
        -t)
            shift
            target_session=$1
            [[ -z "$target_session" ]] && { echoError "Please specify target session."; usage; exit 1; }
            shift
            ;;
        -c)
            shift
            retry_count=$1
            [[ -z "$retry_count" ]] && { echoError "Please specify retry count"; usage; exit 1; }
            shift
            ;;
        *)
            usage; exit 0 ;;
    esac
done
echoHeader "Safe kill tmux sessions starting...."
if [[ -z "$target_session" ]]; then
    echo "Kill all sessions"
else
    echo "Kill session ${target_session}"
fi

safe_end_tries=0
is_all_killed="false"
while [ $safe_end_tries -lt $retry_count ]; do
    echoSection "${safe_end_tries} round starting...."
    safe_end_procs
    echoSection "${safe_end_tries} round finish"
    [[ "$is_all_killed" == "true" ]] && { break; }
    safe_end_tries=$[$safe_end_tries+1]
    sleep 0.75
done
if [[ "$is_all_killed" == "true" ]]; then
    echoHeader "Safe kill tmux sessions finished."
else
    echoError "Could not end all processes, you're on your own now!"
fi