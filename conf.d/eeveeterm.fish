if status is-interactive
    if not test -d ~/.config/eeveeterm
        echo "Warning! ~/.config/eeveeterm/ is not populated. Run \"eeveeterm --populate\" to get started!"
        return
    end
    eeveeterm
end
