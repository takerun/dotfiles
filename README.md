### dotfiles

#### Get started

1. Download this repo as zip file.
2. Open standard terminal app, Run the following command.
  ```
  mv Downloads/dotfiles-master ~/dotfiles
  zsh dotfiles/setup.sh
  ```
3. Connect local git project with remote.
  ```
  cd ~/dotfiles
  git init
  git remote add origin https://github.com/takerun/dotfiles.git
  git add .
  git pull origin master
  ```
4. Run Colima on system startup.
  ```
  brew services start colima
  ```
5. Authenticate github.
  ```
  gh auth login
  ```
6. Setup Ghostty hotkey
  - Allow Ghostty in System Settings > Privacy & Security > Accessibility.
  - Allow Ghostty in System Settings > Privacy & Security > Input Monitoring. 
7. Run user preference.
  ```
  defaults write -g InitialKeyRepeat -int 25
  defaults write -g KeyRepeat -int 2
  defaults write com.apple.finder AppleShowAllFiles -boolean true
  ```
8. Setup user preference.
  - Go to System Settings > Accessibility > Motion and turn on "Reduce motion".


#### TODO
* ClipyのショートカットとVSCodeのショートカットcommand+shift+Bが被る。
