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

// ======
// Data 
// ======
        .data

promptN:
        .string "Enter the size of the table: "

promptDigitSearch:
        .string "Enter a digit to search for (negative to quit): "

fmtInt:
        .string "%d"

fmtElem:
        .string "%d "

fmtNL:
        .string "\n"

fmtCount:
        .string "Digit %d occurrences: %d\n"

fmtOccurence:
        .string "%d. In (%d,%d)\n"

msgInvalidN:
        .string "Invalid table size. Exiting.\n"

// ======
// BSS 
// ======
        .bss
        .align 4

grid:                                               // 2D array
        .skip   GRID_BYTES

occurrences:                                        // array of Occurrence structs
        .skip   MAX_OCC * O_SIZE

N_value:                                            // stores chosen N
        .word   0

curr_digit_value:                                   // stores current digit
        .word   0

// ==============
// Main Section
// ==============
        .text
        .balign 4

main:
        stp     x29, x30, [sp, -16]!
        mov     x29, sp

        ldr     x0, =promptN
        bl      printf                              // Print "Enter the size of the table: "

        ldr     x0, =fmtInt                         // "%d"
        ldr     x1, =N_value
        bl      scanf                               // scanf("%d", &N_value)

        ldr     w19, [N_value]                      // Load N into w19 for convenience

        // Validate N: must be between 1 and MAX_N
        cmp     w19, #1
        blt     invalid_N                           // if N < 1

        cmp     w19, #MAX_N
        bgt     invalid_N                           // if N > MAX_N

        // Using srand to generate random nums
        mov     x0, #0                              // time(NULL)
        bl      time                                // x0 = time(NULL)
        bl      srand                               // srand(time)

        // Creating Grid
        ldr     x0, =grid                           // x0 = &grid[0][0]
        mov     w1, w19                             // w1 = N
        bl      init_grid

        // Printing Grid
        ldr     x0, =grid
        mov     w1, w19
        bl      print_grid

        // Branch to main loop for searching digits
        b       main_loop

invalid_N:
        ldr     x0, =msgInvalidN
        bl      printf
        b       main_end

//============================
// Loop to search for digits
//============================
main_loop:
        ldr     x0, =promptDigitSearch              // Ask user which bamboo type it wants
        bl      printf

        // read digit and assign to curr_digit_value
        ldr     x0, =fmtInt
        ldr     x1, =curr_digit_value
        bl      scanf

        ldr     w20, [curr_digit_value]             // w20 = digit

        // Quit if digit < 0
        cmp     w20, #0
        blt     main_end

        // Call search_and_store to find all occurrences
        ldr     x0, =grid
        mov     w1, w19                             // N
        mov     w2, w20                             // digit to search
        ldr     x3, =occurrences
        bl      search_and_store

        mov     w21, w0                             // w21 = count

        // Prints how many bamboo type is there
        ldr     x0, =fmtCount                       // format string
        mov     w1, w20                             // digit we searched for
        mov     w2, w21                             // count
        bl      printf

        // Print each occurrence:
        mov     w23, #0                             // idx = 0
        ldr     x22, =occurrences                   // x22 = base of occurrences array

