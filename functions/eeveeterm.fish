function eeveeterm
    if test "$argv[1]" = --clear-cache
        rm -rf ~/.cache/eeveeterm
        echo "Cache cleared"
        return
    end

    if test "$argv[1]" = --stats
        echo (set_color ffdd00)"~Shinies~ found: $shiny_count"(set_color normal)
        return
    end

    if test "$argv[1]" = --populate
        set repo Foox-dev/eeveeterm
        set base_url "https://raw.githubusercontent.com/$repo/main/the_eevees"
        set dest ~/.config/eeveeterm
        mkdir -p $dest/shiny

        echo "Fetching sprites..."
        for name in eevee vaporeon jolteon flareon espeon umbreon leafeon glaceon sylveon
            curl -sL "$base_url/$name.png" -o "$dest/$name.png"
            curl -sL "$base_url/shiny/$name.png" -o "$dest/shiny/$name.png"
        end

        if not test -s "$dest/eevee.png"
            echo "Something went wrong! Check your internet connection and try again."
            return 1
        end

        echo "Done! Run "eeveeterm" to test."
        return
    end

    if not set -q shiny_count
        set -U shiny_count 0
    end

    set sprite_dir ~/.config/eeveeterm
    if not test -d $sprite_dir
        return
    end
    set sprites (find $sprite_dir -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.gif" \))
    if test (count $sprites) -eq 0
        return
    end

    set cache_dir ~/.cache/eeveeterm
    mkdir -p $cache_dir
    set queue_file $cache_dir/queue

    # Rebuild queue if empty or missing
    if not test -s $queue_file
        set deck $sprites
        set count (count $deck)
        for i in (seq $count -1 2)
            set j (math (random) % $i + 1)
            set tmp $deck[$i]
            set deck[$i] $deck[$j]
            set deck[$j] $tmp
        end
        printf "%s\n" $deck >$queue_file
    end

    # Pop first entry from queue
    set img (head -n1 $queue_file)
    sed -i 1d $queue_file
    set name (basename $img | sed 's/\.[^.]*$//')

    # 1/25 chance of shiny
    set is_shiny 0
    if test (math (random) % 25) -eq 0
        set shiny_img ~/.config/eeveeterm/shiny/$name.png
        if test -f $shiny_img
            set img $shiny_img
            set is_shiny 1
        end
    end

    set scaled "$cache_dir/$name.png"
    if test $is_shiny -eq 1
        set scaled "$cache_dir/shiny_$name.png"
    end

    if not test -f $scaled
        ffmpeg -i $img -vf "scale=iw*4:ih*4:flags=neighbor" $scaled -y 2>/dev/null
    end

    if set -q KITTY_WINDOW_ID
        kitty +kitten icat --align left $scaled 2>/dev/null
    else if command -q chafa
        chafa --size 60x12 --align left $img
    else
        echo (set_color yellow)"Please install chafa for image support on non-kitty terminals"(set_color normal)
    end

    # Greeting colors
    set color (switch $name
        case eevee;    echo brown
        case vaporeon; echo blue
        case jolteon;  echo yellow
        case flareon;  echo red
        case espeon;   echo magenta
        case umbreon;  echo yellow
        case leafeon;  echo green
        case glaceon;  echo cyan
        case sylveon;  echo ffafd7
    end)

    if test $is_shiny -eq 1
        set -U shiny_count (math $shiny_count + 1)
        echo (set_color $color)"~Shiny~ Welcome back, $USER!"(set_color normal)
    else
        echo (set_color $color)"Welcome back, $USER!"(set_color normal)
    end
    echo (set_color brblack)(date '+%A, %B %d')(set_color normal)
end
