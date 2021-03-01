```
# Uninstall latest broken icu4c https://bugs.php.net/bug.php?id=80310
brew uninstall icu4c --ignore-dependencies

# ensure this tap is up to date
brew tap ampersandhq/php # 

# install this fixed version of icu4c
brew install --formula $(brew --prefix)/Homebrew/Library/Taps/ampersandhq/homebrew-php/Formula/icu4c.rb 

# Pin icu4c to this version
brew pin icu4c
```