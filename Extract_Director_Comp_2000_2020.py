# -*- coding: utf-8 -*-
"""
Created on Tue Jul 20 11:08:04 2020

@author: ps664
"""



import openpyxl
import re
import csv
import urllib
import os
from openpyxl import Workbook
from bs4 import BeautifulSoup
import pandas as pd
import string
import re
import requests
from random import randint
from time import sleep
import numpy as np
import datetime
import io
from xml.etree import ElementTree as et
import os, os.path, sys
import glob
from xml.etree import ElementTree
import  csv
import xml.etree.cElementTree as ET
import time
from datetime import date
import urllib

import tables
from tables import *
from lxml import html
from numpy import nan


import openpyxl
import re
import csv
import urllib
import os
from openpyxl import Workbook
from bs4 import BeautifulSoup

# for Stanford NPL
import nltk
from nltk.tokenize import word_tokenize
from nltk.tag import pos_tag
from nltk.tag import StanfordNERTagger
nltk.download('punkt')
nltk.download('averaged_perceptron_tagger')



def getDuplicateColumns(df):
    '''
    Get a list of duplicate columns.
    It will iterate over all the columns in dataframe and find the columns whose contents are duplicate.
    :param df: Dataframe object
    :return: List of columns whose contents are duplicates.
    '''
    duplicateColumnNames = set()
    # Iterate over all the columns in dataframe
    for x in range(df.shape[1]):
        # Select column at xth index.
        col = df.iloc[:, x]
        # Iterate over all the columns in DataFrame from (x+1)th index till end
        for y in range(x + 1, df.shape[1]):
            # Select column at yth index.
            otherCol = df.iloc[:, y]
            # Check if two columns at x 7 y index are equal
            if col.equals(otherCol):
                duplicateColumnNames.add(df.columns.values[y])
    return list(duplicateColumnNames)


error_n=0
salary=None
stock=None
options=None
dir_names=None
nonequity=None
total_comp=None    
pension=None
other_comp=None
bonus=None
app_frame_full=None
exec_comp=None
year=None

folder="R:\\ps664\\Dr_Becher - DirComp\\8_data_collection\\Code to extract Dir Comp\\adjustments"

os.chdir(folder)


#file = open('no_dir_comp_table.csv')
file = open('trial_2.csv')

csv_f = csv.reader(file, delimiter=',')
i=1


