#!/bin/bash

CPU_ID=$1

make -j16 CPU_ID=$CPU_ID

BENCH_NAME="payload"
BENCH_FOLDER="build/"
CC_STRIP="riscv64-unknown-elf-strip"
CC_OBJCOPY="riscv64-unknown-elf-objcopy"
CC_OBJDUMP="riscv64-unknown-elf-objdump"
# might be needed --change-addresses=0x80000000
    ${CC_OBJCOPY} ${BENCH_FOLDER}${BENCH_NAME} ${BENCH_FOLDER}${BENCH_NAME}  \
# objdump
    ${CC_OBJDUMP} -d ${BENCH_FOLDER}${BENCH_NAME} > ${BENCH_FOLDER}${BENCH_NAME}_disam.txt --

# Remove debug section
    ${CC_STRIP} --strip-all -o ${BENCH_FOLDER}${BENCH_NAME}_strpd.elf ${BENCH_FOLDER}${BENCH_NAME}

# Produce temporary vmem file from object file with reversed bytes within the word
    echo "Generating .vmem file ..."
    ${CC_OBJCOPY} ${BENCH_FOLDER}${BENCH_NAME}_strpd.elf ${BENCH_FOLDER}${BENCH_NAME}.bin -O binary \
    --remove-section=.comment \
    --remove-section=.sdata \
    --remove-section=.riscv.attributes \
    #--file-alignment=64

# prepare uart dump
    #python gen_rom.py ${BENCH_FOLDER}${BENCH_NAME}.vmem.tmp

# Format .vmem file to be compliant with polimi riscv core requirements
    #echo "Formatting .vmem file ..."
    #if [ -f vmem_formatter ]; then
    #    ./vmem_formatter ${BENCH_FOLDER}${BENCH_NAME}.vmem.tmp ${BENCH_FOLDER}${BENCH_NAME}.vmem
    #else
    #    echo "[ERROR] vmem_formatter not found. Place it in the current working directory."
    #    exit 1;
    #fi

    echo "Removing temporary files ..."
    #rm ${BENCH_FOLDER}${BENCH_NAME}.vmem.tmp

    echo "Done."