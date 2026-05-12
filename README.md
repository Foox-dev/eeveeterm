# eeveeterm

<img width="840" height="291" alt="eevee" src="https://github.com/user-attachments/assets/e4186327-2fa9-4c7e-802b-d71d15649067" />

---

A shell greeter that displays a random Eeveelution sprite on every new terminal session (with a chance of a shiny!)

## Install Requirements

- [ffmpeg](https://ffmpeg.org/): for image scaling
- [kitty](https://github.com/kovidgoyal/kitty): for best experience (pixel-perfect rendering). However, any terminal with pixel-perfect rendering should work.
- [chafa](https://github.com/hpjansson/chafa): for compatibility with other terminals (Alacritty, WezTerm, etc).

## Install

Fish (Recommended)
```fish
fisher install Foox-dev/eeveeterm
eeveeterm --populate
```

Zsh
```zsh
# Add to ~/.zshrc:
zinit light Foox-dev/eeveeterm

# Reload your shell then run:
eeveeterm --populate
```

## Usage

eeveeterm runs automatically on every new terminal session. It can also be called manually:

```fish
eeveeterm # display an eevee
eeveeterm --populate # download sprites to ~/.config/eeveeterm/
eeveeterm --stats # shows how many shinies you've found
eeveeterm --clear-cache # clears the image cache (doesn't clear ~/.config/eeveeterm/)
```

## Notes

- Sprites are stored in `~/.config/eeveeterm/` and fetched from this repo via `--populate`
- Shiny variants live in `~/.config/eeveeterm/shiny/` and have a 1/25 chance of appearing
- Best experienced in kitty. Chafa rendering is supported but the quality may be heavily degraded

## Something Something Enjoy

Have fun with eeveeterm!
