Write a program that reads a text file into memory, performs the following actions on the text, and saves the contents of the memory to a new file.

Actions:
- Count and print on the screen how many sentences are in the text
- Count and print on the screen how many words are in the text
- Count and print on the screen how many uppercase/lowercase letters are in the text
- Count and print on the screen how many letters of each Latin alphabet are in the text
- Replace all letters in the text that start with the first letter of your name with the letter that starts with your last name. If the letter is Lithuanian, then replace it with a Latin letter. Save the changed text in a new file

Requirements:
- Each action must be performed in a separate function
- Printing must be performed only after all actions have been performed
- File names must be stored in the .rodata memory segment
- 0x00 must be used as the end-of-text indicator
- Minimum text file size: 1024 bytes
