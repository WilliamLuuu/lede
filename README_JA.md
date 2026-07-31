# LEDE / OpenWrt ソースリポジトリ

> このプロジェクトは Lean 氏が作成した [coolsnowwolf/lede](https://github.com/coolsnowwolf/lede) を基にしています。

I18N: [English](README_EN.md) | [简体中文](README.md) | [日本語](README_JA.md)

## 注意

1. **OpenWRT を決して `root` としてコンパイルしないこと**
2. 中国本土にお住まいの方は、ぜひ **REAL** インターネットをご覧ください。
3. デフォルトのログイン IP は `192.168.3.1` で、パスワードは `password` です。

## コンパイル方法

1. Linuxディストリビューションをインストールし、Debian または Ubuntu LTS を推奨します。

2. 依存関係をインストールする:

   ```bash
   sudo apt update -y
   sudo apt full-upgrade -y
   sudo apt install -y ack antlr3 asciidoc autoconf automake autopoint binutils bison build-essential \
   bzip2 ccache clang cmake cpio curl device-tree-compiler flex gawk gcc-multilib g++-multilib gettext \
   git gperf haveged help2man intltool libc6-dev-i386 libelf-dev libfuse-dev libglib2.0-dev libgmp3-dev \
   libltdl-dev libmpc-dev libmpfr-dev libncurses5-dev libncursesw5-dev libpython3-dev libreadline-dev \
   libssl-dev libtool llvm lrzsz mkisofs msmtp nano ninja-build p7zip p7zip-full patch pkgconf python3 \
   python3-pyelftools python3-setuptools qemu-utils rsync scons squashfs-tools subversion swig texinfo \
   uglifyjs upx-ucl unzip vim wget xmlto xxd zlib1g-dev
   ```

3. ソースコードをクローンし、`feeds` を更新して設定する:

   ```bash
   git clone https://github.com/WilliamLuuu/lede.git lede
   cd lede
   ./scripts/feeds update -a
   ./scripts/feeds install -a
   make menuconfig
   ```

4. ライブラリのダウンロードとファームウェアのコンパイル
   > (`-j` はスレッドカウント、最初のビルドはシングルスレッドを推奨):

   ```bash
   make download -j8
   make V=s -j1
   ```

ビルド結果は、ホスト環境、選択したターゲット、パッケージ設定によって異なります。

リビルド:

```bash
cd lede
git pull
./scripts/feeds update -a
./scripts/feeds install -a
make defconfig
make download -j8
make V=s -j$(nproc)
```

再設定が必要な場合:

```bash
rm -rf ./tmp && rm -rf .config
make menuconfig
make V=s -j$(nproc)
```

ビルドの成果物は `bin/targets` ディレクトリに出力されます。

### WSL/WSL2 をビルド環境として使用している場合

WSL の `PATH` には、Windows のパスが空白で含まれている可能性があり、コンパイルに失敗することがあります。
コンパイルする前に、ローカルの環境プロファイルに以下の行を追加してください:

```bash
# 例えば、~/.bashrc などのプロファイルを更新した後、再読み込みを行う。
cat << EOF >> ~/.bashrc
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"
EOF
source ~/.bashrc
```

WSL ディストリビューションにマウントされた NTFS フォーマットのドライブは、デフォルトで大文字と小文字が区別されません。
このため、WSL/WSL2 でコンパイルすると、次のようなエラーが発生します:

```txt
Build dependency: OpenWrt can only be built on a case-sensitive filesystem
```

単純な解決策は、`git clone` の前に大文字と小文字を区別する `lede` ディレクトリを作成することです:

```powershell
# 管理者としてターミナルを開く
PS > New-Item -ItemType Directory -Path lede
PS > fsutil.exe file setCaseSensitiveInfo lede enable
PS > git clone https://github.com/WilliamLuuu/lede.git lede
```

> すでに `git clone` されたディレクトリでは、`fsutil.exe` は有効になりません。
> 大文字小文字の区別はディレクトリの新しい変更に対してのみ有効になります。

### macOS コンパイル

1. AppStore から Xcode をインストールする

2. Homebrew をインストールする:

   ```bash
   /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
   ```

3. Homebrew でツールチェーン、依存関係、パッケージをインストールする:

   ```bash
   brew unlink awk
   brew install coreutils diffutils findutils gawk gnu-getopt gnu-tar grep make ncurses pkg-config wget quilt xz
   brew install gcc@11
   ```

4. システム環境のアップデート:

   - MacのIntelシリコンバージョン

   ```bash
   echo 'export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"' >> ~/.bashrc
   echo 'export PATH="/usr/local/opt/findutils/libexec/gnubin:$PATH"' >> ~/.bashrc
   echo 'export PATH="/usr/local/opt/gnu-getopt/bin:$PATH"' >> ~/.bashrc
   echo 'export PATH="/usr/local/opt/gnu-tar/libexec/gnubin:$PATH"' >> ~/.bashrc
   echo 'export PATH="/usr/local/opt/grep/libexec/gnubin:$PATH"' >> ~/.bashrc
   echo 'export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"' >> ~/.bashrc
   echo 'export PATH="/usr/local/opt/make/libexec/gnubin:$PATH"' >> ~/.bashrc
   ```

   - MacのAppleシリコンバージョン

   ```zsh
   echo 'export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"' >> ~/.bashrc
   echo 'export PATH="/opt/homebrew/opt/findutils/libexec/gnubin:$PATH"' >> ~/.bashrc
   echo 'export PATH="/opt/homebrew/opt/gnu-getopt/bin:$PATH"' >> ~/.bashrc
   echo 'export PATH="/opt/homebrew/opt/gnu-tar/libexec/gnubin:$PATH"' >> ~/.bashrc
   echo 'export PATH="/opt/homebrew/opt/grep/libexec/gnubin:$PATH"' >> ~/.bashrc
   echo 'export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"' >> ~/.bashrc
   echo 'export PATH="/opt/homebrew/opt/make/libexec/gnubin:$PATH"' >> ~/.bashrc
   ```

5. シェルプロファイル `source ~/.bashrc && bash` を再読み込みすれば、Linux のように普通にコンパイルできます。

## セキュリティ

ソースには、HTTPS 通信を監視または傍受するバックドアやクローズドソースソフトウェアを含めるべきではありません。ビルドやインストールの前に、サードパーティ製パッケージの出所とコードを確認してください。

## 寄付

[原作者への寄付方法を見る](https://github.com/coolsnowwolf/lede#寄付)
