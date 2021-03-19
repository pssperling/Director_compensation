"""
Created on Thu Feb  6 09:40:00 2020

@author: pssperling
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
import nltk
from nltk.tokenize import word_tokenize
from nltk.tag import pos_tag
from nltk.tag import StanfordNERTagger
nltk.download('punkt')
nltk.download('averaged_perceptron_tagger')


def getDuplicateColumns(df):
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
app_frame_full=None

library_=".."
os.chdir(library_)

file = open('Edgar_links.csv')
csv_f = csv.reader(file, delimiter=',')
i=1


# Loop over all firm-year links in the file 
for row in csv_f:

    i=i+1   
   
    # Always start to run the code with i at least 2 (skipping table header)
    if i==2:
        print(i)        
        continue
        
    # continue where left of (code will start with the filenumber mentioned below)
    #if int(row[0])<5680:
    #    print(i)        
    #    continue
    #if i<5680:
    #    print(i)        
    #    continue

    
    link=row[5]   
    print(i)    
    print(link)
    print("File Number:", row[0])
    print("Excel Row Number:", i-1)
    print("Firm Name", row[4])    
        
    ##### Error Check ####
    #link = 'https://www.sec.gov/Archives/edgar/data/314808/000095013409007528/d67153def14a.htm'
    
    page = requests.get(link)
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
    
    table1 = soup.select('table:contains("Salary")')
    table1_ = soup.select('table:contains("SALARY")')
    
    table2 = soup.select('table:contains("Bonus")')
    table2_ = soup.select('table:contains("BONUS")')
    table2__ = soup.select('table:contains("bonus")')
    
    table3 = soup.select('table:contains("Stock")')
    table3_ = soup.select('table:contains("STOCK")')
    table3__ = soup.select('table:contains("stock")')
    
    
    table4 = soup.select('table:contains("Total")')    
    table4_ = soup.select('table:contains("TOTAL")')    
    table4__ = soup.select('table:contains("total")')    

    # set of keywords for wrong tables
    table5 = soup.select('table:contains("Health")')
    table5_ = soup.select('table:contains("Disability")')
    table5__ = soup.select('table:contains("Insurance")')
    table5___ = soup.select('table:contains("Resignation")')
    

    table6 = soup.select('table:contains("Year")')
    table6_ = soup.select('table:contains("year")')
    table6__ = soup.select('table:contains("YEAR")')
    
    table7 = soup.select('table:contains("Option")')
    table7_ = soup.select('table:contains("OPTION")')
    table7__ = soup.select('table:contains("Option")')

    table8 = soup.select('table:contains("principal")')
    table8_ = soup.select('table:contains("PRINCIPAL")')
    table8__ = soup.select('table:contains("Principal")')
    
    tables_found=0
    
    # Try for the whole code 
    try:
        # Proceed with the narrowest set of table keywords to the broadest
        
        # Try combination of kewords Salary & Stock/STOCk/stock & Option/option/OPTION & Year/year/YEAR & principal        
        for table in table1:
            if (table in table3) | (table in table3_) | (table in table3__):  
                if (table in table7) | (table in table7_) | (table in table7__):              
                    if (table in table6) | (table in table6_) | (table in table6__):  
                        if (table in table8) | (table in table8_) | (table in table8__):                         
                            if (table in table5) | (table in table5_) | (table in table5__) | (table in table5___):  
                                print('skipped wrong tables')
                                #print(pd.read_html(str(table))[0])
                            else:
                                tables_found=tables_found+1
                                if i==3:
                                    comp_dataframe=pd.read_html(str(table))
                                    exec_comp=comp_dataframe[0]
                                if i>3:
                                    a=pd.read_html(str(table))
                                    comp_dataframe.append(a[0])
                                    exec_comp=a[0]
                                print("Table found 1")
                                break
        
        # Try combination of kewords Salary & Bonus/BONUS/bonus & Stock/STOCk/stock             
        if tables_found==0:        
            for table in table1:
                if (table in table2) | (table in table2_) | (table in table2__):
                    if (table in table3) | (table in table3_) | (table in table3__):  
                        if (table in table5) | (table in table5_) | (table in table5__) | (table in table5___):  
                            print('skipped wrong tables')
                            #print(pd.read_html(str(table))[0])
                        else:
                            tables_found=tables_found+1
                            if i==3:
                                comp_dataframe=pd.read_html(str(table))
                                exec_comp=comp_dataframe[0]
                            if i>3:
                                a=pd.read_html(str(table))
                                comp_dataframe.append(a[0])
                                exec_comp=a[0]
                            print("Table found 1")
                            break
                    
        # Try combination of kewords SALARY & Bonus/BONUS/bonus & Stock/STOCk/stock             
        if tables_found==0:        
            for table in table1_:
                if (table in table2) | (table in table2_) | (table in table2__):
                    if (table in table3) | (table in table3_) | (table in table3__):  
                        if (table in table5) | (table in table5_) | (table in table5__) | (table in table5___):  
                            print('skipped wrong tables')
                        else:                        
                            tables_found=tables_found+1
                            if i==3:
                                comp_dataframe=pd.read_html(str(table))
                                exec_comp=comp_dataframe[0]
                            if i>3:
                                a=pd.read_html(str(table))
                                comp_dataframe.append(a[0])
                                exec_comp=a[0]
                            print("Table found 2")   
                            break
                    

                
        # Try combination of kewords Salary & Total/TOTAL/total & Year/YEAR/year  
        if tables_found==0:
            for table in table1:
                if (table in table4) | (table in table4_) | (table in table4__):
                    if (table in table6) | (table in table6_) | (table in table6__):
                        if (table in table5) | (table in table5_) | (table in table5__) | (table in table5___):  
                            print('skipped wrong tables')
                        else:                       
                            tables_found=tables_found+1
                            if i==3:
                                comp_dataframe=pd.read_html(str(table))
                                exec_comp=comp_dataframe[0]
                            if i>3:
                                a=pd.read_html(str(table))
                                exec_comp=a[0]
                                comp_dataframe.append(a[0])
                            print("Table found 5")    
                            break

        # Try combination of kewords SALARY & Total/TOTAL/total & Year/YEAR/year  
        if tables_found==0:
            for table in table1_:
                if (table in table4) | (table in table4_) | (table in table4__):
                    if (table in table6) | (table in table6_) | (table in table6__):
                        if (table in table5) | (table in table5_) | (table in table5__) | (table in table5___):  
                            print('skipped wrong tables')
                        else:                       
                            tables_found=tables_found+1
                            if i==3:
                                comp_dataframe=pd.read_html(str(table))
                                exec_comp=comp_dataframe[0]
                            if i>3:
                                a=pd.read_html(str(table))
                                exec_comp=a[0]
                                comp_dataframe.append(a[0])
                            print("Table found 6")    
                            break
                    
        # Try combination of kewords SALARY & Bonus/BONUS/bonus & Year/YEAR/year  
        if tables_found==0:
            for table in table1_:
                if (table in table2) | (table in table2_) | (table in table2__):
                    if (table in table6) | (table in table6_) | (table in table6__):
                        if (table in table5) | (table in table5_) | (table in table5__) | (table in table5___):  
                            print('skipped wrong tables')
                        else:                       
                            tables_found=tables_found+1
                            if i==3:
                                comp_dataframe=pd.read_html(str(table))
                                exec_comp=comp_dataframe[0]
                            if i>3:
                                a=pd.read_html(str(table))
                                exec_comp=a[0]
                                comp_dataframe.append(a[0])
                            print("Table found 7")    
                            break


                    
                
        # Try combination of kewords Salary & Total/TOTAL/total        
        if tables_found==0:
            for table in table1:
                if (table in table4) | (table in table4_) | (table in table4__):
                    if (table in table5) | (table in table5_) | (table in table5__) | (table in table5___):  
                        print('skipped wrong tables')
                    else:                   
                        tables_found=tables_found+1
                        if i==3:
                            comp_dataframe=pd.read_html(str(table))
                            exec_comp=comp_dataframe[0]
                        if i>3:
                            a=pd.read_html(str(table))
                            exec_comp=a[0]
                            comp_dataframe.append(a[0])
                        print("Table found 3")  
                        break
            
        # Try combination of kewords SALARY & Total/TOTAL/total        
        if tables_found==0:
            for table in table1_:
                if (table in table4) | (table in table4_) | (table in table4__):
                    if (table in table5) | (table in table5_) | (table in table5__) | (table in table5___):  
                        print('skipped wrong tables')
                    else:                       
                        tables_found=tables_found+1
                        if i==3:
                            comp_dataframe=pd.read_html(str(table))
                            exec_comp=comp_dataframe[0]
                        if i>3:
                            a=pd.read_html(str(table))
                            exec_comp=a[0]
                            comp_dataframe.append(a[0])
                        print("Table found 4")    
                        break
                    
    
        # Check that the website doesn't have table in a list instead of html
        # => Look at the length of the table pulled (dropped those that have less than 3 columns)
        if tables_found==1 and len(exec_comp.columns)<3:
            print("HTML wrong table format")
            continue
        
    
        # If there is no table found, then skip the rest of the code to the next link
        if tables_found==0:  
            print("No table found")
            frame_full = pd.DataFrame({'file number': row[0], 'gvkey': row[2],  'year_file': row[3], 'year':  row[3],
                     'firm name' : row[4], 'director name' : dir_names, 'salary': salary, 'bonus': bonus, 'stock': stock,
                     'options': options, 'non equity' :  nonequity, 'pension' : pension, 'other comp' : other_comp,
                     'total' :  total_comp, 'table found' : 0 , 'link' : row[5] }, index =[0])        
            app_frame_full=app_frame_full.append(frame_full, ignore_index=True)
            if app_frame_full is None:
                app_frame_full=frame_full
            else:   
                app_frame_full=app_frame_full.append(frame_full, ignore_index=True)    
            continue
    
   
        
        
        # drop empty rows
        df = exec_comp.dropna(how='all')
    
        # drop duplicate columns    
        df = df.drop_duplicates()
    
    
        # mark the row at which the table's numberical values start
        # 1. simple cases where director names follow "Name"
        table_start = df.iloc[:,0].str.contains(r'[Nn]ame', regex=True)
        table_start= table_start.replace(np.nan, False, regex=True)
        t = table_start.index[table_start].tolist()
        
        table_start_pr = df.iloc[:,0].str.contains(r'Principal', flags=re.IGNORECASE, regex=True)
        table_start_pr= table_start_pr.replace(np.nan, False, regex=True)
        t_pr = table_start_pr.index[table_start_pr].tolist()
        if len(t_pr)==0:
            table_start_pr = df.iloc[:,0].str.contains(r'Position', flags=re.IGNORECASE, regex=True)
            table_start_pr= table_start_pr.replace(np.nan, False, regex=True)
            t_pr = table_start_pr.index[table_start_pr].tolist()
        
        if (len(t)>0) & (len(t_pr)>0):
            if int(t[0])<int(t_pr[0]):
                t[0]=t_pr[0]
        
        if len(t)>0:
            dir_names=df.iloc[df.index>t,0]         
        else:
            # adjust for cases where "Name" is in the dataframe header
            min_index= min(df.index)
            try:
                df.loc[min_index-1] = df.columns
            except:
                # adjust for cases where header is a tuple
                df.loc[min_index-1] = df.columns.get_level_values(0)
            df = df.sort_index(ascending=True)
            print(df)    
            table_start = df.iloc[:,0].str.contains(r'[Nn]ame', regex=True)
            table_start= table_start.replace(np.nan, False, regex=True)
            t = table_start.index[table_start].tolist()
            if len(t)>0:
                dir_names=df.iloc[df.index>t,0]  
            else:
                print("Table doesn't start with keyword Name")            
                table_start = df.iloc[:,0].str.contains(r'Principal', flags=re.IGNORECASE, regex=True)
                table_start= table_start.replace(np.nan, False, regex=True)
                t = table_start.index[table_start].tolist()
                if len(t)>0:
                    # if table starts with "Director"
                    dir_names=df.iloc[df.index>t,0]  
                else:
                    print("Table doesn't start with keyword Name or Principal")            
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
     
                        if dir_names is None:
                            # if there is no table start (Name, Director or a Person's name), then skip the link
                            print("No table found")
                            frame_full = pd.DataFrame({'file number': row[0], 'gvkey': row[2],  'year_file': row[3], 'year':  row[3],
                             'firm name' : row[4], 'director name' : dir_names, 'salary': cash, 'bonus': bonus,  'stock': stock,
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
        newDf = df1.drop(columns=getDuplicateColumns(df1))
              
        #Remove all cells with zeros
        newDf = newDf.astype(str)
        
        newDf = newDf.replace('--', '')      
        newDf = newDf.replace('––', '') 
        newDf = newDf.replace('-', '')  
        newDf = newDf.replace('—', '') 
        newDf = newDf.replace('', '')        
        # Get rid of annotations like (1) (6) first (order matters!!)
        newDf= newDf.replace(regex='\([0-9]\)', value= '') 
        newDf= newDf.replace(regex='\(1[0-9]\)', value= '')         
        # Get rid of annotations like (1 (6 first
        newDf= newDf.replace(regex='\([0-9]$', value= '') 
        
        # Change numbers in brackets into negatvie numbers next
        newDf= newDf.replace(regex='\(([0-9].*)\)', value= '-\\1')        
        newDf= newDf.replace(regex='\(([0-9].*)', value= '-\\1') 
        # Get rid of annotations like (a) (b) ($) the last or (b  where only part is recorded
        newDf= newDf.replace(regex='\((.*)\)', value= '') 
        newDf= newDf.replace(regex='\(([a-z])', value= '') 
        newDf= newDf.replace({"\,":''}, regex=True)  
        newDf = newDf.replace('-0-', '')        
        newDf = newDf.replace(')', '')
        newDf= newDf.replace({"\(":''}, regex=True)
        newDf= newDf.replace({"\$":''}, regex=True)        
        newDf = newDf.replace('-)', '')
        newDf = newDf.replace(')', '')


        
        # Find the number of years reported    
        for col in newDf.columns: 
            numbers = newDf[col].str.contains(r'[0-9][0-9][0-9][0-9]', regex=True)           
            comp1 = newDf[col].str.contains(r'Year', flags=re.IGNORECASE, regex=True)
            if comp1.any() == True & numbers.any() == True:
                year=newDf[col]
                year=year[year.index>t]
                
        cash = None
        cash_fee = None
        cash_ben = None
        bonus = None        
        stock = None
        stock_rsu = None
        stock_warr = None
        stock_sar = None
        stock_eq = None 
        stock_more = None
        options=None
        other_comp = None
        other_comp_sub= None
        other_comp_unit= None
        other_comp_tax= None
        other_div=None
        other_def=None
        other_fee = None       
        nonequity = None
        nonequity_def=None
        pension= None
        totak_comp=None
          
        #Find type of compensation            
        for col in newDf.columns: 
            
            # restrict to checking numbers presence after the header (iloc[1:]) because some headers are indexes like 1,2..15..
            numbers = newDf[col].iloc[1:].str.contains(r'[0-9][0-9]', regex=True)

            # skip "Supplemental info" column
            comp00 = newDf[col].str.contains(r'Supplemental', flags=re.IGNORECASE, regex=True)
            if comp00.any() == True & numbers.any() == True:
                print('skipped Supplemental Info column')
                continue
                        
            ######## CASH / SALARY SECTION #######
            comp1 = newDf[col].str.contains(r'salary', flags=re.IGNORECASE, regex=True)
            if comp1.any() == True & numbers.any() == True:
                cash=newDf[col]
                cash=cash[cash.index>t]

            comp114 = newDf[col].str.contains(r'fees', flags=re.IGNORECASE, regex=True)
            comp115 = newDf[col].str.contains(r'cash', flags=re.IGNORECASE, regex=True)
            if comp114.any() == True & comp115.any() == True & numbers.any() == True:
                cash_fee=newDf[col]
                cash_fee=cash_fee[cash_fee.index>t]

            comp116 = newDf[col].str.contains(r'benefits', flags=re.IGNORECASE, regex=True)
            if comp116.any() == True & numbers.any() == True:
                cash_ben=newDf[col]
                cash_ben=cash_ben[cash_ben.index>t]
    

            ######## BONUS SECTION #######                  
            comp2 = newDf[col].str.contains(r'bonus', flags=re.IGNORECASE, regex=True)
            comp21 = newDf[col].str.contains(r'non-equity', flags=re.IGNORECASE, regex=True)
            if (comp2.any()==True) & (comp21.any()==True) :
                print('non-equity bonus plan TAKEN CARE OF')
            else:    
                if comp2.any() == True & numbers.any() == True:
                    bonus=newDf[col]
                    bonus=bonus[bonus.index>t] 

            ######## STOCK SECTION #######            
            comp8 = newDf[col].str.contains(r'stock', flags=re.IGNORECASE, regex=True)
            comp81 = newDf[col].str.contains(r'number', flags=re.IGNORECASE, regex=True)
            comp85 = newDf[col].str.contains(r'option', flags=re.IGNORECASE, regex=True)
            comp84 = newDf[col].str.contains(r'dividend', flags=re.IGNORECASE, regex=True)            
            if (comp85.any()==True) | (comp81.any()==True) | (comp84.any()==True):
                print('stock option award / number/ dividend TAKEN CARE OF')
            else:    
                if comp8.any() == True & numbers.any() == True:
                    if stock is None:
                        stock=newDf[col]
                        stock=stock[stock.index>t]                           
                    else:
                        stock_more=newDf[col]
                        stock_more=stock_more[stock_more.index>t]                           
                        
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
            comp871 = newDf[col].str.contains(r'non[ -][ -]equity', flags=re.IGNORECASE, regex=True)
            if comp86.any() == True & numbers.any() == True:
                if (comp87.any()==True) | (comp871.any()==True):
                    print('equity award mistaken for non-equity is TAKEN CARE OF')
                else:                    
                    stock_eq=newDf[col]
                    stock_eq=stock_eq[stock_eq.index>t]                     
                    
            ######## OPTIONS SECTION #######
            comp3 = newDf[col].str.contains(r'option', flags=re.IGNORECASE, regex=True)
            comp31 = newDf[col].str.contains(r'held', flags=re.IGNORECASE, regex=True)            
            if comp3.any() == True & numbers.any() == True:
                if comp31.any() == True:
                    print('total number of stocks TAKEN CARE OF')
                else:                
                    options=newDf[col]
                    options=options[options.index>t] 

            ######## NON-EQUITY SECTION #######                 
            comp4 = newDf[col].str.contains(r'[Nn]on[ -][Ee]quity', flags=re.IGNORECASE, regex=True)
            comp41 = newDf[col].str.contains(r'non[ -][ -]equity', flags=re.IGNORECASE, regex=True)
            comp42 = newDf[col].str.contains(r'bonus', flags=re.IGNORECASE, regex=True)
            if comp4.any() == True & numbers.any() == True:
                nonequity=newDf[col]
                nonequity=nonequity[nonequity.index>t]          
            if nonequity is None:
                if comp41.any() == True & numbers.any() == True:
                    if comp42.any()==True:
                        print('non-equity bonus taken care of')
                    else:
                        nonequity=newDf[col]
                        nonequity=nonequity[nonequity.index>t]          
                        

            ######## PENSION SECTION #######            
            # check that it is not "Changes in Pension Value AND Nonqualified Deferred Compensation Earnings "
            comp5 = newDf[col].str.contains(r'[Pp]ension', flags=re.IGNORECASE, regex=True)
            comp51 = newDf[col].str.contains(r'Nonqualified Deferred', flags=re.IGNORECASE, regex=True)
            comp511 = newDf[col].str.contains(r'Nonqualified', flags=re.IGNORECASE, regex=True)
            comp512 = newDf[col].str.contains(r'Deferred', flags=re.IGNORECASE, regex=True)
            if comp5.any() == True & numbers.any() == True:
                if comp51.any() == True:
                    print('nonqualified deffered & pension TAKEN CARE OF')
                else:
                    if comp511.any() == True & comp512.any() == True:
                        print('nonqualified deffered & pension TAKEN CARE OF')
                    else:                       
                        pension=newDf[col]
                        pension=pension[pension.index>t] 
        
            ######## TOTAL COMP SECTION #######               
            # check that the column is not the "total number of outstanding unvested equity awards"
            comp6 = newDf[col].str.contains(r'total', flags=re.IGNORECASE, regex=True)
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
            comp411 = newDf[col].str.contains(r'Nonqualified', flags=re.IGNORECASE, regex=True)
            comp412 = newDf[col].str.contains(r'Deferred', flags=re.IGNORECASE, regex=True)
            comp413 = newDf[col].str.contains(r'compensation', flags=re.IGNORECASE, regex=True)
            # make sure it doesn't capture "Nonqualified Deferred Pension"
            if comp41.any() == True & numbers.any() == True:
                other_def=newDf[col]
                other_def=other_def[other_def.index>t] 
            if other_def is None:
                if comp411.any() == True &  comp412.any() == True & numbers.any() == True:
                    other_def=newDf[col]
                    other_def=other_def[other_def.index>t]                 
            if other_def is None:
                if comp411.any() == True &  comp413.any() == True & numbers.any() == True:
                    other_def=newDf[col]
                    other_def=other_def[other_def.index>t]                 


############ Adjust multiple years reported in Exec comp tables ################
            
            # mark cases where a firm reports more than one year    
            if year is None:
                n_years_cell = n_years_row = [0]
            else:    
                try:
                    # 1. multiple years in a cell
                    n_years_cell= re.findall(r'[0-9][0-9][0-9][0-9]', year.iloc[2])           
                    n_years_row= list(set(n_years_cell))           
                except:
                    n_years_cell= re.findall(r'[0-9][0-9][0-9][0-9]', year.iloc[1])        
                    n_years_row= list(set(n_years_cell))              

            if year is None:
                print('no year column')
            else:             
                if len(n_years_row)==1:
                    # 2. multiple years in a column
                    n_years_cell= year.str.extract(r'([0-9][0-9][0-9][0-9])')  
                    n_years_cell = n_years_cell.dropna(how='all') 
                    n_years_row= list(set(n_years_cell.iloc[:,0]))                  
                    
        
        # adjust cases with multiple years in one cell        
        if len(n_years_row)>1:
            
            # 1. drop cases where a firm reports several years, but we can't separate which year is what number
            mushed_numbers= year.str.match( r'[0-9][0-9][0-9][0-9][0-9]')
            mushed = mushed_numbers.index[mushed_numbers].tolist()    
            if len(mushed)>0:
                print("Table Formatting Error - Mushed Numbers")
                frame_full = pd.DataFrame({'file number': row[0], 'gvkey': row[2],  'year_file': row[3], 'year':  row[3],
                         'firm name' : row[4], 'director name' : None, 'salary': None, 'bonus': None, 'stock': None,
                         'options': None, 'non equity' :  None, 'pension' : None, 'other comp' : None,
                         'total' :  None, 'table found' : 0 , 'link' : row[5] }, index =[0])        
                app_frame_full=app_frame_full.append(frame_full, ignore_index=True)   
    
                continue
                        
            # 2. multiple years in a cell        

            from itertools import chain
            def chainer(s):
                return list(chain.from_iterable(s.str.split('\s+')))
            
            def break_years_1(s):
                if s is not None:
                    try:
                        new_s = s.replace({'[a-zA-Z]+':''}, regex=True).str.strip()                    
                        new_s= new_s.str.lstrip().str.rstrip()                    
                        new_s=chainer(new_s)
                        if len(new_s)!=len(total_comp):
                            new_s=np.repeat(new_s, lens)                                 
                        return new_s
                    except:
                        # adjust for cases where some comp types is missing for some people
                        new_ss = s
                        new_ss[(lens.values ==2 ) & (s.values=='nan')] = 'nan nan'
                        new_ss[(lens.values ==3 ) & (new_ss.values=='nan')] = 'nan nan nan'                        
                        new_ss=chainer(new_ss.str.lstrip().str.rstrip())
                        if len(new_ss)==len(total_comp):
                            return new_ss
                else:
                    return None

            # use this function instead if there is no total column reported
            def break_years_2(s):
                if s is not None:
                    try:
                        new_s = s.replace({'[a-zA-Z]+':''}, regex=True).str.strip()                    
                        new_s= new_s.str.lstrip().str.rstrip()                    
                        new_s=chainer(new_s)
                        if len(new_s)!=len(cash):
                            new_s=np.repeat(new_s, lens)                                 
                        return new_s
                    except:
                        # adjust for cases where some comp types is missing for some people
                        new_ss = s
                        new_ss[(lens.values ==2 ) & (s.values=='nan')] = 'nan nan'
                        new_ss[(lens.values ==3 ) & (new_ss.values=='nan')] = 'nan nan nan'                        
                        new_ss=chainer(new_ss.str.lstrip().str.rstrip())
                        if len(new_ss)==len(cash):
                            return new_ss
                else:
                    return None
            
            # variable captures how many rows from that cell will be created
            year = year.replace({'[a-zA-Z]+':''}, regex=True).str.strip() 
            lens = year.str.split('\s+').map(len)
            
            # split the cell info & repeat columns with static values
            if dir_names is not None:
                dir_names=np.repeat(dir_names.str.lstrip(), lens)
            if total_comp is not None:
                total_comp= chainer(total_comp.replace({'[a-zA-Z]+':''}, regex=True).str.strip())
                #total_comp= chainer(total_comp.str.lstrip())
            if cash is not None:
                cash=chainer(cash.replace({'[a-zA-Z]+':''}, regex=True).str.strip())
                #cash=chainer(cash.str.lstrip())
            try:
                # make all chainers on itself (instead of a formed dataframe) in order to include new columns
                bonus = break_years_1(bonus)                
                cash_fee = break_years_1(cash_fee)
                cash_ben = break_years_1(cash_ben)
                pension = break_years_1(pension)
                stock = break_years_1(stock)
                stock_more = break_years_1(stock_more)
                stock_rsu = break_years_1(stock_rsu)               
                stock_warr = break_years_1(stock_warr)
                stock_sar = break_years_1(stock_sar)
                stock_eq = break_years_1(stock_eq)
                options = break_years_1(options)
                other_comp = break_years_1(other_comp)
                other_comp_sub = break_years_1(other_comp_sub)
                other_comp_unit = break_years_1(other_comp_unit)
                other_comp_tax = break_years_1(other_comp_tax)
                other_div = break_years_1(other_div)
                other_def = break_years_1(other_def)
                other_fee = break_years_1(other_fee)                
                nonequity = break_years_1(nonequity)
                nonequity_def = break_years_1(nonequity_def)                
            except:
                try:
                    # try salary length here
                    bonus = break_years_2(bonus)
                    cash_fee = break_years_2(cash_fee)
                    cash_ben = break_years_2(cash_ben)                    
                    pension = break_years_2(pension)
                    stock = break_years_2(stock)
                    stock_more = break_years_2(stock_more)
                    stock_rsu = break_years_2(stock_rsu)               
                    stock_warr = break_years_2(stock_warr)
                    stock_sar = break_years_2(stock_sar)
                    stock_eq = break_years_2(stock_eq)
                    options = break_years_2(options)
                    other_comp = break_years_2(other_comp)
                    other_comp_sub = break_years_2(other_comp_sub)
                    other_comp_unit = break_years_2(other_comp_unit)
                    other_comp_tax = break_years_2(other_comp_tax)
                    other_div = break_years_2(other_div)
                    other_def = break_years_2(other_def)
                    other_fee = break_years_2(other_fee)                
                    nonequity = break_years_2(nonequity)
                    nonequity_def = break_years_2(nonequity_def)                                        
                except:
                    print("Table Formatting Error - Some years Mushed Numbers")
                    frame_full = pd.DataFrame({'file number': row[0], 'gvkey': row[1],  'year_file': row[2], 'year':  row[2],
                             'firm name' : row[3], 'director name' : None, 'salary': None, 'bonus': None, 'stock': None,
                             'options': None, 'non equity' :  None, 'pension' : None, 'other comp' : None,
                             'total' :  None, 'table found' : 0 , 'link' : row[6] }, index =[0])        
                    app_frame_full=app_frame_full.append(frame_full, ignore_index=True)                 
                    continue
                        
            if cash is not None:    
                cash = pd.Series(cash)
            if cash_fee is not None:    
                cash_fee = pd.Series(cash_fee)
            if cash_ben is not None:    
                cash_ben = pd.Series(cash_ben)
            if total_comp is not None:    
                total_comp = pd.Series(total_comp)
            if pension is not None:    
                pension = pd.Series(pension)
            if bonus is not None:    
                bonus = pd.Series(bonus)
            if stock is not None:                    
                stock = pd.Series(stock)
            if stock_more is not None:                    
                stock_more = pd.Series(stock_more)
            if stock_rsu is not None:                    
                stock_rsu = pd.Series(stock_rsu)
            if stock_warr is not None:                    
                stock_warr = pd.Series(stock_warr)
            if stock_sar is not None:                    
                stock_sar = pd.Series(stock_sar)
            if stock_eq is not None:                    
                stock_eq = pd.Series(stock_eq)
            if options is not None:                    
                options = pd.Series(options)
            if other_comp is not None:                    
                other_comp = pd.Series(other_comp)
            if other_comp_sub is not None:                    
                other_comp_sub = pd.Series(other_comp_sub)
            if other_comp_unit is not None:                    
                other_comp_unit = pd.Series(other_comp_unit)
            if other_comp_tax is not None:                    
                other_comp_tax = pd.Series(other_comp_tax)
            if other_div is not None:                    
                other_div = pd.Series(other_div)
            if other_def is not None:                    
                other_def = pd.Series(other_def)
            if other_fee is not None:                    
                other_fee = pd.Series(other_fee)
            if nonequity is not None:                    
                nonequity = pd.Series(nonequity)
            if nonequity_def is not None:                    
                nonequity_def = pd.Series(nonequity_def)
            if total_comp is not None:                    
                total_comp = pd.Series(total_comp)
            dir_names = dir_names.reset_index().drop(columns='index')
            try:
                dir_names = pd.Series(dir_names[0])    
            except:
                dir_names = pd.Series(dir_names.iloc[:,0]) 
            year = chainer(year)
            year = pd.Series(year)

###########################################################################
        
        # After all possible rows are recorded, allocate them into buckets by summing together
        # Total Stock #
        if (stock_rsu is not None) | (stock_warr is not None) | (stock_sar is not None) | (stock_eq is not None) | (stock_more is not None):
            for x in [stock_rsu, stock_warr, stock_sar, stock_eq, stock_more]:
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
        

        # Total Salary
        if (cash_fee is not None) | (cash_ben is not None):
            for x in [cash_fee, cash_ben]:
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
                   


                #Record compensation into a new dataframe   
        data = {'file number': row[0], 'gvkey': row[2], 'year_file': row[3], 'year': year, 'firm name' : row[4],
                 'director name' : dir_names, 'salary': cash, 'bonus': bonus,  'stock': stock, 'options': options,
                 'non equity' :  nonequity, 'pension' : pension, 'other comp' : other_comp, 'total' :  total_comp,
                 'table found' : 1,'link' : row[5]}
        frame_full=pd.DataFrame(data)

            
        ### ADJUST FORMATING ###
        #frame_full = frame_full.replace([None], "")  
        frame_full=frame_full.astype(str)
        frame_full=frame_full.replace("’", "'") 
        frame_full=frame_full.replace(u"(\u2018|\u2019)", "'") 
        frame_full = frame_full.replace(')', '')            
        # because some numbers were int and got converted to str, Python added decimals to them ".0" 
        # correct these cases where ".0" was added -> added ^. to regex
  
        frame_full['salary']= frame_full['salary'].replace({'[^A-Za-z0-9|^.|^\-?[1-9]\d{0,2}(\.\d*)?$]':''}, regex=True).str.strip()    
        frame_full['stock']= frame_full['stock'].replace({'[^A-Za-z0-9|^.|^\-?[1-9]\d{0,2}(\.\d*)?$]':''}, regex=True).str.strip()  
        frame_full['options']= frame_full['options'].replace({'[^A-Za-z0-9|^.|^\-?[1-9]\d{0,2}(\.\d*)?$]':''}, regex=True).str.strip()    

        frame_full['bonus']= frame_full['bonus'].replace({'[^A-Za-z0-9|^.|^\-?[1-9]\d{0,2}(\.\d*)?$]':''}, regex=True).str.strip()    
        frame_full['non equity']= frame_full['non equity'].replace({'[^A-Za-z0-9|^.|^\-?[1-9]\d{0,2}(\.\d*)?$]':''}, regex=True).str.strip()    
        frame_full['total']= frame_full['total'].replace({'[^A-Za-z0-9|^.|^\-?[1-9]\d{0,2}(\.\d*)?$]':''}, regex=True).str.strip()    
        # keep a possibility for a negative sign in pensions and other comp
        frame_full['other comp']= frame_full['other comp'].replace({"[^A-Za-z0-9|^.|^\-?[1-9]\d{0,2}(\.\d*)?$]":''}, regex=True).str.strip()   
        frame_full['year']=frame_full['year'].replace({'[^0-9. ]':''}, regex=True)


        # Convert the collected table into numeric values
        frame_full['salary'] = pd.to_numeric(frame_full['salary'].astype(str).str.replace(',',''), errors='coerce').fillna(0).astype(int)    
        frame_full['stock'] = pd.to_numeric(frame_full['stock'].astype(str).str.replace(',',''), errors='coerce').fillna(0).astype(int)    
        frame_full['options'] = pd.to_numeric(frame_full['options'].astype(str).str.replace(',',''), errors='coerce').fillna(0).astype(int)    
        frame_full['bonus'] = pd.to_numeric(frame_full['bonus'].astype(str).str.replace(',',''), errors='coerce').fillna(0).astype(int)   
        frame_full['non equity'] = pd.to_numeric(frame_full['non equity'].astype(str).str.replace(',',''), errors='coerce').fillna(0).astype(int)    
        frame_full['total'] = pd.to_numeric(frame_full['total'].astype(str).str.replace(',',''), errors='coerce').fillna(0).astype(int)    
        frame_full['other comp'] = pd.to_numeric(frame_full['other comp'].astype(str).str.replace(',',''), errors='coerce').fillna(0).astype(int)    
        frame_full['pension'] = pd.to_numeric(frame_full['pension'].astype(str).str.replace(',',''), errors='coerce').fillna(0).astype(int)    



        
        #only keep executives with nonmissing compensation
        #frame_full['wrong'] = np.where( (frame_full['salary']==0) & (frame_full['total']==0), 1, 0)
        #frame_full = frame_full[frame_full['wrong']!=1]                
        #frame_full = frame_full.drop(columns=['wrong'])
        #correct cases with a person's position instead of a name

                    
        if app_frame_full is None:
            app_frame_full=frame_full
        else:    
            app_frame_full=app_frame_full.append(frame_full, ignore_index=True)
    
        if i==3:
            frame_full.to_csv(r'..\Edgar_tables.csv')
        # Appending the excel file
        if i>3:
            with open(r'..\Edgar_tables.csv', 'a', newline='', encoding="latin-1", errors="replace") as f:
                frame_full.to_csv(f, header=False)
                
        # First time file
        print("Current i:", i)
        
        #if i==40:
        #    break
        
    except Exception as e:
        error_n=error_n+1
        print("skipped observation")
        print(e) 
        err = type(e)      
        data = {"File Number": row[0],
                 'error': str(e),
                 "Link" : row[5],
                 "Excel Row Number": i-1
                }
        frame_full_error=pd.DataFrame(data, index=[0])                  
        frame_full = pd.DataFrame({'file number': row[0], 'gvkey': row[2],  'year_file': row[3], 'year':  row[3],
                 'firm name' : row[4], 'director name' : None, 'salary': None, 'bonus': None, 'stock': None,
                 'options': None, 'non equity' :  None, 'pension' : None, 'other comp' : None,
                 'total' :  None, 'table found' : 0 , 'link' : row[5] }, index =[0])  
        if app_frame_full is None:
            app_frame_full = frame_full
        else:
            app_frame_full=app_frame_full.append(frame_full, ignore_index=True)                 

        if error_n==1:
            frame_full_error.to_csv(r'..\error_ceo.csv')
            with open(r'..\Edgar_tables.csv', 'a', newline='', encoding="latin-1", errors="replace") as f:
                frame_full.to_csv(f, header=False)
                
        # Appending the excel file
        if error_n>1:
            with open(r'..\error_ceo.csv', 'a', newline='', encoding="latin-1", errors="replace") as f:
                frame_full_error.to_csv(f, header=False)        
            with open(r'..\Edgar_tables.csv', 'a', newline='', encoding="latin-1", errors="replace") as f:
                frame_full.to_csv(f, header=False)


