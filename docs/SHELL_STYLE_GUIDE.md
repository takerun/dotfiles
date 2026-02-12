# Zsh Script Style Guide for dotfiles

このドキュメントは、dotfiles内のZshスクリプトのコーディング規約を定義します。Google Shell Style GuideとZshベストプラクティスに基づいています。

## 目次

1. [基本方針](#1-基本方針)
2. [エラーハンドリング](#2-エラーハンドリング)
3. [変数展開とクォーテーション](#3-変数展開とクォーテーション)
4. [変数・定数定義](#4-変数定数定義)
5. [関数定義](#5-関数定義)
6. [パフォーマンス最適化](#6-パフォーマンス最適化)
7. [条件分岐とテスト](#7-条件分岐とテスト)
8. [フォーマット規則](#8-フォーマット規則)
9. [具体例集](#9-具体例集)
10. [チェックリスト](#10-チェックリスト)

---

## 1. 基本方針

### 1.1 シェルの選択

すべてのスクリプトで**Zsh**を使用します。

```bash
#!/bin/zsh
```

**理由**: macOSのデフォルトシェルはZshであり、このdotfilesプロジェクトはmacOS専用です。

### 1.2 適用範囲

- **対象**: 100行未満のユーティリティスクリプト、設定ファイル
- **対象外**: 大規模なアプリケーション（この場合は別の言語を検討）

### 1.3 コメント言語

日本語・英語の混在を許可します。プロジェクトの実情に合わせて使い分けてください。

---

## 2. エラーハンドリング

### 2.1 実行可能スクリプト

すべての実行可能スクリプト（.sh拡張子）で、**`set -eu`** を使用します。

```bash
#!/bin/zsh
set -eu
```

**意味**:
- `-e`: コマンドが0以外の終了ステータスで終了した場合、スクリプトを即座に終了
- `-u`: 未定義変数を参照した場合、エラーとして扱う

**注意**: `set -ue`ではなく`set -eu`の順序で統一してください（慣習的に`-eu`が標準）。

### 2.2 設定ファイル（.zshrc等）

対話型シェルの設定ファイルでは、**エラーハンドリングを設定しない**でください。

**理由**: `.zshrc`などの設定ファイルで`set -e`を使用すると、一部のコマンドが失敗しただけでシェル全体が終了してしまいます。

### 2.3 パイプライン

重要なパイプラインでは、`set -o pipefail`の使用を検討してください。

```bash
set -eu
set -o pipefail  # パイプラインのいずれかが失敗した場合、全体が失敗

cat file.txt | grep "pattern" | sort
```

### 2.4 エラーメッセージ

エラーメッセージは**標準エラー出力**に出力します。

```bash
echo "Error: File not found" >&2
```

---

## 3. 変数展開とクォーテーション

### 3.1 基本原則

**常に `"${var}"` 形式を使用**してください。

```bash
# 良い例
echo "Home directory: ${HOME}"
ln -sf "${file}" "${HOME}/"

# 悪い例
echo "Home directory: $HOME"
ln -sf $file $HOME/
```

**理由**: 変数にスペースや特殊文字が含まれている場合、クォートがないとワードスプリッティング（単語分割）が発生し、意図しない動作やセキュリティ脆弱性の原因となります。

### 3.2 例外

以下の場合のみ、裸の変数（クォートなし）を許可します：

#### 代入の右辺

```bash
# 許可
export PATH=$HOME/bin:$PATH
current_dir=$PWD
```

#### `[[ ]]` 内での単純な変数テスト

```bash
# 許可（Zshの[[ ]]内では自動的にクォートされる）
if [[ -z $var ]]; then
  echo "Variable is empty"
fi

# ただし、推奨は常にクォート
if [[ -z "${var}" ]]; then
  echo "Variable is empty"
fi
```

#### 算術式内

```bash
# 許可
count=$((count + 1))
```

### 3.3 コマンド置換

**`$(command)` 形式を使用**し、バッククォート `` `command` `` は禁止します。

```bash
# 良い例
current_dir=$(pwd)
brew_prefix="$(brew --prefix)"

# 悪い例
current_dir=`pwd`
```

**理由**: `$()`の方が読みやすく、ネストも簡単です。

### 3.4 関数引数

**`"$@"` を使用**し、`$*` は禁止します。

```bash
# 良い例
my_function() {
  echo "Arguments: $@"
  another_command "$@"
}

# 悪い例
my_function() {
  another_command $*  # スペースを含む引数が分割される
}
```

### 3.5 配列要素の展開

```bash
# 良い例
files=("file1.txt" "file 2.txt" "file3.txt")
for f in "${files[@]}"; do
  echo "${f}"
done

# 悪い例
for f in ${files[@]}; do
  echo $f
done
```

---

## 4. 変数・定数定義

### 4.1 命名規則

#### ローカル変数

小文字 + アンダースコア

```bash
current_dir="/path/to/dir"
file_name="example.txt"
```

#### 環境変数・定数

大文字 + アンダースコア

```bash
export CARGO_HOME="${HOME}/.cargo"
export PATH="${CARGO_HOME}/bin:${PATH}"

readonly BOLD_GREEN='\033[1;32m'
readonly MAX_RETRIES=3
```

### 4.2 定数宣言

定数は `readonly` または `declare -r` を使用して宣言します。

```bash
# 良い例
readonly SCRIPT_DIR="$(cd "$(dirname "$0")"; pwd)"
declare -r MAX_ATTEMPTS=5

# 悪い例（定数が変更可能）
SCRIPT_DIR="$(cd "$(dirname "$0")"; pwd)"
```

### 4.3 エクスポート

環境変数は**明示的に `export` を使用**してください。

```bash
# 良い例
export BOLD_GREEN='\033[1;32m'
export CARGO_HOME="${HOME}/.cargo"

# 悪い例（サブシェルから参照できない）
BOLD_GREEN='\033[1;32m'
```

### 4.4 スコープ

関数内の変数は `local` を使用してスコープを限定します。

```bash
# 良い例
my_function() {
  local temp_file="/tmp/myfile.txt"
  echo "Using ${temp_file}"
}

# 悪い例（グローバル変数を汚染）
my_function() {
  temp_file="/tmp/myfile.txt"
  echo "Using ${temp_file}"
}
```

---

## 5. 関数定義

### 5.1 命名規則

関数名は**小文字 + アンダースコア**を使用します。

```bash
# 良い例
add_newline() {
  printf '\n'
}

install_package() {
  brew install "$1"
}

# 悪い例
addNewline() {
  printf '\n'
}
```

### 5.2 関数の配置

関数は**ファイル上部**（定数宣言の後）に配置します。

```bash
#!/bin/zsh
set -eu

# 定数
readonly SCRIPT_DIR="$(cd "$(dirname "$0")"; pwd)"

# 関数
install_package() {
  local package_name="$1"
  brew install "${package_name}"
}

# メイン処理
install_package "vim"
```

### 5.3 ローカル変数

関数内の変数は必ず `local` を使用します。

```bash
calculate_sum() {
  local a=$1
  local b=$2
  local sum=$((a + b))
  echo "${sum}"
}
```

---

## 6. パフォーマンス最適化

### 6.1 重複コマンド実行の回避

遅いコマンド（特に `brew --prefix`）を複数回実行する場合は、**結果を変数にキャッシュ**してください。

```bash
# 悪い例（brew --prefixを6回実行）
source $(brew --prefix)/etc/bash_completion.d/git-prompt.sh
FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# 良い例（1回のみ実行）
if type brew &>/dev/null; then
  readonly BREW_PREFIX="$(brew --prefix)"
  source "${BREW_PREFIX}/etc/bash_completion.d/git-prompt.sh"
  FPATH="${BREW_PREFIX}/share/zsh/site-functions:${FPATH}"
  FPATH="${BREW_PREFIX}/share/zsh-completions:${FPATH}"
  source "${BREW_PREFIX}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi
```

**効果**: `.zshrc` の読み込み時間が約0.5〜1秒短縮されます。

### 6.2 条件分岐の最適化

頻繁に実行されるコマンドは、条件分岐で存在チェックを行います。

```bash
# 良い例
if type brew &>/dev/null; then
  eval "$(brew shellenv)"
fi

# 悪い例（brewがない場合にエラー）
eval "$(brew shellenv)"
```

---

## 7. 条件分岐とテスト

### 7.1 Zsh形式のテスト

**`[[ ]]` を使用**し、`[ ]` は禁止します。

```bash
# 良い例（Zsh形式）
if [[ -f "${file}" ]]; then
  echo "File exists"
fi

if [[ -z "${var}" ]]; then
  echo "Variable is empty"
fi

# 悪い例（Bash互換形式）
if [ -f "${file}" ]; then
  echo "File exists"
fi
```

**理由**: `[[ ]]` はZshの組み込みで、より強力で安全です（自動的にクォートされる、パターンマッチングが可能など）。

### 7.2 算術演算

**`(( ))` を使用**し、`let` や `expr` は禁止します。

```bash
# 良い例
count=0
((count++))
if ((count > 5)); then
  echo "Count is greater than 5"
fi

# 悪い例
let count=count+1
if [ $count -gt 5 ]; then
  echo "Count is greater than 5"
fi
```

### 7.3 論理演算

```bash
# AND
if [[ -f "${file}" && -r "${file}" ]]; then
  echo "File exists and is readable"
fi

# OR
if [[ "${var}" == "value1" || "${var}" == "value2" ]]; then
  echo "Variable matches"
fi

# NOT
if [[ ! -d "${dir}" ]]; then
  echo "Directory does not exist"
fi
```

---

## 8. フォーマット規則

### 8.1 インデント

**2スペース**を使用し、タブは禁止します。

```bash
if [[ -f "${file}" ]]; then
  while read -r line; do
    echo "${line}"
  done < "${file}"
fi
```

### 8.2 行の長さ

特に制限はありませんが、**可読性を優先**してください。長い行は適切に改行します。

```bash
# 許容
brew bundle cleanup -v --file="${CURRENT_DIR}/Brewfile" --force

# より良い（長い場合）
brew bundle cleanup \
  -v \
  --file="${CURRENT_DIR}/Brewfile" \
  --force
```

### 8.3 セクションコメント

セクションを区切る場合は、以下の形式を使用します。

```bash
# --- Section Name ---
# Description of this section

# Code here
```

---

## 9. 具体例集

### 例1: ファイル存在チェックとコピー

```bash
# 悪い例
if [ -f $file ]; then
  cp $file $destination
fi

# 良い例
if [[ -f "${file}" ]]; then
  cp "${file}" "${destination}"
fi
```

**問題点**:
- `[ ]` ではなく `[[ ]]` を使用すべき
- 変数がクォートされていない（スペースを含むファイル名で失敗）

---

### 例2: tgz関数（空白を含むファイル名対応）

```bash
# 悪い例
tgz() {
  tar zcvf $1 ${@:2}
}

# 良い例
tgz() {
  local archive_name="$1"
  shift
  env COPYFILE_DISABLE=1 tar zcvf "${archive_name}" --exclude=".DS_Store" "$@"
}
```

**問題点**:
- `$1` がアンクォート（`file with spaces.tar.gz` が3つの引数に分割される）
- `${@:2}` がアンクォート（スペースを含むファイル名が分割される）

**修正**:
- `"$1"` と `"$@"` を使用
- より明確にするため、`local`変数を使用

---

### 例3: brew --prefix のキャッシュ化

```bash
# 悪い例（.zshrcで6回実行）
source $(brew --prefix)/etc/bash_completion.d/git-prompt.sh
FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
chmod -R 755 $(brew --prefix)/share
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# 良い例（1回のみ実行）
if type brew &>/dev/null; then
  readonly BREW_PREFIX="$(brew --prefix)"
  source "${BREW_PREFIX}/etc/bash_completion.d/git-prompt.sh"
  FPATH="${BREW_PREFIX}/share/zsh/site-functions:${FPATH}"
  FPATH="${BREW_PREFIX}/share/zsh-completions:${FPATH}"
  chmod -R 755 "${BREW_PREFIX}/share"
  source "${BREW_PREFIX}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi
```

**効果**: `.zshrc` の読み込み時間が約0.5〜1秒短縮

---

### 例4: 変数展開の統一

```bash
# 悪い例（混在）
export NVM_DIR=$HOME/.nvm
export CARGO_HOME="$HOME/.cargo"
export PATH="$CARGO_HOME/bin:$PATH"

# 良い例（統一）
export NVM_DIR="${HOME}/.nvm"
export CARGO_HOME="${HOME}/.cargo"
export PATH="${CARGO_HOME}/bin:${PATH}"
```

**理由**: すべて `"${var}"` 形式に統一することで、可読性と一貫性が向上します。

---

### 例5: エラーハンドリング

```bash
# 悪い例（set -ue）
#!/bin/zsh
set -ue

# 良い例（set -eu）
#!/bin/zsh
set -eu
```

**理由**: `-eu` の順序が慣習的に標準です。

---

### 例6: ループでのファイル処理

```bash
# 悪い例
for f in $(find . -name "*.txt"); do
  cat $f
done

# 良い例
find . -name "*.txt" -print0 | while IFS= read -r -d '' f; do
  cat "${f}"
done

# または（シンプルな場合）
find . -name "*.txt" | while read -r f; do
  cat "${f}"
done
```

**問題点**:
- `$(find ...)` の結果がワードスプリッティングされる
- `$f` がアンクォート

---

### 例7: 環境変数のエクスポート

```bash
# 悪い例（exportなし）
BOLD_GREEN='\033[1;32m'
echo "${BOLD_GREEN}Success${NC}"

# 良い例
export BOLD_GREEN='\033[1;32m'
export NC='\033[0m'
echo "${BOLD_GREEN}Success${NC}"
```

**理由**: `export` がないと、サブシェルやsourceされたスクリプトから参照できません。

---

### 例8: 関数内のローカル変数

```bash
# 悪い例
install_package() {
  package_name="$1"
  brew install "${package_name}"
}

# 良い例
install_package() {
  local package_name="$1"
  brew install "${package_name}"
}
```

**理由**: `local` を使用しないと、グローバルスコープを汚染します。

---

### 例9: 条件分岐での変数チェック

```bash
# 悪い例
if [[ -z $PS1_NEWLINE_LOGIN ]]; then
  PS1_NEWLINE_LOGIN=true
fi

# 良い例
if [[ -z "${PS1_NEWLINE_LOGIN}" ]]; then
  PS1_NEWLINE_LOGIN=true
fi
```

**理由**: Zshの `[[ ]]` 内では自動的にクォートされますが、明示的にクォートすることで一貫性が向上します。

---

### 例10: 定数の宣言

```bash
# 悪い例
SCRIPT_DIR="$(cd "$(dirname "$0")"; pwd)"

# 良い例
readonly SCRIPT_DIR="$(cd "$(dirname "$0")"; pwd)"

# または
declare -r SCRIPT_DIR="$(cd "$(dirname "$0")"; pwd)"
```

**理由**: `readonly` を使用することで、意図しない変更を防ぎます。

---

## 10. チェックリスト

新しいスクリプトを作成する際、または既存のスクリプトをレビューする際は、以下のチェックリストを使用してください。

### 基本

- [ ] シェバンは `#!/bin/zsh` か？
- [ ] 実行可能スクリプトで `set -eu` を使用しているか？
- [ ] 設定ファイル（.zshrc等）で `set -e` を使用していないか？

### 変数とクォーテーション

- [ ] すべての変数展開で `"${var}"` 形式を使用しているか？
- [ ] コマンド置換で `$(command)` 形式を使用しているか（バッククォート禁止）？
- [ ] 関数引数で `"$@"` を使用しているか（`$*` 禁止）？

### 変数・定数定義

- [ ] ローカル変数は小文字+アンダースコアか？
- [ ] 環境変数・定数は大文字+アンダースコアか？
- [ ] 定数は `readonly` または `declare -r` で宣言しているか？
- [ ] 環境変数は `export` で明示的にエクスポートしているか？
- [ ] 関数内の変数は `local` を使用しているか？

### パフォーマンス

- [ ] 遅いコマンド（`brew --prefix` 等）を複数回実行していないか？
- [ ] 必要に応じて結果を変数にキャッシュしているか？

### 条件分岐とテスト

- [ ] `[[ ]]` を使用しているか（`[ ]` 禁止）？
- [ ] 算術演算で `(( ))` を使用しているか（`let`, `expr` 禁止）？

### フォーマット

- [ ] インデントは2スペースか（タブ禁止）？
- [ ] 可読性の高いコードになっているか？

### その他

- [ ] エラーメッセージは標準エラー出力 (`>&2`) に出力しているか？
- [ ] コメントは適切に記述されているか？

---

## 参考資料

- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- [ShellCheck](https://www.shellcheck.net/) - シェルスクリプトの静的解析ツール
- [Zsh Documentation](https://zsh.sourceforge.io/Doc/)
- [Bash vs Zsh: Differences and Comparison](https://betterstack.com/community/guides/linux/zsh-vs-bash/)

---

## 更新履歴

- 2026-02-11: 初版作成
