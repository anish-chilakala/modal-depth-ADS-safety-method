# Simple Makefile that compiles every .hs in the folder into one executable.
GHC ?= ghc
SRC := $(wildcard *.hs)
OUT := modal-depth-experiment
BUILD_DIR := .build

.PHONY: all build run clean

all: build

build:
	@echo "Building $(OUT)..."
	$(GHC) -O2 -threaded -outputdir $(BUILD_DIR) -odir $(BUILD_DIR) $(SRC) -o $(OUT)

run: build
	@echo "Running $(OUT)..."
	./$(OUT)

clean:
	@echo "Cleaning build artifacts..."
	rm -rf $(BUILD_DIR) *.o *.hi $(OUT)
