When developing these formulae locally it is often best to be able to install them without committing.

The below will symlink the tap to a checkout of this repo

```
rm -rf $(brew --prefix)/Library/Taps/ampersandhq/homebrew-php
git clone https://github.com/ampersandHQ/homebrew-php ~/src/homebrew-php
ln -s ~/src/homebrew-php $(brew --prefix)/Library/Taps/ampersandhq/homebrew-php
```

Then as you modify files you can run commands like this to use your uncommitted files

```
~/src/homebrew-php/dev/brew.sh install amp-php@7.4 -vvv
```

# Debugging

If a formula has started to fail its possibly caused by a dependency on another brew forumla.

https://github.com/henkrehorst/homebrew-php are the formulae used for https://github.com/weprovide/valet-plus so maybe see if they've encountered a similar issue there.
