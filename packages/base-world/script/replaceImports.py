import sys

def replace_imports(file_path):
    with open(file_path, 'r') as file:
        lines = file.readlines()

    with open(file_path, 'w') as file:
        for line in lines:
            if './' in line and '.sol' in line:
                # Extract the contract name from the line
                contract_name = line.split('/')[-1].split('.sol')[0]

                # Replace the line with the desired import
                new_import = f'import {{ {contract_name} }} from "@tenet-base-world/src/codegen/world/{contract_name}.sol";\n'
                file.write(new_import)
            else:
                file.write(line)

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("Usage: python script_name.py <path_to_file>")
        sys.exit(1)

    file_path = sys.argv[1]
    replace_imports(file_path)