#include <iostream>
#include <vector>
#include <queue>
#include <iomanip>
#include <fstream>
#include <sstream>
#include <algorithm>

using namespace std;

// Estados de un proceso
enum class Estado {
    NUEVO,
    LISTO,
    EJECUTANDO,
    TERMINADO
};

// Estructura de un proceso
struct Proceso {
    int id;
    int llegada;
    int burst;
    int prioridad;
    Estado estado;
    int tiempoRestante;
    int tiempoRespuesta;
    int tiempoFinalizacion;
    bool respuestaCalculada;
    
    Proceso(int id, int llegada, int burst, int prioridad)
        : id(id), llegada(llegada), burst(burst), prioridad(prioridad),
          estado(Estado::NUEVO), tiempoRestante(burst),
          tiempoRespuesta(-1), tiempoFinalizacion(-1),
          respuestaCalculada(false) {}
};

// Métricas de un proceso
struct MetricasProceso {
    int turnaroundTime;
    int waitingTime;
    int responseTime;
};

// Métricas del sistema
struct MetricasSistema {
    double avgTurnaroundTime;
    double avgWaitingTime;
    double cpuUtilization;
};

// Función para cargar procesos desde un archivo
vector<Proceso> cargarProcesosDesdeArchivo(const string& filename) {
    vector<Proceso> procesos;
    ifstream file(filename);
    string line;
    
    if (!file.is_open()) {
        cerr << "Error al abrir el archivo: " << filename << endl;
        return procesos;
    }
    
    // Saltar la línea de encabezado si existe
    getline(file, line);
    
    while (getline(file, line)) {
        stringstream ss(line);
        char p;
        int id, llegada, burst, prioridad;
        
        ss >> p >> id >> llegada >> burst >> prioridad;
        procesos.emplace_back(id, llegada, burst, prioridad);
    }
    
    file.close();
    return procesos;
}

// Función para simular Round Robin
pair<vector<MetricasProceso>, MetricasSistema> roundRobin(
    vector<Proceso> procesos, int quantum) {
    
    vector<MetricasProceso> metricasProcesos(procesos.size());
    MetricasSistema metricasSistema{0, 0, 0};
    
    queue<Proceso*> colaListos;
    int tiempo = 0;
    int procesosTerminados = 0;
    int tiempoOcioso = 0;
    int totalProcesos = procesos.size();
    
    // Ordenar procesos por tiempo de llegada
    sort(procesos.begin(), procesos.end(), 
        [](const Proceso& a, const Proceso& b) {
            return a.llegada < b.llegada;
        });
    
    // Inicializar tiempos de respuesta
    for (auto& p : procesos) {
        metricasProcesos[p.id - 1].responseTime = -1;
    }
    
    while (procesosTerminados < totalProcesos) {
        // Agregar procesos que han llegado a la cola de listos
        for (auto& p : procesos) {
            if (p.llegada == tiempo && p.estado == Estado::NUEVO) {
                p.estado = Estado::LISTO;
                colaListos.push(&p);
            }
        }
        
        if (!colaListos.empty()) {
            Proceso* actual = colaListos.front();
            colaListos.pop();
            
            // Marcar tiempo de respuesta si es la primera vez que se ejecuta
            if (!actual->respuestaCalculada) {
                metricasProcesos[actual->id - 1].responseTime = tiempo - actual->llegada;
                actual->respuestaCalculada = true;
            }
            
            actual->estado = Estado::EJECUTANDO;
            int tiempoEjecucion = min(quantum, actual->tiempoRestante);
            
            // Ejecutar el proceso
            for (int i = 0; i < tiempoEjecucion; ++i) {
                tiempo++;
                actual->tiempoRestante--;
                
                // Agregar nuevos procesos que llegan durante la ejecución
                for (auto& p : procesos) {
                    if (p.llegada == tiempo && p.estado == Estado::NUEVO) {
                        p.estado = Estado::LISTO;
                        colaListos.push(&p);
                    }
                }
            }
            
            if (actual->tiempoRestante == 0) {
                // Proceso terminado
                actual->estado = Estado::TERMINADO;
                actual->tiempoFinalizacion = tiempo;
                procesosTerminados++;
                
                // Calcular métricas para este proceso
                metricasProcesos[actual->id - 1].turnaroundTime = 
                    actual->tiempoFinalizacion - actual->llegada;
                metricasProcesos[actual->id - 1].waitingTime = 
                    metricasProcesos[actual->id - 1].turnaroundTime - actual->burst;
            } else {
                // Volver a cola de listos
                actual->estado = Estado::LISTO;
                colaListos.push(actual);
            }
        } else {
            // CPU ociosa
            tiempoOcioso++;
            tiempo++;
        }
    }
    
    // Calcular métricas del sistema
    double totalTurnaround = 0;
    double totalWaiting = 0;
    
    for (const auto& m : metricasProcesos) {
        totalTurnaround += m.turnaroundTime;
        totalWaiting += m.waitingTime;
    }
    
    metricasSistema.avgTurnaroundTime = totalTurnaround / totalProcesos;
    metricasSistema.avgWaitingTime = totalWaiting / totalProcesos;
    metricasSistema.cpuUtilization = 
        (double)(tiempo - tiempoOcioso) / tiempo * 100;
    
    return {metricasProcesos, metricasSistema};
}

