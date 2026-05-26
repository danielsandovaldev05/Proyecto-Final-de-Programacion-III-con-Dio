cmake_minimum_required(VERSION 3.10)

# Definir el proyecto nativo
project(native_lib VERSION 1.0.0 LANGUAGES CXX)

# Añadir archivo cpp como una librería compartida (.so / .dll)
add_library(native_lib SHARED
    src/todo_manager.cpp
)

# Vincular los encabezados (.h)
set_target_properties(native_lib PROPERTIES
    PUBLIC_HEADER src/todo_node.h
)