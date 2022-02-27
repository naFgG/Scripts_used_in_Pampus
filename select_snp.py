import os
import argparse
from random import randint

parser = argparse.ArgumentParser(usage='python <PATH to this script>/select_snp.py [-p/P] [-i/i] [-o/O]',
                                 description='This script was wrote with Python (version 3.8), so it need for Python '
                                             'in your environment,'
                                             ' and it aim to selecting a SNP randomly while a locus have several SNP '
                                             'sites,'
                                             'finally, it will generate a filterd VCF with predefined prefix.')
parser.add_argument('-p', dest='p', help='your working directory', required=True)
parser.add_argument('-i', dest='i', help='a VCF format file as input file', required=True)
parser.add_argument('-o', dest='o', help='a prefix for output file', required=True)
args = parser.parse_args()

os.chdir(f'{args.p}')
os.system(f'vcftools --vcf {args.i} --out {args.o} --remove-indels --max-missing 0.8 --min-meanDP 6 --kept-sites')
os.system(f'mv {args.o}.log kept_sites.log')

with open(f'{args.o}.kept.sites', 'r') as in_file:
    raw = in_file.readlines()
    raw.pop(0)
    i = 0
    only_gene = list()
    tem = list()
    selected = list()
    for each in raw:
        split = each.split('\t')
        only_gene.append(split[0])
        if len(only_gene) == 1:
            tem.append(raw[i])
        elif len(only_gene) > 1:
            if len(tem) == 0:
                tem.append(raw[i])
            elif only_gene[i] == only_gene[i-1]:
                tem.append(raw[i])
                # 最后一组基因如果有重复，进入此判断
                if i == (len(raw) - 1):
                    len2 = len(tem)
                    ran_choice = tem[randint(0, (len2 - 1))]
                    selected.append(ran_choice)
            else:
                len2 = len(tem)
                ran_choice = tem[randint(0, (len2 - 1))]
                selected.append(ran_choice)
                tem = list()
                tem.append(raw[i])
                # 最后一组基因如果只有一个，进入此判断
                if i == (len(raw) - 1):
                    selected.append(raw[i])
        i += 1

with open('selected_snp.txt', 'a+') as result_file:
    for each in selected:
        result_file.writelines(each)

os.system(f'vcftools --vcf {args.i} --out {args.o} --positions selected_snp.txt --recode --recode-INFO-all')
os.system(f'mv {args.o}.recode.vcf {args.o}.vcf')
os.system(f'mv {args.o}.log recode.log')

print(f'''********************************************************************
    Select SNPs Completed, total {len(selected)} loci (SNPs) were remained
    The filtered file is {args.o}.vcf
********************************************************************''')
