import argparse
import os
import sys
import pandas
import math
import numpy
from pprint import pprint
from tabulate import tabulate


def parser():
    parse = argparse.ArgumentParser(
        formatter_class=argparse.RawDescriptionHelpFormatter,
        description='A script to trans markdown file to SpreadT`s datasheet.',
        epilog="""
Example:
    sys.argv[0] -version
    sys.argv[0] -help
    sys.argv[0] -md xx.md -excel xx.xlsx -output xx.md

                                                by sheyiqi
                                                2026/05/08

        """)
    
    parse.add_argument("-version", action="version", version="{} 1.0".format(sys.argv[0]))
    parse.add_argument("-md", help="specify a input markdown file name.", required=True)
    parse.add_argument("-excel", help="specify a excel file.", required=True)
    parse.add_argument("-output", help="specify a output markdown file name.", required=True)
    args = parse.parse_args()
    print(args)
    md = args.md
    if os.path.exists(md):
        pass
    else:
        print("{} not exists.".format(md))
    excel = args.excel.replace('"', "")
    if os.path.exists(excel):
        pass
    else:
        print("{} not exists.".format(excel))
    output = args.output
    return md, excel, output

def get_table_from_excel(excel_file):
    table_dict = dict()
    for sheet_name in (pandas.ExcelFile(excel_file).sheet_names):
        if sheet_name.startswith("Table"):
            excel_file_data = pandas.DataFrame(pandas.read_excel(excel_file, sheet_name=sheet_name, dtype=str))
            excel_file_data['Table Name'] = excel_file_data['Table Name'].ffill()
            md_table_name = list(excel_file_data['Table Name'])[0]
            excel_file_data = excel_file_data.drop('Table Name', axis=1)
            if "Memory Compiler 定义" in md_table_name:
                md_table_cont = tabulate(excel_file_data, headers="keys", tablefmt="grid", showindex=False, maxcolwidths=(10,30,20), colalign=("left","left","left"))
            elif "SRAM Bitcell 定义" in md_table_name:
                md_table_cont = tabulate(excel_file_data, headers="keys", tablefmt="grid", showindex=False, maxcolwidths=(10,10,10,10,10,10,10,10,10,10), colalign=("left","left","left","left","left","left","left","left","left","left"))
            elif "容量范围定义" in md_table_name:
                md_table_cont = tabulate(excel_file_data, headers="keys", tablefmt="grid", showindex=False, maxcolwidths=(10,10,10,10,10,10,10,10,10), colalign=("left","left","left","left","left","left","left","left","left"))
            elif "Corner" in md_table_name:
                md_table_cont = tabulate(excel_file_data, headers="keys", tablefmt="grid", showindex=False, maxcolwidths=(25,10,10,10,10,20), colalign=("left","left","left","left","left","left"))
            elif "View" in md_table_name:
                md_table_cont = tabulate(excel_file_data, headers="keys", tablefmt="grid", showindex=False, maxcolwidths=(20,70), colalign=("left","left"))
            elif "测试片开发计划" in md_table_name:
                md_table_cont = tabulate(excel_file_data, headers="keys", tablefmt="grid", showindex=False, maxcolwidths=(20,70,20,20), colalign=("left","left","left","left"))
            else:
                md_table_cont = tabulate(excel_file_data, headers="keys", tablefmt="grid", showindex=False, maxcolwidths=(15,15,70), colalign=("left","left","left",))
            table_dict[md_table_name] = md_table_cont + "\n\n" + md_table_name
    return table_dict


def update_md(input, output, table_dict):
    with open (input, "r", encoding="utf-8") as fr:
        lines = fr.read()
    for key, value in table_dict.items():
        lines = lines.replace("{}".format(str(key)), str(value))
    with open(output, "w", encoding="utf-8") as fw:
        fw.write(lines)


def main():
    md, excel, output = parser()
    table_dict = get_table_from_excel(excel)
    update_md(md, output, table_dict)


if __name__ == "__main__":
    main()