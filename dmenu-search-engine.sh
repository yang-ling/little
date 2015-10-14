#!/usr/bin/bash

[[ -f $HOME/.dmenurc ]] && { . $HOME/.dmenurc;  }

[[ -n "$DMENU" ]] || { DMENU='dmenu -nb #000000 -nf #ECDDA6 -sb #000000 -sf #b23308 -fn Ubuntu-16:bold -i'; }

SEARCH_ENGINE="ciba
google"

result=$(echo -e "$SEARCH_ENGINE" | rofi -dmenu -p "Choose search engine:")

selected_engine="${result%% *}"
[[ -z "$selected_engine" ]] && { echo "No search engine. Exit."; exit 0; }

result=$(echo "" | rofi -dmenu -p "Input search content:" $*)

search_content="${result%% *}"

[[ -z "$search_content" ]] && { echo "No search content. Exit."; exit 0; }

case "$selected_engine" in
    ciba)
        xdg-open "http://www.iciba.com/$search_content";;
    google)
        xdg-open "http://www.google.com/search?q=$search_content";;
    *)
        xdg-open "http://www.google.com/search?q=$search_content";;
esac
