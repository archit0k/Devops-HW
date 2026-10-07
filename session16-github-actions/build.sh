#!/usr/bin/env bash
set -euo pipefail
mkdir -p build
cp app/calculator.py build/calculator.py
printf 'Built by Archit Kulkarni (24BCS10194)\n' > build/build-info.txt
python -m py_compile build/calculator.py
