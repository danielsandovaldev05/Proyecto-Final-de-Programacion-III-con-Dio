#include <iostream>
#include <string>
#include <cstring>
#include "todo_node.h"

// Clase encargada de la lógica en C++ (POO)
class TodoManager {
private:
    TodoNode* head;

public:
    TodoManager() : head(nullptr) {}

    // 1. INSERCIÓN: Agrega un nodo al final de la lista enlazada
    void insertar(int id, int userId, const char* title, bool completed) {
        TodoNode* nuevo = new TodoNode(id, userId, title, completed);
        if (!head) {
            head = nuevo;
        } else {
            TodoNode* temp = head;
            while (temp->next) {
                temp = temp->next;
            }
            temp->next = nuevo;
        }
    }

    // 2. RECORRIDO: Cuenta cuántos nodos existen actualmente en memoria RAM
    int contar() {
        int contador = 0;
        TodoNode* temp = head;
        while (temp) {
            contador++;
            temp = temp->next;
        }
        return contador;
    }

    // 3. BÚSQUEDA: Busca una tarea por su ID único
    bool buscar(int id) {
        TodoNode* temp = head;
        while (temp) {
            if (temp->id == id) return true; // Encontrado
            temp = temp->next;
        }
        return false; // No existe
    }

    // 4. ELIMINACIÓN: Libera la memoria de un nodo específico (Gestión Manual)
    bool eliminar(int id) {
        if (!head) return false;

        // Si el nodo a eliminar es la cabeza
        if (head->id == id) {
            TodoNode* aEliminar = head;
            head = head->next;
            delete aEliminar; // Liberación de memoria explícita
            return true;
        }

        TodoNode* temp = head;
        while (temp->next && temp->next->id != id) {
            temp = temp->next;
        }

        if (temp->next) {
            TodoNode* aEliminar = temp->next;
            temp->next = temp->next->next;
            delete aEliminar; // Liberación de memoria explícita
            return true;
        }
        return false;
    }

    // Destructor: Limpia TODA la memoria al cerrar la app para evitar fugas (Memory Leaks)
    ~TodoManager() {
        TodoNode* temp = head;
        while (temp) {
            TodoNode* siguiente = temp->next;
            delete temp;
            temp = siguiente;
        }
    }
};

// --- PUENTE FFI (Funciones externas que Flutter puede mandar a llamar) ---
extern "C" {
    TodoManager* crear_manager() { 
        return new TodoManager(); 
    }
    
    void insertar_todo(TodoManager* mgr, int id, int userId, const char* title, bool completed) {
        if (mgr) mgr->insertar(id, userId, title, completed);
    }

    int obtener_conteo(TodoManager* mgr) {
        return (mgr) ? mgr->contar() : 0;
    }

    bool buscar_todo(TodoManager* mgr, int id) {
        return (mgr) ? mgr->buscar(id) : false;
    }

    bool eliminar_todo(TodoManager* mgr, int id) {
        return (mgr) ? mgr->eliminar(id) : false;
    }

    void borrar_manager(TodoManager* mgr) {
        if (mgr) delete mgr;
    }
}