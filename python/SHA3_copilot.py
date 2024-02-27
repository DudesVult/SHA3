import io
import binascii
import math 

Digest = 1600
c = []
bins = '1100'
SHA3_mode = 256
cnt = 0
WD = math.floor((2*SHA3_mode)/64)
const = math.floor((Digest-2*SHA3_mode)/64)

with io.open(f'Test.txt', encoding='utf-8') as file:
    for line in file:
        c.append(line)

def HID(matrix):
    for i in range(0, len(matrix)):
        print(matrix[i])
    
def H2B(bins):
    z  = f'{int(bins, 2):X}'
    return z
    
#print(H2B(bins))

input_string = c[0]

# Используем list comprehension для разделения строки на подстроки по 8 символов
substrings = [input_string[i:i+16] for i in range(0, len(input_string), 16)]

subcnt = len(substrings)
steps = math.ceil(subcnt/const)

last_substrings_len = len(substrings[subcnt-1])
substrings[subcnt-1] = '06' + substrings[subcnt-1]
substrings[subcnt-1] = substrings[subcnt-1].rjust(16, '0') #Дополнение нулями

# Выводим полученные подстроки
for z in range(0,subcnt):
    print(substrings[z])
print('.')

# # Выводим полученные подстроки
# for z in range(0,steps):
#     if (z < steps-1):
#         for i in range(0,const):
#             print(substrings[(z*const)+i])
#         for i in range(0,WD):
#             print('0000000000000000')
#         print('+')
#     else:
#         x = subcnt-(const*z)
#         for i in range(0,x):
#             print(substrings[(z*const)+i])
#         for j in range(x+1,const):
#             print('0000000000000000')
#         # print('8000000000000000')    # padding, который дальше не нужен
#         # for i in range(1,WD):
#         #     print('0000000000000000')
#         print('.')
