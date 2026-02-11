### dotfiles

#### Get started

1. Download this repo as zip file.
2. Open standard terminal app, Run the following command.
  ```
  mv Downloads/dotfiles-master ~/dotfiles
  zsh dotfiles/setup.sh
  ```
3. Reboot your computer.
4. Open standard terminal app, Run the following command.
  ```
  defaults read com.googlecode.iterm2
  ```
5. Connect local git project with remote.
  ```
  cd ~/dotfiles
  git init
  git remote add origin https://github.com/takerun/dotfiles.git
  git add .
  git pull origin master
  ```
6. Authenticate github.
  ```
  gh auth login
  ```
7. Run user preforence.
  ```
  defaults write -g InitialKeyRepeat -int 25
  defaults write -g KeyRepeat -int 2
  ```


#### TODO
* ClipyのショートカットとVSCodeのショートカットcommand+shift+Bが被る。
