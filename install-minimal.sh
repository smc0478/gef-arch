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
pacman -S --noconfirm  $GDB_MULTIARCH wget

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
