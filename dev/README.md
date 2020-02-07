When developing these formulae locally it is often best to be able to install them without committing.

The below will symlink the tap to a checkout of this repo

```
rm -rf /usr/local/Homebrew/Library/Taps/ampersandhq/homebrew-php
git clone https://github.com/ampersandHQ/homebrew-php ~/src/homebrew-php
ln -s ~/src/homebrew-php /usr/local/Homebrew/Library/Taps/ampersandhq/homebrew-php
```

Then as you modify files you can run commands like this to use your uncommitted files

```
~/src/homebrew-php/dev/brew.sh install amp-php@7.4 -vvv
```
