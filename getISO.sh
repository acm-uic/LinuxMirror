#!/usr/bin/env bash

fil="sources.txt"

size=0

default_pull(){
    local pullLine="$1"
    local directory="${2:-other}"
    html=$(curl -L -s "$pullLine")

    find "./website/downloads/$directory"/"$toDownLoad" -type f -mtime +13 -delete

    
    
    while IFS= read -r htmlLine; do
        if [[ "$htmlLine" == *"<a"* ]]; then
            toDownLoad=$(echo "$htmlLine" | awk -F 'href="' '{if (NF>1) {split($2, a, "\""); print a[1]}}')
            length=${#toDownLoad}
            if [[ length -ge 6 ]]; then
                #contentLength=$(curl -I -s "$pullLine/$toDownLoad" | awk 'BEGIN { IGNORECASE=1 } /^Content-Length:/ {gsub("\r", "", $2); print $2}')
                #size=$((size + contentLength))
                #echo "$size"
                curl --create-dirs -L -s "$pullLine"/"$toDownLoad" -o "./temporary/$directory"/"$toDownLoad"
                mkdir -p "./website/downloads/$directory"
                mv "./temporary/$directory"/"$toDownLoad" "./website/downloads/$directory"/"$toDownLoad"
                
            fi
        fi
    done <<< "$html"

}

echo "pulling the following:"

first=1

while IFS= read -r line; do
    case "$line" in 
        *"ubuntu"*)
            echo "ubuntu"
            htmlS=$(curl -L -s "$line")
            
            rows=""

            while IFS= read -r part; do
                seperate=$(echo "$part" | awk -F 'href="' '{if (NF>1) {split($2, a, "\""); print a[1]}}')
                if [[  "$seperate" =~ [0-9]+ ]]; then

                    if [[ $first == 1 ]]; then
                        rows="$seperate"
                        first=0
                    else
                        rows+=$'\n'"$seperate"
                    fi
                    

                fi
            done <<< "$htmlS"


            sorted=$(echo "$rows" | sort -r | xargs)

            read -ra latest_Line <<< "$sorted"

            echo "$line""${latest_Line[0]}"
           
            default_pull "$line"'/'"${latest_Line[0]}" "Ubuntu"
            
            ;;
        *"void"*)
            echo "void"
            default_pull "$line" "Void"
            ;;
        *"arch"*)
            echo "arch"
            default_pull "$line" "Arch"
            ;;
        *"debian"*)
            echo "debian Cinnamon"
            default_pull "$line" "Cinnamon"
            ;;
        *"kali"*)
            echo "kali"
            default_pull "$line" "Kali"
            ;;
        *"alpine"*)
            echo "alpine"
            default_pull "$line" "Alpine"
            ;;
        *)
            default_pull "$line" "Misc"
            ;;
    esac
done < "$fil"

echo $size