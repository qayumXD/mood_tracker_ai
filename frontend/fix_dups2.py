import glob

for f in glob.glob('lib/**/*.dart', recursive=True):
    with open(f, 'r') as file:
        content = file.read()
    
    lines = content.split('\n')
    
    if len(lines) > 0 and lines[0].startswith('import'):
        first_line = lines[0]
        for i in range(1, len(lines)):
            if lines[i] == first_line:
                print(f"Fixing {f} by cutting at line {i}")
                with open(f, 'w') as out:
                    out.write('\n'.join(lines[:i]))
                break
