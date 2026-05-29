#ifndef TODO_NODE_H
#define TODO_NODE_H

#include <stdio.h>

// Estructura autorreferenciada
struct TodoNode {
    int id;
    int userId;
    char title[200];
    bool completed;
    
    TodoNode* next; // Puntero autorreferenciado

    TodoNode(int _id, int _userId, const char* _title, bool _completed) {
        id = _id;
        userId = _userId;
        completed = _completed;
        snprintf(title, sizeof(title), "%s", _title);
        next = nullptr;
    }
};

#endif