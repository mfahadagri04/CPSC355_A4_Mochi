// CPSC 355 Assignment 4 - Mochis Inventory
// Author: Muhammad Fahad
// LEC 01 & TUT 02

        .global main

// =====================
// Constants & Structs
// =====================
        .equ    MAX_N,      50          // max N value
        .equ    ELEM_SIZE,  4           // 4 bytes per int

        // Grid storage: MAX_N x MAX_N ints
        .equ    GRID_BYTES, MAX_N * MAX_N * ELEM_SIZE

        // Occurrence struct:
        .equ    O_ROW,   0               // offset of row field
        .equ    O_COL,   4               // offset of col field
        .equ    O_SIZE,  8               // struct size = 8 bytes

        // Max number of occurrences
        .equ    MAX_OCC, MAX_N * MAX_N
