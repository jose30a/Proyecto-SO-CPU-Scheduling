#include <QtWidgets/QApplication> // Forma correcta de incluir QApplication
#include "ui/interface.h"  // Ruta relativa desde src/winmain.cpp

int WINAPI WinMain(HINSTANCE hInstance, 
                  HINSTANCE hPrevInstance, 
                  LPSTR lpCmdLine, 
                  int nCmdShow)
{
    // Necesario para manejo de argumentos en Windows
    int argc = __argc;
    char **argv = __argv;
    
    QApplication app(argc, argv);
    
    // Asegúrate que esta clase coincide con la declarada en interface.h
    Interface mainInterface;
    mainInterface.show();
    
    return app.exec();
}