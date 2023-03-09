
# ROMAN NUMERAL CONVERTER

# Usage:
# 1. Ensure "Settings -> Program arguments provided to program" is enabled
# 2. Ensure "delayed branching" is unchecked
# 3. Assemble program
# 4. Enter argument into program arguments textbox
# 5. Run!

# ===== MACRO DEFINITIONS =======
.macro push(%t)
  addi sp sp -4
  sw %t (sp)
.end_macro

.macro pop(%t)
  lw %t (sp)
  addi sp sp 4
.end_macro

.macro print_str(%str)
  li a7 4
  la a0 %str
  ecall
.end_macro

.macro print_char(%c)
  mv a0 %c
  li a7 11
  ecall
.end_macro

.macro exit
  li a7 10
  ecall
.end_macro

.data
youEntered: .asciz "You entered the Roman numerals:\n"
binary:     .asciz "The binary representation is:\n"
binary0b:   .asciz "0b"
error:      .asciz "Error: Invalid program argument."
newline:    .asciz "\n"

.text

# ===== PROGRAM START ======
main:
  # Program argument array stored in a1 on startup
  mv t0 a1

  # Print user argument
  print_str(youEntered)
  lw a0 (t0)
  li a7 4
  ecall
  
  # t0 = input string
  lw t0 (t0)

  # Init running sum
  li s0 0

# ======= CONVERSION TO INTEGER ==========
# for every char:
#   if current char < next char:
#     add to running sum
#   else:
#     sub from running sum
#   if running sum ever goes negative:
#     invalid input received

# == REGISTERS USED ==
# t0: Program arguments array
# t1: Running sum
# t2: Current character
# t3: Next character
# s0: Running sum

charLoop:
  # Check if running sum is invalid
  # (If it ever goes negative, it's invalid)
  blez s0 invalidArgument

  lbu t2 0(t0) # Current char
  beqz t2 charLoopExit
  lbu t3 1(t0) # Next char
  addi t0 t0 1

  # Convert current
  mv a0 t2
  jal convertChar
  mv t2 a0
 
  # Convert next
  mv a0 t3
  jal convertChar
  mv t3 a0

  bge t2 t3 currentGreaterOrEquals

  # If current < next, sub from running sum
  currentLessThan:
    sub s0 s0 t2
    b charLoop

  # If current >= next, add to running sum
  currentGreaterOrEquals:
    add s0 s0 t2
    b charLoop

charLoopExit:
  print_str(newline)
  print_str(newline)
  print_str(binary)
  print_str(binary0b)
  mv t0 s0
  li t3 0

# ======= CONVERSION TO BINARY ==========
# the move is:
#   - isolate bit 0
#   - push either '1' or '0' to the stack
#   - shift to the right by 1
#   - increment count
# once value == 0, you're done converting to binary
# now pop things off the stack and print them

# == REGISTERS USED ==
# t0 integer
# t1 isolated 0 bit
# t2 count
# t3 tmp

convertBinaryLoop:
  beqz t0 printBinaryLoop

  andi t1 t0 1  # Isolate bit 0, store in t1
  srli t0 t0 1  # Shift t0 to the right
  addi t2 t2 1  # Increment count

  # If bit 0 == 0, print zero
  # If bit 1 == 1, print one
  beqz t1 printZero

  printOne:
    li t3 '1'
    push(t3)
    b convertBinaryLoop

  printZero:
    li t3 '0'
    push(t3)
    b convertBinaryLoop

printBinaryLoop:
  beqz t2 exitProgram
  pop(a0)
  print_char(a0)
  addi t2 t2 -1
  b printBinaryLoop

exitProgram:
  print_str(newline)
  exit

# Subroutine to convert a single roman numeral to integer.
# Arguments:
#   a0: Character to convert
# Return values:
#   a0: Converted integer
convertChar:
  push(s0)

  beqz a0 null
  li s0 'I'
  beq a0 s0 one
  li s0 'V'
  beq a0 s0 five
  li s0 'X'
  beq a0 s0 ten
  li s0 'L'
  beq a0 s0 fifty
  li s0 'C'
  beq a0 s0 onehundred
  li s0 'D'
  beq a0 s0 fivehundred
  b convertCharError

  null:
    li a0 0
    b convertCharEnd

  one:
    li a0 1
    b convertCharEnd

  five:
    li a0 5
    b convertCharEnd

  ten:
    li a0 10
    b convertCharEnd

  fifty:
    li a0 50
    b convertCharEnd

  onehundred:
    li a0 100
    b convertCharEnd

  fivehundred:
    li a0 500
    b convertCharEnd

  convertCharError:
    b invalidArgument

  convertCharEnd:
  pop(s0)
  ret

invalidArgument:
  print_str(newline)
  print_str(newline)
  print_str(error)
  print_str(newline)
  exit
