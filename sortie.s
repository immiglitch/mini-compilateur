.text
.globl main
main:
 addiu $sp, $sp, -8
 sw $fp, 4($sp)
 sw $ra, 0($sp)
 move $fp, $sp
 la $v0, str_2
 addiu $sp, $sp, -4
 sw $v0, 0($sp)
 jal print_string
 addiu $sp, $sp, 4
 jal _gets
 addiu $sp, $sp, 0
 addiu $sp, $sp, -4
 sw $v0, 0($sp)
 la $v0, str_1
 addiu $sp, $sp, -4
 sw $v0, 0($sp)
 jal print_string
 addiu $sp, $sp, 4
 lw $v0, -4($fp)
 addiu $sp, $sp, -4
 sw $v0, 0($sp)
 jal print_string
 addiu $sp, $sp, 4
  li $v0, 0
 move $sp, $fp
 lw $ra, 0($sp)
 lw $fp, 4($sp)
 addiu $sp, $sp, 8
 jr $ra
 move $sp, $fp
 lw $ra, 0($sp)
 lw $fp, 4($sp)
 addiu $sp, $sp, 8
 jr $ra
_add:
 lw $t0, 0($sp)
 lw $t1, 4($sp)
 addu $v0, $t0, $t1
 jr $ra
_sub:
 lw $t0, 0($sp)
 lw $t1, 4($sp)
 subu $v0, $t0, $t1
 jr $ra
_mul:
 lw $t0, 0($sp)
 lw $t1, 4($sp)
 mul $v0, $t0, $t1
 jr $ra
_div:
 lw $t0, 0($sp)
 lw $t1, 4($sp)
 div $t0, $t1
 mflo $v0
 jr $ra
_mod:
 lw $t0, 0($sp)
 lw $t1, 4($sp)
 div $t0, $t1
 mfhi $v0
 jr $ra
_and:
 lw $t0, 0($sp)
 lw $t1, 4($sp)
 and $v0, $t0, $t1
 jr $ra
_or:
 lw $t0, 0($sp)
 lw $t1, 4($sp)
 or $v0, $t0, $t1
 jr $ra
_not:
 lw $t0, 0($sp)
 xori $v0, $t0, 1
 jr $ra
_xor:
 lw $t0, 0($sp)
 lw $t1, 4($sp)
 xor $v0, $t0, $t1
 jr $ra
_sup:
 lw $t0, 0($sp)
 lw $t1, 4($sp)
 slt $v0, $t0, $t1
 jr $ra
_inf:
 lw $t0, 0($sp)
 lw $t1, 4($sp)
 slt $v0, $t1, $t0
 jr $ra
_eq:
 lw $t0, 0($sp)
 lw $t1, 4($sp)
 xor $t0, $t0, $t1
 sltiu $v0, $t0, 1
 jr $ra
_puti:
 lw $a0, 0($sp)
  li $v0, 1
 syscall
  li $v0, 0
 jr $ra
_geti:
  li $v0, 5
 syscall
 jr $ra
_gets:
 la $a0, global_string_reader
  li $a1, 100
  li $v0, 8
 syscall
 la $v0, global_string_reader
 jr $ra
_getb:
  li $v0, 5
 syscall
 jr $ra
print_string:
 lw $a0, 0($sp)
  li $v0, 4
 syscall
  li $v0, 0
 jr $ra
_putb:
 lw $t0, 0($sp)
  beq $t0, $zero, p_false_base
 la $a0, bool_true
  li $v0, 4
 syscall
 j p_end_base
p_false_base:
 la $a0, bool_false
  li $v0, 4
 syscall
p_end_base:
  li $v0, 0
 jr $ra
print_newline:
  li $a0, 10
  li $v0, 11
 syscall
  li $v0, 0
 jr $ra

.data
bool_true: .asciiz "true"
bool_false: .asciiz "false"
global_string_reader: .space 128
str_2: .asciiz "Entrez votre nom: "
str_1: .asciiz "Bonjour "
