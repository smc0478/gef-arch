#!/bin/sh -ex

echo "[+] Initialize"
if [ -z "${GDBINIT_PATH}" ]; then
    GDBINIT_PATH="/root/.gdbinit"
fi
GEF_PATH="${GDBINIT_PATH}-gef.py"

if [ ! $(id -u) = 0 ]; then
    echo "[-] Detected non-root user."
    echo "[-] INSTALLATION FAILED"
    exit 1
fi


echo "[+] pacman"
GDB_MULTIARCH="aarch64-linux-gnu-gdb arm-none-eabi-gdb avr-gdb lm32-elf-gdb or1k-elf-gdb ppc64le-elf-gdb riscv32-elf-gdb riscv64-elf-gdb riscv64-linux-gnu-gdb sh2-elf-gdb"
pacman -Sy
pacman -S --noconfirm tzdata
pacman -S --noconfirm  $GDB_MULTIARCH wget binutils gcc file ruby git colordiff binwalk imagemagick
#apt-get install -y gdb-multiarch binutils gcc file python3-pip ruby-dev git

echo "[+] pip3"
pip3 install setuptools crccheck unicorn capstone ropper keystone-engine tqdm codext angr pycryptodome magicka

echo "[+] install seccomp-tools, one_gadget"
if [ "x$(which seccomp-tools)" = "x" ]; then
    gem install seccomp-tools
fi

if [ "x$(which one_gadget)" = "x" ]; then
    gem install one_gadget
fi

echo "[+] Install rp++"
if [ "$(uname -m)" = "x86_64" ]; then
    if [ -z "$(command -v rp-lin)" ] && [ ! -e /usr/local/bin/rp-lin ]; then
        # v2.1.3 will cause an error on Ubuntu 22.10 or earlier.
        # The only difference between 2.1.2 and 2.1.3 is for OpenBSD compatibility and can be ignored.
        wget -q https://github.com/0vercl0k/rp/releases/download/v2.1.2/rp-lin-clang.zip -P /tmp
        unzip /tmp/rp-lin-clang.zip -d /usr/local/bin/
        chmod +x /usr/local/bin/rp-lin
        rm /tmp/rp-lin-clang.zip
    fi
fi

echo "[+] install vmlinux-to-elf"
if [ "x$(which vmlinux-to-elf)" = "x" ] && [ ! -e /usr/local/bin/vmlinux-to-elf ]; then
    pip3 install --upgrade lz4 zstandard git+https://github.com/clubby789/python-lzo@b4e39df
    pip3 install --upgrade git+https://github.com/marin-m/vmlinux-to-elf
fi

echo "[+] Download gef"
if [ -e "${GEF_PATH}" ]; then
    echo "[-] ${GEF_PATH} already exists. Please delete or rename."
    echo "[-] INSTALLATION FAILED"
    exit 1
else
    wget -q https://raw.githubusercontent.com/bata24/gef/dev/gef.py -O "${GEF_PATH}"
    if [ ! -s "${GEF_PATH}" ]; then
        echo "[-] Downloading ${GEF_PATH} failed."
        rm -f "${GEF_PATH}"
        echo "[-] INSTALLATION FAILED"
        exit 1
    fi
fi

echo "[+] Setup gef"
STARTUP_COMMAND="source ${GEF_PATH}"
if [ ! -e "${GDBINIT_PATH}" ] || [ -z "$(grep "${STARTUP_COMMAND}" "${GDBINIT_PATH}")" ]; then
    echo "${STARTUP_COMMAND}" >> "${GDBINIT_PATH}"
fi

echo "[+] INSTALLATION SUCCESSFUL"
exit 0