// Función para mostrar resultados
void mostrarResultados(const vector<Proceso>& procesos,
                       const vector<MetricasProceso>& metricasProcesos,
                       const MetricasSistema& metricasSistema) {
    
    cout << "\nResultados de la simulación Round Robin:\n";
    cout << "------------------------------------------------\n";
    cout << "Proceso | Turnaround | Espera | Respuesta\n";
    cout << "------------------------------------------------\n";
    
    for (size_t i = 0; i < procesos.size(); ++i) {
        cout << "P" << procesos[i].id << "\t| "
             << setw(6) << metricasProcesos[i].turnaroundTime << "\t| "
             << setw(6) << metricasProcesos[i].waitingTime << "\t| "
             << setw(6) << metricasProcesos[i].responseTime << endl;
    }
    
    cout << "------------------------------------------------\n";
    cout << fixed << setprecision(2);
    cout << "Turnaround promedio: " << metricasSistema.avgTurnaroundTime << endl;
    cout << "Espera promedio: " << metricasSistema.avgWaitingTime << endl;
    cout << "Utilización de CPU: " << metricasSistema.cpuUtilization << "%" << endl;
}

// Función para mostrar el diagrama de Gantt (simplificado)
void mostrarDiagramaGantt(const vector<Proceso>& procesos) {
    cout << "\nDiagrama de Gantt (simplificado):\n";
    // Implementación básica - en una GUI sería más visual
    for (const auto& p : procesos) {
        cout << "P" << p.id << " terminó en t=" << p.tiempoFinalizacion << " | ";
    }
    cout << endl;
}

int main() {
    int opcion;
    vector<Proceso> procesos;
    int quantum;
    
    cout << "Simulador de Round Robin\n";
    cout << "1. Cargar procesos desde archivo\n";
    cout << "2. Ingresar procesos manualmente\n";
    cout << "Seleccione una opción: ";
    cin >> opcion;
    
    if (opcion == 1) {
        string filename;
        cout << "Ingrese el nombre del archivo: ";
        cin >> filename;
        procesos = cargarProcesosDesdeArchivo(filename);
    } else if (opcion == 2) {
        int numProcesos;
        cout << "Número de procesos: ";
        cin >> numProcesos;
        
        for (int i = 0; i < numProcesos; ++i) {
            int id, llegada, burst, prioridad;
            cout << "Proceso " << i+1 << " (ID Llegada Burst Prioridad): ";
            cin >> id >> llegada >> burst >> prioridad;
            procesos.emplace_back(id, llegada, burst, prioridad);
        }
    } else {
        cout << "Opción no válida\n";
        return 1;
    }
    
    cout << "Ingrese el quantum: ";
    cin >> quantum;
    
    auto [metricasProcesos, metricasSistema] = roundRobin(procesos, quantum);
    mostrarResultados(procesos, metricasProcesos, metricasSistema);
    mostrarDiagramaGantt(procesos);
    
    return 0;
}