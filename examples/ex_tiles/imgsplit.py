import re

colors = re.compile(r'(\d+)\s+(\d+)\s+(\d+)\s+(\d+)')
index = re.compile(r'(\d+)')

with open("tiles.raw", "r") as source:
    with open("tiles_pal.asm", "w") as palette:
        palette.write("tiles_clut_start:\n")
        # Read the signature line and ignore it
        line = source.readline()

        # Read the begin palette line and ignore it
        line = source.readline()

        count = int(source.readline())

        for x in range(1, count):
            color_line = source.readline()
            color_matches = colors.match(color_line)
            if color_matches:
                red = int(color_matches.group(1))
                green = int(color_matches.group(2))
                blue = int(color_matches.group(3))
                palette.write("\t.byte ${0:02X}, ${1:02X}, ${2:02X}, $00\n".format(blue, green, red))
        palette.write("tiles_clut_end:\n")

    # Skip to the indices
    while not line.startswith("begin indices"):
        line = source.readline()

    with open("tiles_pix.asm", "w") as pixels:
        pixels.write("tiles_img_start:")
        first_pixel = 1
        count = 0
        while not line.startswith("end indices"):
            line = source.readline()
            if not line.startswith("end indices"):
                 index_matches = index.findall(line)
                 if index_matches:
                     for index_match in index_matches:
                         if first_pixel:
                             pixels.write("\n\t.byte ${0:02X}".format(int(index_match)))
                             first_pixel = 0
                             count = count + 1
                         else:
                             if count == 10:
                                 first_pixel = 1
                                 count = 0
                             else:
                                 count = count + 1
                             pixels.write(", ${0:02X}".format(int(index_match)))
        pixels.write("\ntiles_img_end:")
