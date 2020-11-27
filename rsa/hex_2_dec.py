filename = str(input("Enter filename: "))

with open(filename, "r") as file:
    hex_str = file.read().split('\n')
    # print(hex_str)

hex_str = list(map(lambda x: x.replace(' ', ''), hex_str))
hex_str = ''.join(hex_str)
hex_str = hex_str[3:]
hex_str = hex_str.replace(':', '')

print(int(hex_str, 16))