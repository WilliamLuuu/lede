# LEDE / OpenWrt Source Repository

> This project is based on [coolsnowwolf/lede](https://github.com/coolsnowwolf/lede), originally authored by Lean.

I18N: [English](README_EN.md) | [简体中文](README.md) | [日本語](README_JA.md)

## Notice

1. **Never compile OpenWRT as `root`**
2. If you are living in mainland China, please make sure you could visit the **REAL** Internet.
3. Default login IP is `192.168.3.1`, password is `password`.

## How to Compile

1. Install a Linux distribution, Debian or Ubuntu LTS is recommended.

2. Install dependencies:

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

3. Clone the source code, update `feeds` and configure:

   ```bash
   git clone https://github.com/WilliamLuuu/lede.git lede
   cd lede
   ./scripts/feeds update -a
   ./scripts/feeds install -a
   make menuconfig
   ```

4. Download libraries and compile firmware
   > (`-j` is the thread count, single-thread is recommended for the first build):

   ```bash
   make download -j8
   make V=s -j1
   ```

Build results depend on the host environment, selected target, and package configuration.

Rebuild:

```bash
cd lede
git pull
./scripts/feeds update -a
./scripts/feeds install -a
make defconfig
make download -j8
make V=s -j$(nproc)
```

If reconfiguration is need:

```bash
rm -rf ./tmp && rm -rf .config
make menuconfig
make V=s -j$(nproc)
```

Build artifacts will be outputted to `bin/targets` directory.

### If you are using WSL/WSL2 as your build environment

WSL's `PATH` potentially contain Windows paths with spaces, which may cause compilation failure.
Please add the following lines to your local environment profiles before compiling:

```bash
# Update and reload your profile, ~/.bashrc for example.
cat << EOF >> ~/.bashrc
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"
EOF
source ~/.bashrc
```

NTFS-formatted drives mounted to a WSL distribution will be case-insensitive by default.
This will cause the following error when compiling in WSL/WSL2:

```txt
Build dependency: OpenWrt can only be built on a case-sensitive filesystem
```

A simple solution is to create a case-sensitive `lede` directory before `git clone`:

```powershell
# Open a terminal as administrator
PS > New-Item -ItemType Directory -Path lede
PS > fsutil.exe file setCaseSensitiveInfo lede enable
PS > git clone https://github.com/WilliamLuuu/lede.git lede
```

> For directories that have already been `git clone`, `fsutil.exe` will not take effect.
> Case sensitivity will only be enabled for new changes in the directory.

### macOS Compilation

1. Install Xcode from AppStore

2. Install Homebrew:

   ```bash
   /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
   ```

3. Install toolchain, dependencies and packages with Homebrew:

   ```bash
   brew unlink awk
   brew install coreutils diffutils findutils gawk gnu-getopt gnu-tar grep make ncurses pkg-config wget quilt xz
   brew install gcc@11
   ```

4. Update your system environment:

   - mac with intel chip

   ```bash
   echo 'export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"' >> ~/.bashrc
   echo 'export PATH="/usr/local/opt/findutils/libexec/gnubin:$PATH"' >> ~/.bashrc
   echo 'export PATH="/usr/local/opt/gnu-getopt/bin:$PATH"' >> ~/.bashrc
   echo 'export PATH="/usr/local/opt/gnu-tar/libexec/gnubin:$PATH"' >> ~/.bashrc
   echo 'export PATH="/usr/local/opt/grep/libexec/gnubin:$PATH"' >> ~/.bashrc
   echo 'export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"' >> ~/.bashrc
   echo 'export PATH="/usr/local/opt/make/libexec/gnubin:$PATH"' >> ~/.bashrc
   ```

   - mac with apple chip

   ```zsh
   echo 'export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"' >> ~/.bashrc
   echo 'export PATH="/opt/homebrew/opt/findutils/libexec/gnubin:$PATH"' >> ~/.bashrc
   echo 'export PATH="/opt/homebrew/opt/gnu-getopt/bin:$PATH"' >> ~/.bashrc
   echo 'export PATH="/opt/homebrew/opt/gnu-tar/libexec/gnubin:$PATH"' >> ~/.bashrc
   echo 'export PATH="/opt/homebrew/opt/grep/libexec/gnubin:$PATH"' >> ~/.bashrc
   echo 'export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"' >> ~/.bashrc
   echo 'export PATH="/opt/homebrew/opt/make/libexec/gnubin:$PATH"' >> ~/.bashrc
   ```

5. Reload your shell profile `source ~/.bashrc && bash`, then you can compile normally like Linux.

## Security

The source should not contain backdoors or closed-source software that monitors or intercepts HTTPS traffic. Review third-party package sources and code before building or installing them.

## Donation

[See the original author's donation options](https://github.com/coolsnowwolf/lede#donation)
