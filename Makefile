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

# Linker flags
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

# Source files - winmain primero explícitamente
WINMAIN_SRC := src/winmain.cpp
OTHER_SRCS := \
    src/main.cpp \
    src/core/process.cpp \
    src/core/scheduler.cpp \
    src/core/metrics.cpp \
    src/core/algorithms/fcfs.cpp \
    src/core/algorithms/sjf.cpp \
    src/core/algorithms/round_robin.cpp \
    src/core/algorithms/priority.cpp \
    src/ui/interface.cpp \
    src/ui/results_display.cpp \
    src/utils/file_handler.cpp \
    src/utils/process_generator.cpp

# Object files
WINMAIN_OBJ := $(OBJ_DIR)/winmain.o
OTHER_OBJS := $(patsubst src/%.cpp,$(OBJ_DIR)/%.o,$(OTHER_SRCS))

.PHONY: all clean

# Default target
all: $(BUILD_DIR)/simulator.exe

# Link executable - winmain.o primero explícitamente
$(BUILD_DIR)/simulator.exe: $(WINMAIN_OBJ) $(OTHER_OBJS)
	@echo Linking $@...
	$(CXX) $^ -o $@ $(LDFLAGS)
	@echo Build successful: $@

# Regla especial para winmain para garantizar que se compile primero
$(WINMAIN_OBJ): $(WINMAIN_SRC) | dirs
	@echo Compiling $< to $@ [Priority]
	$(CXX) $(CXXFLAGS) -c $< -o $@

# Regla para otros archivos
$(OBJ_DIR)/%.o: src/%.cpp | dirs
	@echo Compiling $< to $@
	$(CXX) $(CXXFLAGS) -c $< -o $@

# Creación de directorios
.PHONY: dirs
dirs: $(OBJ_DIR)/core/algorithms $(OBJ_DIR)/ui $(OBJ_DIR)/utils

$(OBJ_DIR)/core/algorithms $(OBJ_DIR)/ui $(OBJ_DIR)/utils:
	@if not exist "$(BUILD_DIR)" mkdir "$(BUILD_DIR)"
	@if not exist "$(OBJ_DIR)" mkdir "$(OBJ_DIR)"
	@if not exist "$(OBJ_DIR)/core" mkdir "$(OBJ_DIR)/core"
	@if not exist "$(OBJ_DIR)/core/algorithms" mkdir "$(OBJ_DIR)/core/algorithms"
	@if not exist "$(OBJ_DIR)/ui" mkdir "$(OBJ_DIR)/ui"
	@if not exist "$(OBJ_DIR)/utils" mkdir "$(OBJ_DIR)/utils"

clean:
	@echo Cleaning...
	@if exist "$(BUILD_DIR)" rmdir /S /Q "$(BUILD_DIR)"