#!/usr/bin/env zsh

_eeveeterm_color() {
    case "$1" in
        normal)   printf '\e[0m'        ;;
        black)    printf '\e[30m'       ;;
        red)      printf '\e[31m'       ;;
        green)    printf '\e[32m'       ;;
        yellow)   printf '\e[33m'       ;;
        blue)     printf '\e[34m'       ;;
        magenta)  printf '\e[35m'       ;;
        cyan)     printf '\e[36m'       ;;
        white)    printf '\e[37m'       ;;
        brblack)  printf '\e[90m'       ;;
        brown)    printf '\e[38;5;130m' ;;
        *)
            local r=$((16#${1:0:2}))
            local g=$((16#${1:2:2}))
            local b=$((16#${1:4:2}))
            printf '\e[38;2;%d;%d;%dm' "$r" "$g" "$b"
            ;;
    esac
}

eeveeterm() {
    # Shiny count is persisted to a plain file because zsh has no
    # equivalent of fish's universal variables (set -U).
    local shiny_count_file=~/.config/eeveeterm/shiny_count

    if [[ "$1" == "--clear-cache" ]]; then
        rm -rf ~/.cache/eeveeterm
        echo "Cache cleared"
        return
    fi

    if [[ "$1" == "--stats" ]]; then
        local count=0
        [[ -f "$shiny_count_file" ]] && count=$(<"$shiny_count_file")
        echo "$(_eeveeterm_color ffdd00)~Shinies~ found: $count$(_eeveeterm_color normal)"
        return
    fi

    if [[ "$1" == "--populate" ]]; then
        local repo="Foox-dev/eeveeterm"
        local base_url="https://raw.githubusercontent.com/$repo/main/the_eevees"
        local dest=~/.config/eeveeterm
        mkdir -p "$dest/shiny"
        echo "Fetching sprites..."
        local name
        for name in eevee vaporeon jolteon flareon espeon umbreon leafeon glaceon sylveon; do
            curl -sL "$base_url/$name.png"       -o "$dest/$name.png"
            curl -sL "$base_url/shiny/$name.png" -o "$dest/shiny/$name.png"
        done
        if [[ ! -s "$dest/eevee.png" ]]; then
            echo "Something went wrong! Check your internet connection and try again."
            return 1
        fi
        echo 'Done! Run "eeveeterm" to test.'
        return
    fi

    local shiny_count=0
    [[ -f "$shiny_count_file" ]] && shiny_count=$(<"$shiny_count_file")

    local sprite_dir=~/.config/eeveeterm
    [[ ! -d "$sprite_dir" ]] && return

    local -a sprites
    sprites=("${(@f)$(find "$sprite_dir" -maxdepth 1 -type f \
        \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.gif" \))}")
    [[ ${#sprites[@]} -eq 0 ]] && return

    local cache_dir=~/.cache/eeveeterm
    mkdir -p "$cache_dir"
    local queue_file="$cache_dir/queue"

    if [[ ! -s "$queue_file" ]]; then
        local -a deck=("${sprites[@]}")
        local i j tmp count=${#deck[@]}
        for (( i = count; i >= 2; i-- )); do
            j=$(( RANDOM % i + 1 ))
            tmp="${deck[$i]}"
            deck[$i]="${deck[$j]}"
            deck[$j]="$tmp"
        done
        printf '%s\n' "${deck[@]}" > "$queue_file"
    fi

    local img
    img=$(head -n1 "$queue_file")
    sed -i'' -e '1d' "$queue_file" # sed -i'' works on GNU and BSD sed

    local name
    name=$(basename "$img" | sed 's/\.[^.]*$//')

    # 1/25 chance of shiny
    local is_shiny=0
    if (( RANDOM % 25 == 0 )); then
        local shiny_img=~/.config/eeveeterm/shiny/$name.png
        if [[ -f "$shiny_img" ]]; then
            img="$shiny_img"
            is_shiny=1
        fi
    fi

    local scaled="$cache_dir/$name.png"
    (( is_shiny )) && scaled="$cache_dir/shiny_$name.png"

    if [[ ! -f "$scaled" ]]; then
        ffmpeg -i "$img" -vf "scale=iw*4:ih*4:flags=neighbor" "$scaled" -y 2>/dev/null
    fi

    if [[ -n "$KITTY_WINDOW_ID" ]]; then
        kitty +kitten icat --align left "$scaled" 2>/dev/null
    elif command -v chafa &>/dev/null; then
        chafa --size 60x12 --align left "$img"
    else
        echo "$(_eeveeterm_color yellow)Please install chafa for image support on non-kitty terminals$(_eeveeterm_color normal)"
    fi

    local color
    case "$name" in
        eevee)    color=brown   ;;
        vaporeon) color=blue    ;;
        jolteon)  color=yellow  ;;
        flareon)  color=red     ;;
        espeon)   color=magenta ;;
        umbreon)  color=yellow  ;;
        leafeon)  color=green   ;;
        glaceon)  color=cyan    ;;
        sylveon)  color=ffafd7  ;;
        *)        color=white   ;;
    esac

    if (( is_shiny )); then
        shiny_count=$(( shiny_count + 1 ))
        echo "$shiny_count" > "$shiny_count_file"
        echo "$(_eeveeterm_color $color)~Shiny~ Welcome back, $USER!$(_eeveeterm_color normal)"
    else
        echo "$(_eeveeterm_color $color)Welcome back, $USER!$(_eeveeterm_color normal)"
    fi
    echo "$(_eeveeterm_color brblack)$(date '+%A, %B %d')$(_eeveeterm_color normal)"
}

if [[ -o interactive ]]; then
    eeveeterm
fi