print_occ_loop:
        cmp     w23, w21                            // while (idx < count)
        b.ge    print_occ_done

        // Compute &occurrences[idx]
        mov     w24, w23                            // w24 = idx
        uxtw    x24, w24                            // zero-extend to 64-bit
        lsl     x24, x24, #3                        // x24 = idx * O_SIZE (8 bytes)
        add     x25, x22, x24                       // x25 = &occurrences[idx]

        // Load row and col
        ldr     w2, [x25, #O_ROW]                   // w2 = row
        ldr     w3, [x25, #O_COL]                   // w3 = col

        ldr     x0, =fmtOccurence
        add     w1, w23, #1                         // w1 = idx + 1  (1-based index)
        bl      printf

        add     w23, w23, #1                        // idx++
        b       print_occ_loop

print_occ_done:
        b       main_loop                           // Branch for next value

// =======================================
// Fills NxN grid with random digits 0–9
// =======================================
init_grid:
        stp     x29, x30, [sp, -16]!
        mov     x29, sp

        // Save arguments into registers
        mov     x9, x0                              // x9 = base address of grid
        mov     w10, w1                             // w10 = N

        mov     w11, #0                             // row = 0

init_row_loop:
        // if (row >= N) break;
        cmp     w11, w10
        b.ge    init_done

        mov     w12, #0                             // col = 0

init_col_loop:
        // if (col >= N) go to next row
        cmp     w12, w10
        b.ge    init_next_row

        // Generate random digit 0–9
        bl      rand                                // w0 = rand()

        mov     w1, #10                             // divisor = 10
        udiv    w2, w0, w1                          // w2 = rand / 10
        msub    w0, w2, w1, w0                      // w0 = rand - (w2*10) = rand % 10

        // Compute &grid[row][col]
        mul     w3, w11, w10                        // w3 = row * N
        add     w3, w3, w12                         // w3 = row*N + col
        lsl     x3, x3, #2                          // x3 = (row*N + col) * 4
        add     x3, x9, x3                          // x3 = &grid[row][col]

        str     w0, [x3]                            // grid[row][col] = digit

        add     w12, w12, #1                        // col++
        b       init_col_loop

init_next_row:
        add     w11, w11, #1                        // row++
        b       init_row_loop

init_done:
        ldp     x29, x30, [sp], 16
        ret

// ================================
// Prints NxN table of random ints
// ================================
print_grid:
        stp     x29, x30, [sp, -16]!
        mov     x29, sp

        // Save arguments
        mov     x9, x0                              // x9 = base of grid
        mov     w10, w1                             // w10 = N

        mov     w11, #0                             // row = 0

print_row_loop:
        // if (row >= N) done
        cmp     w11, w10
        b.ge    print_done

        mov     w12, #0                             // col = 0

print_col_loop:
        // if (col >= N) end of row
        cmp     w12, w10
        b.ge    print_row_end

        // Load grid[row][col]
        mul     w3, w11, w10                        // w3 = row * N
        add     w3, w3, w12                         // w3 = row*N + col
        lsl     x3, x3, #2                          // x3 = (row*N + col) * 4
        add     x3, x9, x3                          // x3 = &grid[row][col]
        ldr     w4, [x3]                            // w4 = grid[row][col]

        // print the value
        ldr     x0, =fmtElem                        // format "%d "
        mov     w1, w4                              // value
        bl      printf

        add     w12, w12, #1                        // col++
        b       print_col_loop

print_row_end:
        // End of row: print newline
        ldr     x0, =fmtNL
        bl      printf

        add     w11, w11, #1                        // row++
        b       print_row_loop

print_done:
        ldp     x29, x30, [sp], 16
        ret

// ============================================
// search and store for count of occurrences
// ============================================
search_and_store:
        stp     x29, x30, [sp, -16]!
        mov     x29, sp

        // Save arguments
        mov     x9, x0                              // grid base
        mov     w10, w1                             // N
        mov     w11, w2                             // digit to search
        mov     x12, x3                             // occurrences base

        mov     w13, #0                             // count = 0
        mov     w14, #0                             // row = 0

search_row_loop:
        cmp     w14, w10                            // check if row >= N
        b.ge    search_done

        mov     w15, #0                             // col = 0

search_col_loop:
        cmp     w15, w10                            // check if col >= N
        b.ge    next_search_row

        // Load grid[row][col]
        mul     w3, w14, w10                        // row * N
        add     w3, w3, w15                         // row*N + col
        lsl     x3, x3, #2                          // *4
        add     x3, x9, x3                          // x3 = &grid[row][col]
        ldr     w4, [x3]                            // w4 = grid[row][col]

        // Check if (grid[row][col] == digit)
        cmp     w4, w11
        b.ne    not_match

        // If match: Compute &occurrences[count]
        mov     w5, w13                             // index = count
        uxtw    x5, w5                              // zero-extend to 64-bit
        lsl     x5, x5, #3                          // *8 (O_SIZE = 8)
        add     x6, x12, x5                         // x6 = &occurrences[count]

        str     w14, [x6, #O_ROW]                   // Store row
        str     w15, [x6, #O_COL]                   // Store col

        add     w13, w13, #1                        // count++

not_match:
        add     w15, w15, #1                        // col++
        b       search_col_loop

next_search_row:
        add     w14, w14, #1                        // row++
        b       search_row_loop

search_done:
        mov     w0, w13                             // Return count in w0

        ldp     x29, x30, [sp], 16
        ret

main_end:
        ldp     x29, x30, [sp], 16
        mov     w0, #0                              // return 0
        ret