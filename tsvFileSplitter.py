import pandas as pd
import os

path = "C:/Users/tmc54/Desktop"
os.chdir(path)
data = pd.read_table('ACESeg7-10-2019.tsv', low_memory = 'False')

data.RecordingName

subjectNames = set(data.RecordingName)

while len(subjectNames) > 0:
    subjectName = subjectNames.pop()
    subjectFile = data[data.RecordingName == subjectName]
    
    fileName = subjectName + '.xlsx'
    subjectFile.to_excel(fileName)