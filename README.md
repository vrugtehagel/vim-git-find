# VIM Git find

Simple file navigation for git repositories.

The VIM Git find plugin provides dependency-free fuzzy search algorithm within
Git repositories. Find any file, either globally within the repository (as in,
for example, `:GF foo`) or relative to the current file (such as `:GF ./foo`,
`:GF ../../foo`, etcetera). Git-ignored files are ignored by the plugin as
well.

## Installation

This plugin requires the latest version of VIM (at least VIM 9). To install the
plugin, first navigate to your VIM plugins folder:

```bash
cd ~/.vim/pack/plugins/start
```

then clone this repository using

```bash
git clone git@github.com:vrugtehagel/vim-git-find.git
```

And that's it!
