TASK:

Write and upload a RISC-V assembly program source code that traverses from the head of a circular doubly-linked list and print the corresponding node values until it reaches back to the head.

---
The list that must be build and printed:

NODE1 (H)               NODE2                NODE3                NODE4 (T)
+----------+     +--> +----------+     +--> +----------+     +--> +----------+
| val = R  |     |    | val = I  |     |    | val = S  |     |    | val = C  |
| next-----------+    | next ----------+    | next ----------+    | next ---------+
| prev     | <--------| prev     | <--------| prev     | <--------| prev     |    |
+----------+          +----------+          +----------+          +----------+    |
^                                                                                 |
|                                                                                 |
+---------------------------------------------------------------------------------+

Doubly-linked list is a structure that consists of addresses pointing to the previous and subsequent node addresses. The next-address of a tail (T) node is the head (H) node, and the prev-address of a head node is the tail node.

---
Node structure:

+-----------------------------------------------+
| val*  (8 bit): node-value                   |
| next  (32 bits): address of the next node     |
| prev  (32 bits): address of the previous node |
+-----------------------------------------------+

Program must contain of at least the following functionalities:

---
- alloc_node()
  
  args:
  
  a0: val

  description:
  
  Allocates memory for an empty node structure, sets val to value specified in (a0)
  next and prev values must be not NULL and set to itself

  return:
  
  starting address of the allocated node

---
- add_tail()
  
  args:
  
  a0: address of head node
  
  a1: address of the new node

  description:
  
  adds the new node (a1) to the tail of a list that
  starts from head node (a0)

---
- del_node()
  
  args:
  
  a0: address of head node
  
  a1: address of node to be deleted

  description:
  
  deletes node with address (a1) from list
  starting from head node (a0)

  return:
  
  (-1) if the tobe-deleted node isn't found or
  list head node address, otherwise.

---
- print_list()
  
  args:
  
  a0: address of head node

  description:
  
  traverses every node of a list starting from head (a0)  and prints node->val to the terminal

  return:
  
  (-1) at first print fail or the number of bytes written at last

---
Program workflow hint (using only aforementioned functions):
- Create head node with ASCII value 'R'
- Add node with ASCII value 'V' to the tail
- Add node with ASCII value 'I' to the tail
- Add node with ASCII value 'S' to the tail
- Add node with ASCII value 'C' to the tail
- Traverse the list nodes and print their value
- Remove the node with 'V' value from the list
- Exit with exit code 0

---
Notes:
- Use only ABI names for the registers
- For debugging, see gdb program basic calls
- Functions (returning values) must be always checked for error. 
  if returns error value the program must terminate
