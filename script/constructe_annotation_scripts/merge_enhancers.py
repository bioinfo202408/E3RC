import sys
import pandas as pd
import numpy as np
import csv

if len(sys.argv) < 2:
    print("Please provide one or more file names.")
    sys.exit(1)

pwdlist=[]

# Iterate through the command-line arguments starting from the second argument
for arg in sys.argv[1:-1]:
    pwdlist.append(arg)

def clean_table(pwd):
    listchr=['chr1','chr2','chr3','chr4','chr5','chr6','chr7','chr8','chr9','chr10','chr11','chr12','chr13','chr14','chr15','chr16','chr17','chr18','chr19','chrX','chrY']
    if "csv" in pwd:
        df1_all = pd.read_csv(pwd,header= 0)
    else:
        df1_all = pd.read_table(pwd,header= 0)
    print("read_sucess")
    df1_all['source']=pwd
    df1=df1_all[['chr','start','end','length','abs_summit','source']]
    df1_clean = df1.loc[df1['chr'].isin(listchr)]
    df1_without146 = df1_clean.loc[df1_clean['length'] > 146 ]
    print(pwd)
    return df1_without146
def index(i,df):
    k = df.loc[i,'MergeTo']
    while k != -1:
        i=k
        k= df.loc[i,'MergeTo']
    return i

tablelist=[]
for i in pwdlist:
    tablelist.append(clean_table(i))
df_without146=pd.concat(tablelist, axis=0, ignore_index=True)
df_sorted = df_without146.sort_values(by=['chr', 'abs_summit'], ascending=True)
df_sorted.insert(6,'MergeTo',np.zeros(len(df_sorted))-1)
df_sorted.set_axis(range(0,len(df_sorted)))

flag = 'chr1'
listchr=[0]
for i in range(0,len(df_sorted)):
    if df_sorted.loc[i,'chr'] != flag:
        flag = df_sorted.loc[i,'chr'] 
        listchr.append(i)
listchr.append(len(df_sorted))

for i in range(0,21):
    Start = listchr[i]
    End = listchr[i+1]
    for j in range(Start,End):
        for k in range(j+1,End):
            if abs( df_sorted.loc[k,'abs_summit'] - df_sorted.loc[j,'abs_summit'])<= 100:
                df_sorted.loc[k,'MergeTo'] = index(j,df_sorted)
            else: break


listarray=np.array(df_sorted['MergeTo'])
uniquearray = np.unique(listarray)
uniquelist=uniquearray.tolist()
df_merged=df_sorted[df_sorted['MergeTo'] == -1]
merged_co = df_merged.copy()


for i in range(1,len(uniquelist)):
    df_temp = df_sorted.loc[df_sorted ['MergeTo'] == uniquelist[i]]
    add = df_sorted.loc[uniquelist[i],]
    dicto = add.to_dict()
    df_temp = df_temp.append(dicto,ignore_index=True)
    df_max = df_temp.sort_values(by=['end'], ascending=False)
    df_min = df_temp.sort_values(by=['start'], ascending=True)
    start = df_min.loc[df_min.index[0],'start']
    end = df_max.loc[df_max.index[0],'end']
    merged_co.loc[uniquelist[i],'start'] = start
    merged_co.loc[uniquelist[i],'end'] = end

merged_co.to_csv(sys.argv[-1],index=False)
