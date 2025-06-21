# Compiler and flags
CXX = g++
# -I. includes the current directory (project root) for headers.
# Other -I flags are for specific source subdirectories where headers might reside.
CXXFLAGS = -Wall -Wextra -std=c++17 -I. -I$(SRC_DIR) -I$(CORE_DIR) -I$(ALGORITHMS_DIR) -I$(UI_DIR)
LDFLAGS =

# Qt specific flags (adjust QTDIR if necessary for your MinGW-w64 Qt installation)

QTDIR = "C:/Qt/6.9.1/mingw_64"
QT_INCLUDE_PATH = -I"$(QTDIR)/include" -I"$(QTDIR)/include/QtCore" -I"$(QTDIR)/include/QtGui" -I"$(QTDIR)/include/QtWidgets"
QT_LIB_PATH = -L"$(QTDIR)/lib"
QT_LIBS = -lQt5Widgets -lQt5Gui -lQt5Core

# Project structure directories
SRC_DIR = src
CORE_DIR = $(SRC_DIR)/core
ALGORITHMS_DIR = $(SRC_DIR)/algorithms
UI_DIR = $(SRC_DIR)/ui
BUILD_DIR = build

# List all source files explicitly with their full paths relative to the Makefile
SRCS = $(SRC_DIR)/main.cpp \
       $(CORE_DIR)/process.cpp \
       $(CORE_DIR)/scheduler.cpp \
       $(CORE_DIR)/metrics.cpp \
       $(ALGORITHMS_DIR)/fcfs.cpp \
       $(ALGORITHMS_DIR)/sjf.cpp \
       $(ALGORITHMS_DIR)/rr.cpp \
       $(ALGORITHMS_DIR)/priority.cpp \
       $(UI_DIR)/interface.cpp \
       $(UI_DIR)/results_display.cpp

# Object files: Transform source paths (e.g., src/main.cpp) into
# object paths within the build directory (e.g., build/src/main.o)
OBJS = $(patsubst %.cpp,$(BUILD_DIR)/%.o,$(SRCS))

# Executable name
TARGET = $(BUILD_DIR)/simulator.exe

# Default target
all: $(TARGET)

# Rule to link all object files into the final executable
# The | $(BUILD_DIR) makes sure the main build directory exists before linking.
$(TARGET): $(OBJS) | $(BUILD_DIR)
	@echo "Linking $(TARGET)..."
	$(CXX) $(OBJS) -o $@ $(LDFLAGS) $(QT_LIB_PATH) $(QT_LIBS)
	@echo "Build successful: $(TARGET)"

# Generic rule to compile any .cpp file from its source directory into
# a corresponding .o file within the build directory structure.
# For example:
# To make 'build/src/main.o', it looks for 'src/main.cpp'
# To make 'build/src/core/process.o', it looks for 'src/core/process.cpp'
$(BUILD_DIR)/%.o: %.cpp
	@mkdir -p $(dir $@) # Create the target subdirectory (e.g., build/src, build/src/core) if it doesn't exist
	@echo "Compiling $< to $@"
	$(CXX) $(CXXFLAGS) $(QT_INCLUDE_PATH) -c $< -o $@

# Rule to create the main build directory if it doesn't exist
$(BUILD_DIR):
	@echo "Creating build directory: $(BUILD_DIR)"
	mkdir -p $(BUILD_DIR)

# Clean target to remove compiled files and directories
clean:
	@echo "Cleaning build directory: $(BUILD_DIR)..."
	@rm -rf $(BUILD_DIR)
	@echo "Clean complete."

# Phony targets to prevent conflicts with file names
.PHONY: all clean