# Loop over all firm-year links in the file 
for row in csv_f:
    i=i+1
    if i==2:
        continue
    
    link=row[5]
    print(i)
    print(link)
    print("File Number:", row[0])
    print("Excel Row Number:", i-1)    
    
    ##### Error Check ####
    #link = 'https://www.sec.gov/Archives/edgar/data/63330/000110465907021062/a07-5810_3def14a.htm'
    
    page = requests.get(link)
    #tree = html.fromstring(page.content)
    html = requests.get(link).content
    soup = BeautifulSoup(html,'lxml')    

    cash=None
    stock=None
    options=None
    dir_names=None
    nonequity=None
    total_comp=None    
    pension=None
    other_comp=None    
    bonus=None
    year=None
    exec_comp=None
 
    table1 = []
    table2 = []
    table3 = []
    table4 = []
    table5 = []
    table1_ = []    
    table2_ = []
    table3_ = []
    table4_ = []
    table5_ = []
    table1__ = []    
    table2__ = []
    table3__ = []
    table4__ = []
    table5__ = []
    
    # Try combination of kewords Salary & Bonus
    table1 = soup.select('table:contains("Fees")')
    table1_ = soup.select('table:contains("FEES")')
    
    table2 = soup.select('table:contains("Earned")')
    table2_ = soup.select('table:contains("earned")')
    table2__ = soup.select('table:contains("EARNED")')
    
    table3 = soup.select('table:contains("Cash")')
    table3_ = soup.select('table:contains("cash")')
    table3__ = soup.select('table:contains("CASH")')
    
    table4 = soup.select('table:contains("Total")') 
    table4_ = soup.select('table:contains("total")') 
    table4__ = soup.select('table:contains("TOTAL")') 
    
    table5 = soup.select('table:contains("Paid")')
    table5_ = soup.select('table:contains("paid")')
    table5__ = soup.select('table:contains("PAID")')
    
    table6 = soup.select('table:contains("Stock")')
    table6_ = soup.select('table:contains("stock")')
    table6__ = soup.select('table:contains("STOCK")')
        
    tables_found=0



    # Stop processing     
    #if i>100:
    #    break
    if "txt" in link:
        continue

    # Try for the whole code below
    try:

    
        # Try combination of kewords Fees, Earned/earned/EARNED, Total/total/TOTAL
        for table in table1:
            if (table in table2) | (table in table2_) | (table in table2__):
                if (table in table4) | (table in table4_) | (table in table4__):  
                    tables_found=tables_found+1
                    if i==3:
                        comp_dataframe=pd.read_html(str(table))
                        exec_comp=comp_dataframe[0]
                    if i>3:
                        a=pd.read_html(str(table))
                        comp_dataframe.append(a[0])
                        exec_comp=a[0]
                    print("Table found 1")    
        

        # Try combination of kewords FEES, Earned/earned/EARNED, Total/total/TOTAL
        if tables_found==0:              
            for table in table1_:
                if (table in table5) | (table in table5_) | (table in table5__):
                    if (table in table4) | (table in table4_) | (table in table4__):
                        tables_found=tables_found+1
                        if i==3:
                            comp_dataframe=pd.read_html(str(table))
                            exec_comp=comp_dataframe[0]
                        if i>3:
                            a=pd.read_html(str(table))
                            exec_comp=a[0]
                            comp_dataframe.append(a[0])
                        print("Table found 2")    
                                
                
        # Try combination of kewords Fees, Paid/paid/PAID, Total/total/TOTAL
        if tables_found==0:        
            for table in table1:
                if (table in table5) | (table in table5_) | (table in table5__):
                    if (table in table4) | (table in table4_) | (table in table4__):
                        tables_found=tables_found+1
                        if i==3:
                            comp_dataframe=pd.read_html(str(table))
                            exec_comp=comp_dataframe[0]
                        if i>3:
                            a=pd.read_html(str(table))
                            exec_comp=a[0]
                            comp_dataframe.append(a[0])
                        print("Table found 2")    
                        
        # Try combination of kewords FEES, Paid/paid/PAID, Total/total/TOTAL
        if tables_found==0:        
            for table in table1_:
                if (table in table5) | (table in table5_) | (table in table5__):
                    if (table in table4) | (table in table4_) | (table in table4__):
                        tables_found=tables_found+1
                        if i==3:
                            comp_dataframe=pd.read_html(str(table))
                            exec_comp=comp_dataframe[0]
                        if i>3:
                            a=pd.read_html(str(table))
                            exec_comp=a[0]
                            comp_dataframe.append(a[0])
                        print("Table found 2")    
                                
         # Try combination of kewords Fees, Cash/cash/CASH, Total/total/TOTAL
        if tables_found==0:        
            for table in table1:
                if (table in table3) | (table in table3_) | (table in table3__):
                    if (table in table4) | (table in table4_) | (table in table4__):
                        tables_found=tables_found+1
                        if i==3:
                            comp_dataframe=pd.read_html(str(table))
                            exec_comp=comp_dataframe[0]
                        if i>3:
                            a=pd.read_html(str(table))
                            exec_comp=a[0]
                            comp_dataframe.append(a[0])
                        print("Table found 3")
                        
         # Try combination of kewords FEES, Cash/cash/CASH, Total/total/TOTAL
        if tables_found==0:        
            for table in table1_:
                if (table in table3) | (table in table3_) | (table in table3__):
                    if (table in table4) | (table in table4_) | (table in table4__):
                        tables_found=tables_found+1
                        if i==3:
                            comp_dataframe=pd.read_html(str(table))
                            exec_comp=comp_dataframe[0]
                        if i>3:
                            a=pd.read_html(str(table))
                            exec_comp=a[0]
                            comp_dataframe.append(a[0])
                        print("Table found 4")

         # Try combination of kewords Fees, Stock/stock/STOCK, Total/total/TOTAL
        if tables_found==0: 
            for table in table1:
                if (table in table6) | (table in table6_) | (table in table6__):                    
                    if (table in table4) | (table in table4_) | (table in table4__):
                        tables_found=tables_found+1
                        if i==3:
                            comp_dataframe=pd.read_html(str(table))
                            exec_comp=comp_dataframe[0]
                        if i>3:
                            a=pd.read_html(str(table))
                            exec_comp=a[0]
                            comp_dataframe.append(a[0])
                        print("Table found 5")    

         # Try combination of kewords FEES, Stock/stock/STOCK, Total/total/TOTAL
        if tables_found==0: 
            for table in table1_:
                if (table in table6) | (table in table6_) | (table in table6__):                    
                    if (table in table4) | (table in table4_) | (table in table4__):
                        tables_found=tables_found+1
                        if i==3:
                            comp_dataframe=pd.read_html(str(table))
                            exec_comp=comp_dataframe[0]
                        if i>3:
                            a=pd.read_html(str(table))
                            exec_comp=a[0]
                            comp_dataframe.append(a[0])
                        print("Table found 5")                           
                        
        # Try combination of kewords Director, Aggregate Compensation, Bonus,
    
        # Check that the website doesn't have table in a list instead of html
        # => Look at the length of the table pulled (dropped those that have less than 3 columns)
        if tables_found==1 and len(exec_comp.columns)<3:
            print("HTML wrong table format")
            continue
    
        # If there is no table found, then skip the rest of the code to the next link
        if tables_found==0:  
            print("No table found")
            frame_full = pd.DataFrame({'file number': row[0], 'gvkey': row[2],  'year_file': row[3], 'year':  row[3],
                     'firm name' : row[4], 'director name' : dir_names, 'cash award': cash,  'stock': stock,
                     'options': options, 'non equity' :  nonequity, 'pension' : pension, 'other comp' : other_comp,
                     'total' :  total_comp, 'table found' : 0 , 'link' : row[5] }, index =[0])          
            if app_frame_full is None:
                app_frame_full=frame_full
            else:   
                app_frame_full=app_frame_full.append(frame_full, ignore_index=True)
            continue
    
    
    
    
        #exec_comp=comp_dataframe[87]
    
        # drop empty rows
        df = exec_comp.dropna(how='all')
    
        # drop duplicate columns    
        df = df.drop_duplicates()
    
        # mark the row at which the table's numberical values start
        # 1. simple cases where director names follow "Name"
        table_start = df.iloc[:,0].str.contains(r'[Nn][Aa][Mm][Ee]', regex=True)
        table_start= table_start.replace(np.nan, False, regex=True)
        t = table_start.index[table_start].tolist()
        
        dir_names=None
        if len(t)>0:
            # if table starts with "Name"
            dir_names=df.iloc[df.index>t,0]         
        else:
            # if "Name" is in the dataframe header
            min_index= min(df.index)
            df.loc[min_index-1] = df.columns
            df = df.sort_index(ascending=True)
            #print(df)    
            table_start = df.iloc[:,0].str.contains(r'[Nn]ame', regex=True)
            table_start= table_start.replace(np.nan, False, regex=True)
            t = table_start.index[table_start].tolist()
            if len(t)>0:
                dir_names=df.iloc[df.index>t,0]  
            else:
                print("Table doesn't start with keyword Name")            
                table_start = df.iloc[:,0].str.contains(r'Director', flags=re.IGNORECASE, regex=True)
                table_start= table_start.replace(np.nan, False, regex=True)
                t = table_start.index[table_start].tolist()
                if len(t)>0:
                    # if table starts with "Director"
                    dir_names=df.iloc[df.index>t,0]  
                else:
                    print("Table doesn't start with keyword Name or Director")            
                   
                    # if table starts with a person's name, search uses Stanford NPL analysis 
                    # Stanford NPL: https://nlp.stanford.edu/software/CRF-NER.shtml#Download   
                    # Stanford NPL download for Python: http://www.nltk.org/
                    # Stanford NPL in terminal: pip install nltk           
                    if dir_names is None:                        
                        # iterate over a row where directors are listed
                        for index, cell in df.iterrows():
                            possible_name=None
                            tokens = nltk.tokenize.word_tokenize(str(cell.iloc[0]))
                            tagged = nltk.pos_tag(tokens)
                            possible_name = [item for t in tagged for item in t] 
                            # mark a cell that containes a name tagged as "NNP"
                            if "NNP" in possible_name:
                                print("director names start in row", index)
                                t = index -1
                                dir_names=df.iloc[df.index>t,0]
                                break
                            
                        # BEFORE if table starts with a name like "John J. Johnson" (misses cases like John Johnson)
                        #dir_names = df.iloc[:,0].str.contains(r'[A-Z][a-z]* [A-Z]. [A-Z][a-z]*', regex=True)
                        #table_start= dir_names.replace(np.nan, False, regex=True)
                        #t = table_start.index[table_start].tolist()
                        #if t !=[]:
                        #    t=min(t)-1
                        #    if dir_names.any() == True :
                        #        dir_names=df.iloc[df.index>t,0]
                        
                        if dir_names is None:
                            # if there is no table start (Name, Director or a Person's name), then skip the link
                            print("No table found")
                            frame_full = pd.DataFrame({'file number': row[0], 'gvkey': row[2],  'year_file': row[3], 'year':  row[3],
                             'firm name' : row[4], 'director name' : dir_names, 'cash award': cash,  'stock': stock,
                             'options': options, 'non equity' :  nonequity, 'pension' : pension, 'other comp' : other_comp,
                             'total' :  total_comp, 'table found' : 0 , 'link' : row[5] }, index =[0])        
                            app_frame_full=app_frame_full.append(frame_full, ignore_index=True)
                            continue            
                      

        
            
        
        
        # Adjust names    
        dir_names= dir_names.replace({"\([0-9]\)":''}, regex=True)   
        dir_names= dir_names.replace({"[0-9][0-9]":''}, regex=True)   
        dir_names= dir_names.replace({"[0-9]":''}, regex=True)   
        dir_names= dir_names.replace({"\*":''}, regex=True)   
        dir_names= dir_names.replace({"\([a-z]\)":''}, regex=True)   
        dir_names= dir_names.replace({"\([A-Z]\)":''}, regex=True)          
    
            
           
        df1 = df
     
    
        # drop missing rows and columns further
        duplicateColumnNames = getDuplicateColumns(df1)
        #print('Duplicate Columns are as follows')
        #for col in duplicateColumnNames:
        #    print('Column name : ', col) 
        newDf = df1.drop(columns=getDuplicateColumns(df1))
        #print("Modified Dataframe", newDf, sep='\n')
          
    
        #Remove all cells with zeros
        newDf = newDf.astype(str)
        
        
        
        
        newDf = newDf.replace('--', '')      
        newDf = newDf.replace('––', '') 
        newDf = newDf.replace('-', '')  
        newDf = newDf.replace('—', '') 
        newDf = newDf.replace('', '')        
        # Get rid of annotations like (1) (6) first (order matters!!)
        newDf= newDf.replace(regex='\([0-9]\)', value= '') 
        # Change numbers in brackets into negatvie numbers next
        newDf= newDf.replace(regex='\(([0-9].*)\)', value= '-\\1')        
        newDf= newDf.replace(regex='\(([0-9].*)', value= '-\\1') 
        # Get rid of annotations like (a) (b) ($) the last or (b  where only part is recorded
        newDf= newDf.replace(regex='\((.*)\)', value= '') 
        newDf= newDf.replace(regex='\(([a-z])', value= '') 

        
        #newDf = newDf.replace('0', '')
        #newDf = newDf.replace('0.0', '')
        newDf= newDf.replace({"\,":''}, regex=True)  


        newDf = newDf.replace('-0-', '')        
        newDf = newDf.replace(')', '')
        newDf= newDf.replace({"\(":''}, regex=True)
        newDf= newDf.replace({"\$":''}, regex=True)        
        newDf = newDf.replace('-)', '')
        newDf = newDf.replace(')', '')
        newDf = newDf.replace('2015 Director Compensation', '')      

    
        #Find type of compensation
        for col in newDf.columns: 
            numbers = newDf[col].str.contains(r'[0-9][0-9][0-9][0-9]', regex=True)
           
            comp1 = newDf[col].str.contains(r'[Yy]ear', regex=True)
            if comp1.any() == True & numbers.any() == True:
                year=newDf[col]
                year=year[year.index>t]
          
            
        cash = None
        cash_an_ret=None
        cash_committee=None
        cash_chair_fee=None
        cash_meet_fee=None
        cash_board_fee=None
        
        stock = None
        stock_rsu = None
        stock_warr = None
        stock_sar = None
        stock_eq = None
        
        option=None
        
        other_comp = None
        other_comp_sub= None
        other_comp_unit= None
        other_comp_tax= None
        other_div=None
        other_def=None
        other_fee = None
       
        nonequity = None
        
        for col in newDf.columns: 
            
            # restrict to checking numbers presence after the header (iloc[1:]) because some headers are indexes like 1,2..15..
            numbers = newDf[col].iloc[1:].str.contains(r'[0-9][0-9]', regex=True)
            
            
            ######## CASH / SALARY SECTION #######
            comp1 = newDf[col].str.contains(r'[Ff][Ee][Ee][Ss]', regex=True)
            comp11 = newDf[col].str.contains(r'[Tt][Oo][Tt][Aa][Ll]', regex=True)
            comp116 = newDf[col].str.contains(r'compensation', flags=re.IGNORECASE, regex=True)

            # look for "Total Fees" first (column summarizing different fees)
            if comp1.any() == True & comp11.any() == True & numbers.any() == True:
                if (comp116.any()==True):
                    print('Total Comp & Fees Paid is TAKEN CARE OF')
                else: 
                    cash=newDf[col]
                    cash=cash[cash.index>t]

            # look for non-standard cash names next
            
            # look for "Annual Retainer"
            comp12 = newDf[col].str.contains(r'annual', flags=re.IGNORECASE, regex=True)
            comp13 = newDf[col].str.contains(r'retainer', flags=re.IGNORECASE, regex=True)
            if comp12.any() == True & comp13.any() == True & numbers.any() == True:
                cash_an_ret=newDf[col]
                cash_an_ret=cash_an_ret[cash_an_ret.index>t]

            # look for "meeting fees"
            comp14 = newDf[col].str.contains(r'meeting', flags=re.IGNORECASE, regex=True)
            comp15 = newDf[col].str.contains(r'fee', flags=re.IGNORECASE, regex=True)
            if comp14.any() == True & comp15.any() == True & numbers.any() == True:
                cash_meet_fee=newDf[col]
                cash_meet_fee=cash_meet_fee[cash_meet_fee.index>t]

            # look for "chairman fees"
            comp16 = newDf[col].str.contains(r'chairman', flags=re.IGNORECASE, regex=True)
            comp17 = newDf[col].str.contains(r'fee', flags=re.IGNORECASE, regex=True)
            if comp16.any() == True & comp17.any() == True & numbers.any() == True:
                cash_chair_fee=newDf[col]
                cash_chair_fee=cash_chair_fee[cash_chair_fee.index>t]

            # look for "committee fees" (avoid cases "committee meeting fees" and "committee chariman fees")
            comp18 = newDf[col].str.contains(r'committee', flags=re.IGNORECASE, regex=True)
            comp19 = newDf[col].str.contains(r'fee', flags=re.IGNORECASE, regex=True)
            if  comp16.all()==False  & comp14.all()==False :
                if comp18.any() == True & comp19.any() == True & numbers.any() == True:
                    cash_committee=newDf[col]
                    cash_committee=cash_committee[cash_committee.index>t]

            # look for "board cash fees "
            comp111 = newDf[col].str.contains(r'board', flags=re.IGNORECASE, regex=True)
            comp112 = newDf[col].str.contains(r'cash', flags=re.IGNORECASE, regex=True)
            comp113 = newDf[col].str.contains(r'fee', flags=re.IGNORECASE, regex=True)
            if comp111.any() == True & comp112.any() == True & comp113.any() == True & numbers.any() == True:
                cash_board_fee=newDf[col]
                cash_board_fee=cash_board_fee[cash_board_fee.index>t]
                
            # Now look for "Cash Fees" but check that a found column is neither of the ones found above (Board Cash Fees)
            comp114 = newDf[col].str.contains(r'fees', flags=re.IGNORECASE, regex=True)
            comp115 = newDf[col].str.contains(r'cash', flags=re.IGNORECASE, regex=True)
            comp116 = newDf[col].str.contains(r'compensation', flags=re.IGNORECASE, regex=True)
            if cash_board_fee is None:
                if comp114.any() == True & comp115.any() == True & numbers.any() == True:
                    if (comp116.any()==True):
                        print('Total Comp & Fees Paid is TAKEN CARE OF')
                    else:                     
                        cash=newDf[col]
                        cash=cash[cash.index>t]
    

            # Only if there is no other data found on cash, use "Fees" as a keyword
            if (cash is None) & (cash_board_fee is None) & (cash_committee is None) & (cash_chair_fee is None) & (cash_meet_fee is None) & (cash_an_ret is None):
                comp114 = newDf[col].str.contains(r'fees', flags=re.IGNORECASE, regex=True)
                if comp114.any() == True & numbers.any() == True:
                    cash=newDf[col]
                    cash=cash[cash.index>t]
                    
               

            # New columns: meeting fees, chairman fees, committee fees, board cash fees               


            ######## BONUS SECTION #######
                  
            comp2 = newDf[col].str.contains(r'[Bb]onus', regex=True)
            if comp2.any() == True & numbers.any() == True:
                bonus=newDf[col]
                bonus=bonus[bonus.index>t] 

            ######## STOCK SECTION #######
            
            comp8 = newDf[col].str.contains(r'[Ss][Tt][Oo][Cc][Kk]', regex=True)
            comp81 = newDf[col].str.contains(r'number', flags=re.IGNORECASE, regex=True)
            comp85 = newDf[col].str.contains(r'option', flags=re.IGNORECASE, regex=True)
            comp84 = newDf[col].str.contains(r'dividend', flags=re.IGNORECASE, regex=True)            

            if (comp85.any()==True) | (comp81.any()==True) | (comp84.any()==True):
                print('stock option award / number/ dividend TAKEN CARE OF')
            else:    
                if comp8.any() == True & numbers.any() == True:
                    stock=newDf[col]
                    stock=stock[stock.index>t] 
                
          
            comp86 = newDf[col].str.contains(r'SAR', regex=True)   
            comp85 = newDf[col].str.contains(r'option', flags=re.IGNORECASE, regex=True)
            if comp86.any() == True & numbers.any() == True:
                if (comp85.any()==True):
                    print('Option / SAR is TAKEN CARE OF')
                else: 
                    stock_sar=newDf[col]
                    stock_sar=stock_sar[stock_sar.index>t] 

            #record RSU 
            comp87 = newDf[col].str.contains(r'RSU', regex=True)            
            if comp87.any() == True & numbers.any() == True:
                stock_rsu=newDf[col]
                stock_rsu=stock_rsu[stock_rsu.index>t] 

            # didn't work for: https://www.sec.gov/Archives/edgar/data/716006/000119312509070061/ddef14a.htm#toc14976_12
            comp82 = newDf[col].str.contains(r'Restricted', flags=re.IGNORECASE, regex=True) 
            comp83 = newDf[col].str.contains(r'Share', flags=re.IGNORECASE, regex=True)            
            if comp82.any() == True & comp83.any() == True & numbers.any() == True:
                stock_rsu=newDf[col]
                stock_rsu=stock_rsu[stock_rsu.index>t] 


            comp85 = newDf[col].str.contains(r'warrant', flags=re.IGNORECASE, regex=True)            
            if comp85.any() == True & numbers.any() == True:
                stock_warr=newDf[col]
                stock_warr=stock_warr[stock_warr.index>t] 

            # capture equity award
            comp86 = newDf[col].str.contains(r'equity', flags=re.IGNORECASE, regex=True)  
            comp87 = newDf[col].str.contains(r'[Nn]on[ -][Ee]quity', flags=re.IGNORECASE, regex=True)

            if comp86.any() == True & numbers.any() == True:
                if (comp87.any()==True):
                    print('equity award mistaken for non-equity is TAKEN CARE OF')
                else:                    
                    stock_eq=newDf[col]
                    stock_eq=stock_eq[stock_eq.index>t]                     
                    
            ######## OPTIONS SECTION #######

            comp3 = newDf[col].str.contains(r'[Oo][Pp][Tt][Ii][Oo][Nn]', regex=True)
            comp31 = newDf[col].str.contains(r'held', flags=re.IGNORECASE, regex=True)            
            if comp3.any() == True & numbers.any() == True:
                if comp31.any() == True:
                    print('total number of stocks TAKEN CARE OF')
                else:                
                    options=newDf[col]
                    options=options[options.index>t] 

            ######## NON-EQUITY SECTION #######
                 
            comp4 = newDf[col].str.contains(r'[Nn]on[ -][Ee]quity', regex=True)
            if comp4.any() == True & numbers.any() == True:
                nonequity=newDf[col]
                nonequity=nonequity[nonequity.index>t] 
            

            ######## PENSION SECTION #######
            
            # check that it is not "Changes in Pension Value AND Nonqualified Deferred Compensation Earnings "
            comp5 = newDf[col].str.contains(r'[Pp]ension', regex=True)
            comp51 = newDf[col].str.contains(r'Nonqualified Deferred', flags=re.IGNORECASE, regex=True)
            if comp5.any() == True & numbers.any() == True:
                if comp51.any() == True:
                    print('nonqualified deffered & pension TAKEN CARE OF')
                else:
                    pension=newDf[col]
                    pension=pension[pension.index>t] 



            ######## TOTAL COMP SECTION #######
               
            # check that the column is not the "total number of outstanding unvested equity awards"
            comp6 = newDf[col].str.contains(r'[Tt][Oo][Tt][Aa][Ll]', regex=True)
            comp61 = newDf[col].str.contains(r'number', flags=re.IGNORECASE, regex=True)            
            if comp6.any() == True & numbers.any() == True:
                if comp61.any() == True:
                    print('total number of stocks TAKEN CARE OF')
                else:
                    total_comp=newDf[col]
                    total_comp=total_comp[total_comp.index>t] 

            
            ######## OTHER COMP SECTION #######
               
            comp7 = newDf[col].str.contains(r'[Oo]ther', flags=re.IGNORECASE, regex=True)
            comp79 = newDf[col].str.contains(r'fee', flags=re.IGNORECASE, regex=True)
            if comp7.any() == True & numbers.any() == True:
                if comp79.any() == True:
                    other_fee = newDf[col]
                    other_fee=other_fee[other_fee.index>t] 
                else:    
                    other_comp=newDf[col]
                    other_comp=other_comp[other_comp.index>t] 
                        
            comp71 = newDf[col].str.contains(r'Opta', flags=re.IGNORECASE, regex=True)
            comp72 = newDf[col].str.contains(r'Minerals', flags=re.IGNORECASE, regex=True)
            comp73 = newDf[col].str.contains(r'fee', flags=re.IGNORECASE, regex=True)
            if comp71.any() == True & comp72.any() == True & comp73.any() == True & numbers.any() == True:
                other_comp_sub=newDf[col]
                other_comp_sub=other_comp_sub[other_comp_sub.index>t]     

            comp74 = newDf[col].str.contains(r'unit', flags=re.IGNORECASE, regex=True)
            comp75 = newDf[col].str.contains(r'award', flags=re.IGNORECASE, regex=True)
            comp77 = newDf[col].str.contains(r'share', flags=re.IGNORECASE, regex=True)
            comp78 = newDf[col].str.contains(r'stock', flags=re.IGNORECASE, regex=True)            
            # adjust for case where "Annual Award of Restricted Share Units"
            if comp74.any() == True & comp75.any() == True & numbers.any() == True:
                if (comp77.any() == True) | (comp78.any() == True):
                    print('unit award in shares/ stocks TAKEN CARE OF')
                else:        
                    other_comp_unit=newDf[col]
                    other_comp_unit=other_comp_unit[other_comp_unit.index>t] 
                
            comp76 = newDf[col].str.contains(r'tax', flags=re.IGNORECASE, regex=True)
            if comp76.any() == True & numbers.any() == True:
                other_comp_tax=newDf[col]
                other_comp_tax=other_comp_tax[other_comp_tax.index>t] 

            #record dividends 
            comp84 = newDf[col].str.contains(r'dividend', flags=re.IGNORECASE, regex=True)            
            if comp84.any() == True & numbers.any() == True:
                other_div=newDf[col]
                other_div=other_div[other_div.index>t] 

            comp41 = newDf[col].str.contains(r'Nonqualified Deferred', flags=re.IGNORECASE, regex=True)
            # make sure it doesn't capture "Nonqualified Deferred Pension"
            if comp41.any() == True & numbers.any() == True:
                other_def=newDf[col]
                other_def=other_def[other_def.index>t] 


        # After all possible rows are recorded, allocate them into buckets by summing together

        # Total Cash #
        # the following relies on the conditions that:
        # if cash is not reported, then it is reported through cash components (needs summing)
        # if the cash column is reported, it includes all other fee components (ASSUMPTION)
        if cash is None:
            # add all cash components
            for x in [cash_an_ret,cash_committee, cash_chair_fee,cash_meet_fee,cash_board_fee]:
                if x is not None:
                    if cash is not None:
                        ccc = pd.to_numeric(x.astype(str).str.replace(',',''), errors='coerce').fillna(0).astype(int)
                        try:
                            cash = cash.replace('', '0').astype(int) + ccc
                        except:
                            cash = pd.to_numeric(cash.astype(str).str.replace(',',''), errors='coerce').fillna(0).astype(int)+ ccc                            
                            
                        #x.to_frame().replace('', '0').astype(dtype = int, errors = 'coerce')
                    if cash is None:
                        cash = pd.to_numeric(x.astype(str).str.replace(',',''), errors='coerce').fillna(0).astype(int)
                        #cash =  x.to_frame().replace('', '0').astype(dtype = int, errors = 'ignore')



        # Total Stock #
        if (stock_rsu is not None) | (stock_warr is not None) | (stock_sar is not None) | (stock_eq is not None):
            for x in [stock_rsu, stock_warr, stock_sar, stock_eq]:
                if x is not None:        
                    if stock is not None:
                        ccc = pd.to_numeric(x.astype(str).str.replace(',',''), errors='coerce').fillna(0).astype(int)
                        try:
                            stock = stock.replace('', '0').astype(int) + ccc
                        except:
                            stock = pd.to_numeric(stock.astype(str).str.replace(',',''), errors='coerce').fillna(0).astype(int)+ ccc                            
                        #x.to_frame().replace('', '0').astype(dtype = int, errors = 'coerce')
                    if stock is None:
                        stock = pd.to_numeric(x.astype(str).str.replace(',',''), errors='coerce').fillna(0).astype(int)

        # Total Non-equity #
        if (nonequity_def is not None) :
            for x in [nonequity_def]:
                if x is not None:        
                    if nonequity is not None:
                        ccc = pd.to_numeric(x.astype(str).str.replace(',',''), errors='coerce').fillna(0).astype(int)
                        try:
                            nonequity = nonequity.replace('', '0').astype(int) + ccc
                        except:
                            nonequity = pd.to_numeric(nonequity.astype(str).str.replace(',',''), errors='coerce').fillna(0).astype(int)+ ccc                            
                        #x.to_frame().replace('', '0').astype(dtype = int, errors = 'coerce')
                    if nonequity is None:
                        nonequity = pd.to_numeric(x.astype(str).str.replace(',',''), errors='coerce').fillna(0).astype(int)

    
        # Total Other Comp #
        # unlike cash, other comp components are always reported separately and are not included in the other comp column calculation
        # below we simply add all extra columns reported on other comp
        if (other_comp_tax is not None) | (other_fee  is not None) | (other_comp_unit is not None) | (other_comp_sub is not None) | (other_div is not None) | (other_def is not None) :
            for x in [other_div,other_fee, other_comp_tax,other_comp_unit, other_comp_sub, other_def]:
                if x is not None:        
                    if other_comp is not None:
                        ccc = pd.to_numeric(x.astype(str).str.replace(',',''), errors='coerce').fillna(0).astype(int)
                        try:
                            other_comp = other_comp.replace('', '0').astype(int) + ccc
                        except:
                            other_comp = pd.to_numeric(other_comp.astype(str).str.replace(',',''), errors='coerce').fillna(0).astype(int)+ ccc                            
                        #x.to_frame().replace('', '0').astype(dtype = int, errors = 'coerce')
                    if other_comp is None:
                        other_comp = pd.to_numeric(x.astype(str).str.replace(',',''), errors='coerce').fillna(0).astype(int)
        
                                    
        
    
        #Record compensation into a new dataframe   
        data = {'file number': row[0], 'gvkey': row[2], 'year_file': row[3], 'year': row[3], 'firm name' : row[4],
                 'director name' : dir_names, 'cash award': cash,  'stock': stock, 'options': options,
                 'non equity' :  nonequity, 'pension' : pension, 'other comp' : other_comp, 'total' :  total_comp,
                 'table found' : 1,'link' : row[5]}
     
        
         
        frame_full=pd.DataFrame(data)
        frame_full=frame_full.astype(str)
        
        frame_full=frame_full.replace("’", "'") 
        frame_full=frame_full.replace(u"(\u2018|\u2019)", "'") 
        frame_full = frame_full.replace(')', '')            
        # because some numbers were int and got converted to str, Python added decimals to them ".0" 
        # correct these cases where ".0" was added -> added ^. to regex

        #frame_full=frame_full.str.strip()
    
        frame_full['cash award']= frame_full['cash award'].replace({'[^A-Za-z0-9|^.|^\-?[1-9]\d{0,2}(\.\d*)?$]':''}, regex=True).str.strip()    
        frame_full['stock']= frame_full['stock'].replace({'[^A-Za-z0-9|^.|^\-?[1-9]\d{0,2}(\.\d*)?$]':''}, regex=True).str.strip()  
        frame_full['options']= frame_full['options'].replace({'[^A-Za-z0-9|^.|^\-?[1-9]\d{0,2}(\.\d*)?$]':''}, regex=True).str.strip()    
        frame_full['non equity']= frame_full['non equity'].replace({'[^A-Za-z0-9|^.|^\-?[1-9]\d{0,2}(\.\d*)?$]':''}, regex=True).str.strip()    
        frame_full['total']= frame_full['total'].replace({'[^A-Za-z0-9|^.|^\-?[1-9]\d{0,2}(\.\d*)?$]':''}, regex=True).str.strip()    
        # keep a possibility for a negative sign in pensions and other comp
        frame_full['other comp']= frame_full['other comp'].replace({"[^A-Za-z0-9|^.|^\-?[1-9]\d{0,2}(\.\d*)?$]":''}, regex=True).str.strip()   

        #frame_full['other comp']= frame_full['other comp'].replace({"[^(?!\d+$)(?:[a-zA-Z0-9][a-zA-Z0-9 @&$]*)?$]":''}, regex=True) 
        


        # Convert the collected table into numeric values
        frame_full['cash award'] = pd.to_numeric(frame_full['cash award'].astype(str).str.replace(',',''), errors='coerce').fillna(0).astype(int)    
        frame_full['stock'] = pd.to_numeric(frame_full['stock'].astype(str).str.replace(',',''), errors='coerce').fillna(0).astype(int)    
        frame_full['options'] = pd.to_numeric(frame_full['options'].astype(str).str.replace(',',''), errors='coerce').fillna(0).astype(int)    
        frame_full['non equity'] = pd.to_numeric(frame_full['non equity'].astype(str).str.replace(',',''), errors='coerce').fillna(0).astype(int)    
        frame_full['total'] = pd.to_numeric(frame_full['total'].astype(str).str.replace(',',''), errors='coerce').fillna(0).astype(int)    
        frame_full['other comp'] = pd.to_numeric(frame_full['other comp'].astype(str).str.replace(',',''), errors='coerce').fillna(0).astype(int)    
        frame_full['pension'] = pd.to_numeric(frame_full['pension'].astype(str).str.replace(',',''), errors='coerce').fillna(0).astype(int)    



        # Drop former directors, drop rows with table headers    
        for index, row in frame_full.iterrows():
            k=0  
            m=row   
            if "former director" in row['director name'] :  
                frame_full.at[index, 'former_dir'] = 1
            else:
                frame_full.at[index, 'former_dir'] = 0
            if "Directors" in row['director name'] :  
                frame_full.at[index, 'header_row'] = 1
            else:
                frame_full.at[index, 'header_row'] = 0                
        df_no_former = frame_full[frame_full['former_dir']!=1]
        df_no_header = df_no_former[frame_full['header_row']!=1]
        df_no_header = df_no_header.drop(columns=['former_dir','header_row'])
        df_no_header = df_no_header[df_no_header['director name']!=""]
        df_no_header = df_no_header.replace('nan', '')      

        frame_full = df_no_header
        
    
    
        if app_frame_full is None:
            app_frame_full=frame_full
        else:    
            app_frame_full=app_frame_full.append(frame_full, ignore_index=True, sort=False)
    
        # check that the recorded data is correct
        app_frame_full['check_sum'] = app_frame_full['cash award'] +app_frame_full['stock'] + app_frame_full['options']+app_frame_full['non equity']+app_frame_full['other comp']+app_frame_full['pension'] 
        app_frame_full['check'] = np.where(( app_frame_full['check_sum'] == app_frame_full['total']), 1, 0)
        
        if i==3:
            frame_full.to_csv(r'R:\ps664\Dr_Becher - DirComp\8_data_collection\Code to extract Dir Comp\adjustments\data_direct_pull.csv')
        # Appending the excel file
        if i>3:
            with open(r'R:\ps664\Dr_Becher - DirComp\8_data_collection\Code to extract Dir Comp\adjustments\data_direct_pull.csv', 'a', newline='', encoding="latin-1", errors="replace") as f:
                frame_full.to_csv(f, header=False)
    


    except Exception as e:
        error_n=error_n+1
        print("skipped observation")
        print(e) 
        err = type(e)      
        data = {'file_number': i,
                 'error': str(e),
                 "File Number": row[0],
                 "Excel Row Number": i-1
                }
        frame_full_error=pd.DataFrame(data, index=[0])                  
        frame_full = pd.DataFrame({'file number': row[0], 'gvkey': row[2],  'year_file': row[3], 'year':  row[3],
                 'firm name' : row[4], 'director name' : None, 'cash award': None, 'stock': None,
                 'options': None, 'non equity' :  None, 'pension' : None, 'other comp' : None,
                 'total' :  None, 'table found' : 0 , 'link' : row[5] }, index =[0])        
        app_frame_full=app_frame_full.append(frame_full, ignore_index=True)                 
    
        if error_n==1:
            frame_full_error.to_csv(r'R:\ps664\Dr_Becher - DirComp\8_data_collection\Code to extract Dir Comp\adjustments\error.csv')
            #with open(r'R:\ps664\Dr_Becher - DirComp\8_data_collection\Code to extract Dir Comp\data_direct_pull.csv', 'a', newline='', encoding="latin-1", errors="replace") as f:
            #    frame_full.to_csv(f, header=False)
                
        # Appending the excel file
        if error_n>1:
            with open(r'R:\ps664\Dr_Becher - DirComp\8_data_collection\Code to extract Dir Comp\adjustments\error.csv', 'a', newline='', encoding="latin-1", errors="replace") as f:
                frame_full_error.to_csv(f, header=False)        
            #with open(r'R:\ps664\Dr_Becher - DirComp\8_data_collection\Code to extract Dir Comp\data_direct_pull.csv', 'a', newline='', encoding="latin-1", errors="replace") as f:
            #    frame_full.to_csv(f, header=False)






















