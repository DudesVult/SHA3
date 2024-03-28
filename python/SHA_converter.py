import sys
import io
import math 

file = sys.argv[1]
width = sys.argv[2]

# file = 'test.bin'
# width = 16
width_str = str(width)
width_num = int(width)

cnt = int(0)
c = []

cnt_c = 0

flag = 0;

name = file[:4]+"_"+width_str + ".bin"

with open(file, encoding='utf-8', errors='ignore') as file:
    for line in file:
        c.append(line)
        
input_string = c[0]
last = '6'

# Используем list comprehension для разделения строки на подстроки по 8 символов
substrings = [input_string[i:i+int(width_num/4)] for i in range(0, len(input_string), int(width_num/4))]

subcnt = len(substrings)

last_substrings_len = len(substrings[subcnt-1])
if (last_substrings_len < int(width_num/4)):
    substrings[subcnt-1] = '6' + substrings[subcnt-1]
    substrings[subcnt-1] = substrings[subcnt-1].rjust(math.ceil(width_num/4), '0') #Дополнение нулями
else:
    flag = 1
    last = last.rjust(math.ceil(width_num/4), '0') #Дополнение нулями
    subcnt += 1
        
f = open(name, "w")
f.write(f"{str(subcnt)}\n")

while cnt_c < subcnt-1:
    f.write(f"{str(substrings[cnt_c])}\n")
    cnt_c += 1

if cnt_c == subcnt-1 and flag == 1:
    f.write(str(last))
    
f.close()