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
killMoc() {
    ps -ef | grep -v grep | grep mocp
    if [[ $? -eq 0 ]]; then
        mocp -x
        echoInfo "MOC is killed"
    else
        echoInfo "MOC is not running"
    fi
}
getPanesNumber() {
    old_ifs="$IFS"
    IFS=$'\n'
    panes=$(tmux list-panes -a -F "#{pane_id} #{pane_current_command} #{session_name}" 2>/dev/null)
    _panes_number=0
    if [[ $? -eq 0 ]]; then
        for pane_set in $panes; do
            _panes_number=$(( _panes_number+1 ))
        done
    fi
    IFS="$old_ifs"
}

safe_end_procs() {

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
        elif [[ "$pane_proc" == "mocp" ]]; then
            cmd='"Q"'
        elif [[ "$pane_proc" == "bash" ]] || [[ "$pane_proc" == "zsh" ]] || [[ "$pane_proc" == "adb" ]]; then
            cmd='C-c C-u "exit" Enter'
        elif [[ "$pane_proc" == "ssh" ]]; then
            cmd='Enter "~."'
        elif [[ "$pane_proc" == "python" ]]; then
            # This is for ranger
            cmd='"q"'
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

mainLoop() {
    while [ $safe_end_tries -lt $retry_count ]; do
        echoSection "${actual_tries} round starting...."
        getPanesNumber
        prev_panes_number=$_panes_number
        echo "Previous panes number is $prev_panes_number"

        safe_end_procs

        sleep 0.75
        getPanesNumber
        curr_panes_number=$_panes_number
        echo "Current panes number is $curr_panes_number"
        [[ "$is_all_killed" == "true" ]] && { break; }
        if [[ ! $prev_panes_number -gt $curr_panes_number ]]; then
            safe_end_tries=$[$safe_end_tries+1]
            echoError "Panes are not reduced, $(( retry_count-safe_end_tries )) tries remaining"
        else
            safe_end_tries=0
        fi
        actual_tries=$(( actual_tries+1 ))
        echoSection "${actual_tries} round finish"
    done
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
actual_tries=1
is_all_killed="false"
prev_panes_number=0
curr_panes_number=0
_panes_number=0

mainLoop

if [[ "$is_all_killed" == "true" ]]; then
    echoHeader "Safe kill tmux sessions finished."
    echoHeader "Try to kill MOC..."
    killMoc
    echoHeader "MOC killing job done."
else
    echoError "Could not end all processes, you're on your own now!"
fi
