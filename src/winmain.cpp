#ifdef _WIN32
#include <windows.h>
extern int main(int, char**);
 
extern "C" __declspec(dllexport)
int WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int) {
    return main(__argc, __argv);
}
#endif

