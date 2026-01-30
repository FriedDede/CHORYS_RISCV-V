TEST_NAME=$2
BENCH_FOLDER="build/"
BIN_FOLDER=${BENCH_FOLDER}"bin/"
CPU=$3
#!/bin/bash

# Check if exactly two arguments are provided
if [ "$#" -ne 3 ]; then
    echo "Error: 3 arguments required."
    echo "Usage: $0 <cva6|snitch> <bench_name> <core_id>"
    exit 1
fi

# Check if the first argument is either "cva6" or "snitch"
if [ "$1" != "cva6" ] && [ "$1" != "snitch" ]; then
    echo "Error: "Core type" must be either 'cva6' or 'snitch'."
    exit 1
fi

if [ "$1" == "cva6" ]; then
    RV64=1
    CC_STRIP="riscv64-unknown-elf-strip"
    CC_OBJCOPY="riscv64-unknown-elf-objcopy"
    CC_OBJDUMP="riscv64-unknown-elf-objdump"
else
    RV64=0
    CC_STRIP="riscv64-unknown-elf-strip"
    CC_OBJCOPY="riscv64-unknown-elf-objcopy"
    CC_OBJDUMP="riscv64-unknown-elf-objdump"
fi

BENCH_NAME=${TEST_NAME}_${CPU}

make all RV64=$RV64 TEST=${TEST_NAME} CPU=$3

# objdump
    mkdir ${BENCH_FOLDER}disasm
    ${CC_OBJDUMP} -d ${BENCH_FOLDER}${BENCH_NAME}.elf > ${BENCH_FOLDER}disasm/${BENCH_NAME}_disasm.txt --

# Remove debug section
    ${CC_STRIP} --strip-all -o ${BENCH_FOLDER}${BENCH_NAME}_strpd.elf ${BENCH_FOLDER}${BENCH_NAME}.elf

# Produce temporary vmem file from object file with reversed bytes within the word
    echo "Generating .vmem file ..."
    ${CC_OBJCOPY} ${BENCH_FOLDER}${BENCH_NAME}_strpd.elf ${BENCH_FOLDER}${BENCH_NAME}.bin -O binary \
    --remove-section=.comment \
    --remove-section=.sdata \
    --remove-section=.riscv.attributes \
    #--file-alignment=64

rm ${BENCH_FOLDER}${BENCH_NAME}_strpd.elf
rm ${BENCH_FOLDER}${BENCH_NAME}.elf

echo "Polybench : ${BENCH_NAME} binary generated"