data = [x for x in range(320*240)]

for y in range(0, 240):
    for x in range(0, 320):
        data[y * 320 + x] = y

with open('gradient.raw', 'wb') as file:
    file.write(bytes(data))
