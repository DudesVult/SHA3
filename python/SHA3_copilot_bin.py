import io
import binascii
import math 

c = []
bins = '0110'

with io.open(f'Test_bin.txt', encoding='utf-8') as file:
    for line in file:
        c.append(line)

def HID(matrix):
    for i in range(0, len(matrix)):
        print(matrix[i])
    
def H2B(bins):
    z  = f'{int(bins, 2):X}'
    return z
    
input_string = c[0]

# Используем list comprehension для разделения строки на подстроки по 8 символов
substrings = [input_string[i:i+64] for i in range(0, len(input_string), 64)]

subcnt = len(substrings)
steps = math.ceil(subcnt/const)

last_substrings_len = len(substrings[subcnt-1])
substrings[subcnt-1] = '0110' + substrings[subcnt-1]
substrings[subcnt-1] = substrings[subcnt-1].rjust(16, '0') #Дополнение нулями

# Выводим полученные подстроки
for z in range(0,subcnt):
    print(hex(substrings[z]))
print('.')