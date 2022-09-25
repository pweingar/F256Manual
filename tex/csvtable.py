
import csv

with open('io_page_1_tab.tex', 'w') as outfile:
    outfile.write("\\begin{table}\n")
    outfile.write("\\begin{tabular}{|c|l|} \\hline\n")

    with open('io_page_1.csv') as csvfile:
        io_blocks = csv.reader(csvfile)
        for device in io_blocks:
            outfile.write("\\verb+{0}+ & \multirows{{2}}{{*}}{{{1}}} \\\\ \\cline{{1-1}}\n".format(device[0], device[2]))
            outfile.write("\\verb+{0}+ & \\\\ \\hline\n".format(device[1]))

    outfile.write("\\caption{I/O Page 1 Addresses}\n")
    outfile.write("\\label{tab:io_page_1}\n")
    outfile.write("\\end{tabular}\n")
    outfile.write("\\end{table}\n")
