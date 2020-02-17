# -*- coding: utf-8 -*-
"""
Created on Wed Jan 29 09:02:31 2020

@author: tmc54
"""

# Generate wav files from mov files of subjects

# Imports
import os
import subprocess
import shutil

# Set up subject list
subjectList = [] # Fill in subject names

# Set up the paths
remotePath = '' # this will be where the subject's videos are contained
localPath = 'C:/Users/tmc54/Desktop/test'

# Call ffmpeg from within Python
# Extract audio from mov file, as a wav file
def generate_wavFile(video,output):
    command = "ffmpeg -i {video} {output}".format(video=video, output=output)
    subprocess.call(command,shell=True)

# Go to the specific subject's directory for each subject
for subjectName in subjectList:
    subjectPath = remotePath + subjectName + '/Probes' 
    os.chdir(subjectPath)

# Loop through all files in subject folder, find mov files, extract audio
    for fileName in os.listdir(subjectPath):
        if fileName.endswith('.mp4'):
            shutil.copy(fileName, localPath)
            os.chdir(localPath)
            outputName = os.path.splitext(fileName)[0] + '_extractedAudio.wav'
            generate_wavFile(fileName,outputName)
            os.chdir(subjectPath)
            
            
    # Move wav files into a new subfolder
    os.chdir(localPath)
    outputDirectory = subjectPath + '/extractedAudio'
    if not os.path.isdir(outputDirectory):
        os.mkdir(outputDirectory)
    for fileName in os.listdir(localPath):
        if fileName.endswith('.wav'):
            shutil.move(fileName, outputDirectory)