
import csv

with open('io_page_0_tab.tex', 'w') as outfile:
    outfile.write("\\begin{table}\n")
    outfile.write("    \\begin{center}\n")
    outfile.write("        \\begin{tabular}{|c|c|l|} \\hline\n")
    outfile.write("            Start & End & Purpose \\\\ \\hline \\hline\n")

    with open('io_page_0.csv') as csvfile:
        io_blocks = csv.reader(csvfile)
        for device in io_blocks:
            outfile.write("            \\verb+{0}+ & \\verb+{1}+ & {2} \\\\ \\hline\n".format(device[0], device[1], device[2]))

    outfile.write("        \\end{tabular}\n")
    outfile.write("        \\caption{I/O Page 0 Addresses}\n")
    outfile.write("        \\label{tab:io_page_0}\n")
    outfile.write("    \\end{center}\n")
    outfile.write("\\end{table}\n")
