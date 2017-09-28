#!/usr/bin/env bash

#Check if the agent is running
ps -ef | grep -v grep | grep "ssh-agent -s"
agent_running=$?

tempfile=/tmp/ssh-agent.test

#Check for an existing ssh-agent
if [ -e $tempfile ] && [ $agent_running -eq 0 ]
then
    echo "Examining old ssh-agent"
    . $tempfile
else
    if [ $agent_running -eq 0 ]
    then
        echo "Old ssh-agent is invalid. Killing it..."
        ssh-agent -k
    fi
    echo "Old ssh-agent is dead..creating new agent."
    #Create a new ssh-agent if needed
    rm -rf $tempfile
    ssh-agent -s > $tempfile
    . $tempfile
fi
