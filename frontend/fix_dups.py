import os, glob

for f in glob.glob('lib/**/*.dart', recursive=True):
    with open(f, 'r') as file:
        lines = file.read().split('\n')
    
    # Check if exactly duplicated
    if len(lines) % 2 == 1: # account for trailing empty line
        half = len(lines) // 2
        if lines[:half] == lines[half:-1]:
            print(f"Fixing {f}")
            with open(f, 'w') as out:
                out.write('\n'.join(lines[:half]) + '\n')
