#!/usr/bin/env python3

from string import Template
import argparse
import os.path
import sys
import binascii


parser = argparse.ArgumentParser(description='Convert binary file to verilog rom')
parser.add_argument('filename', metavar='filename', nargs=1,
                   help='filename of input binary')

args = parser.parse_args()
file = args.filename[0];

# check that file exists
if not os.path.isfile(file):
    print("File {} does not exist.".format(filename))
    sys.exit(1)

filename = os.path.splitext(file)[0]

def read_bin():

    with open(filename +".tmp", 'rb') as f:
        rom = bytearray((f.read()))
        rom = (binascii.hexlify(rom))
        #print(rom)
    # align to 64 bit
    align = (int((len((rom)) + 7) / 8 )) * 8

    for i in range(len(rom), align):
        rom.append("00")
    
    return rom

rom = read_bin()

with open( filename + ".uart.txt", "w") as f:
    rom_str = ""
    start_address = 0x80000000
    # process in junks of 512 bit (64 byte, 128 symbols)
    for i in (range(int(len(rom)/128))):
        word = str(rom[i*128:i*128+128])
        word = word[+2:-1]
        # address formatting, must be 8 bit long, and little endian
        address_str = (hex(start_address))[+2:]
        address_str = "0"+ address_str[+1:]
        address_str_out = address_str[+6:] + address_str[+4:-2] + address_str[+2:-4]+ address_str[:-6]
        # string concat
        rom_str += "        f3 " + word + "  "+ address_str_out + "\n"
        # increment address for next iterationS
        start_address = start_address +(0x40)

    # remove the trailing comma
    rom_str = rom_str[:-1]
    #print(rom_str)
    f.write(rom_str)

