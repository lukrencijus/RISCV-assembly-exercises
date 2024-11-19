Task: Implement Separate push and pop Functions in RISC-V Assembly
Implement separate functions for push and pop in RISC-V assembly. These functions will handle the stack operations independently, allowing you to push a value onto the stack or pop a value from the stack into a register. 

Write a program that demonstrates the functions you have created. The program must consist of at least four functions: main, math, push and pop. The MATH function must make calculations according to the following formula: X=A+B-C-10+D. All parameters A, B, C, D from the main function must be passed to math function via stack. The result must also be returned via the stack. After calculating X, print it to the console from the main function.

Requirements:
        All functions:
            Return address for branch and jump commands is always saved in ra register

            Before using any of the registers, the functions main and math must evaluate which of the function's caller or callee should save the register on the stack. Not valid for push and pop functions.

       main function:
            Input: the initial values of variables A, B, C, D must be read from the .data segment of memory. Variables size: 4 bytes. 

       math function:
            Input: The values from a stack

            Action: Calculate X=A+B-C-10+D

            Return: The value via stack

        push function:
            Input: A value in a register (e.g., a0) that should be stored onto the stack. 

            Action: Store the value (4 bytes) onto the stack and adjust the stack pointer (sp).

        pop function:
            Output: The top value of the stack should be stored into a register (e.g., a0).

            Action: Retrieve one value (4 bytes) from the stack and adjust the stack pointer (sp).

