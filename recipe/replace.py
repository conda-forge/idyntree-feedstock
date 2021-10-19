#!/usr/bin/env python3
import argparse
import fileinput

parser = argparse.ArgumentParser()
parser.add_argument("-f", "--file", type=str)
parser.add_argument("--pre", type=str)
parser.add_argument("--post", type=str)

args = parser.parse_args()

with fileinput.FileInput(args.file, inplace=True, backup='.bak') as file:
    for line in file:
        print(line.replace(args.pre, args.post), end='')
