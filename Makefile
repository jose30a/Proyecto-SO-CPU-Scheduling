# Compiler and flags
CXX = g++
CXXFLAGS = -Wall -Wextra -std=c++17 -I./src/core -I./src/algorithms -I./src/ui
LDFLAGS =

# Qt specific flags (adjust paths if necessary for your MinGW-w64 Qt installation)
# You might need to find where qmake is located and then use it to get the correct flags.
# For example, on Windows with Qt installed, it might be in C:\Qt\5.15.2\mingw81_64\bin\qmake.exe
# And the includes and libs would be in C:\Qt\5.15.2\mingw81_64\include and C:\Qt\5.15.2\mingw81_64\lib
QT_MOC_FLAGS = -fPIC
QT_INCLUDE_PATH = -I$(QTDIR)/include -I$(QTDIR)/include/QtCore -I$(QTDIR)/include/QtGui -I$(QTDIR)/include/QtWidgets
QT_LIB_PATH = -L$(QTDIR)/lib
QT_LIBS = -lQt5Widgets -lQt5Gui -lQt5Core

# Project structure
SRC_DIR = src
CORE_DIR = $(SRC_DIR)/core
ALGORITHMS_DIR = $(SRC_DIR)/algorithms
UI_DIR = $(SRC_DIR)/ui
BUILD_DIR = build

# Source files
CORE_SRCS = $(CORE_DIR)/process.cpp $(CORE_DIR)/scheduler.cpp $(CORE_DIR)/metrics.cpp
ALGORITHM_SRCS = $(ALGORITHMS_DIR)/fcfs.cpp $(ALGORITHMS_DIR)/sjf.cpp $(ALGORITHMS_DIR)/rr.cpp $(ALGORITHMS_DIR)/priority.cpp
UI_SRCS = $(UI_DIR)/interface.cpp $(UI_DIR)/results_display.cpp
MAIN_SRC = $(SRC_DIR)/main.cpp

SRCS = $(MAIN_SRC) $(CORE_SRCS) $(ALGORITHM_SRCS) $(UI_SRCS)

# Object files
OBJS = $(patsubst %.cpp,$(BUILD_DIR)/%.o,$(SRCS))
# For Qt, you might also have MOC files if using signals/slots with custom classes.
# This example assumes simple .cpp files for UI, if you use Qt Creator or design files,
# you'll need to run moc on the header files that contain Q_OBJECT.

# Executable name
TARGET = $(BUILD_DIR)/simulator.exe

# Default target
all: $(TARGET)

# Rule to create the build directory if it doesn't exist
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Rule to compile each .cpp file into a .o file
$(BUILD_DIR)/%.o: %.cpp | $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) $(QT_INCLUDE_PATH) -c $< -o $@

# Rule to link all object files into the final executable
$(TARGET): $(OBJS)
	$(CXX) $(OBJS) -o $@ $(LDFLAGS) $(QT_LIB_PATH) $(QT_LIBS)

# Clean target to remove compiled files
clean:
	rm -f $(BUILD_DIR)/*.o $(TARGET)

# Phony targets to prevent conflicts with file names
.PHONY: all clean