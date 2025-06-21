# Makefile for CPU Scheduling Simulator on Windows (MinGW)

# Qt configuration
QT_ROOT := C:/Qt/6.9.1/mingw_64

# Compiler settings
CXX := g++
CXXFLAGS := -Wall -Wextra -std=c++17 \
	-I. -Isrc \
	-I"$(QT_ROOT)/include" \
	-I"$(QT_ROOT)/include/QtCore" \
	-I"$(QT_ROOT)/include/QtGui" \
	-I"$(QT_ROOT)/include/QtWidgets"

# Linker flags: console subsystem & Qt libs
LDFLAGS := -Wl,-subsystem,console \
	-Wl,-e,mainCRTStartup \
	-L"$(QT_ROOT)/lib" \
	-lQt6Widgets \
	-lQt6Gui \
	-lQt6Core

# Directories
SRC_DIR := src
BUILD_DIR := build
OBJ_DIR := $(BUILD_DIR)/src

# Source and object files (ensure winmain.cpp stub is compiled first)
SRC_FILES := \
	src/winmain.cpp \
	src/main.cpp \
	src/core/process.cpp \
	src/core/scheduler.cpp \
	src/core/metrics.cpp \
	src/algorithms/fcfs.cpp \
	src/algorithms/sjf.cpp \
	src/algorithms/rr.cpp \
	src/algorithms/priority.cpp \
	src/ui/interface.cpp \
	src/ui/results_display.cpp

OBJ_FILES := $(patsubst src/%.cpp,$(OBJ_DIR)/%.o,$(SRC_FILES))

.PHONY: all clean

# Default target: build executable
all: $(BUILD_DIR)/simulator.exe

# Link executable (winmain.o provides WinMain stub)
$(BUILD_DIR)/simulator.exe: $(OBJ_FILES)
	@echo Linking $@...
	$(CXX) $^ -o $@ $(LDFLAGS)
	@echo Build successful: $@

# Compile rule: compile each src/*.cpp into build/src/*.o
$(OBJ_DIR)/%.o: src/%.cpp | $(BUILD_DIR) $(OBJ_DIR) $(OBJ_DIR)/core $(OBJ_DIR)/algorithms $(OBJ_DIR)/ui
	@echo Compiling $< to $@
	$(CXX) $(CXXFLAGS) -c $< -o $@

# Create necessary directories
$(BUILD_DIR):
	if not exist "$(BUILD_DIR)" mkdir "$(BUILD_DIR)"

$(OBJ_DIR):
	if not exist "$(OBJ_DIR)" mkdir "$(OBJ_DIR)"

$(OBJ_DIR)/core:
	if not exist "$(OBJ_DIR)/core" mkdir "$(OBJ_DIR)/core"

$(OBJ_DIR)/algorithms:
	if not exist "$(OBJ_DIR)/algorithms" mkdir "$(OBJ_DIR)/algorithms"

$(OBJ_DIR)/ui:
	if not exist "$(OBJ_DIR)/ui" mkdir "$(OBJ_DIR)/ui"

# Clean target: remove build directory
clean:
	@echo Cleaning...
	if exist "$(BUILD_DIR)" rmdir /S /Q "$(BUILD_DIR)"
