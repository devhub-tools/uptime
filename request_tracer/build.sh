#!/usr/bin/env bash

tinygo build -o main.wasm -scheduler=none --no-debug -target wasi main.go
