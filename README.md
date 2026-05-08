# homebrew-proj

Homebrew tap for `proj`.

## Install

```bash
brew tap khurd21/proj
brew install khurd21/proj/proj
proj --add-path <path-to-your-workplace>
```

## What this tap sets up

- Installs the `proj` binary.
- Installs zsh completion to Homebrew's completion directory.
- Creates a user-editable config file at:

  `$(brew --prefix)/var/proj/config/proj.yaml`

The wrapper script runs `proj` from `$(brew --prefix)/var/proj` so the app finds `config/proj.yaml` without requiring additional shell configuration.
