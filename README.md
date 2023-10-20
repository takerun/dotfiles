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


#### Optional
* poetryは個別にスクリプト実行する。pythonのバージョンを決めてから。
  ```
  zsh dotfiles/package/poetry/install.sh
  ```


#### TODO
* defaultsコマンドもスクリプトで実行したい。
* 再起動前に`defaults write -g InitialKeyRepeat -int 25`、`defaults write -g KeyRepeat -int 2`を実行したい。
* ClipyのショートカットとVSCodeのショートカットcommand+shift+Bが被る。
* 2023/10時点では、g++環境の「#include <bits/stdc++.h>」とxcode commandlinetoolsの相性が悪く、14.3.1にダウングレードした。
  - https://developer.apple.com/download/all/ から手動でインストールした
  - 加えて、この対応をなぜか必要だった。https://qiita.com/ikoanymg/items/b108e97093b50662673d
