#!/usr/bin/env bash
# Compile and run the self-checking RV32I top-level smoke test with Icarus Verilog.
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

for tool in iverilog vvp; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "ERROR: required tool '$tool' was not found in PATH." >&2
        echo "Install Icarus Verilog and rerun: bash sim/run_smoke.sh" >&2
        exit 127
    fi
done

TESTBENCH="$ROOT_DIR/tb/tb_rv32i_smoke.v"
if [[ ! -f "$TESTBENCH" ]]; then
    echo "ERROR: missing self-checking testbench: $TESTBENCH" >&2
    exit 2
fi

mapfile -t RTL_SOURCES < <(find "$ROOT_DIR/rtl" -type f -name '*.v' -print | sort)
if [[ ${#RTL_SOURCES[@]} -eq 0 ]]; then
    echo "ERROR: no Verilog source files found under $ROOT_DIR/rtl" >&2
    exit 2
fi

BUILD_DIR="$(mktemp -d)"
trap 'rm -rf "$BUILD_DIR"' EXIT

iverilog -g2012 -Wall -s tb_rv32i_smoke \
    -o "$BUILD_DIR/rv32i_smoke.vvp" "${RTL_SOURCES[@]}" "$TESTBENCH"

(
    cd "$BUILD_DIR"
    vvp ./rv32i_smoke.vvp
) | tee "$BUILD_DIR/simulation.log"

if ! grep -Fq "PASS: RV32I top-level smoke test completed successfully." "$BUILD_DIR/simulation.log"; then
    echo "ERROR: the smoke test did not report PASS." >&2
    exit 1
fi

echo "[PASS] RV32I top-level smoke simulation."
