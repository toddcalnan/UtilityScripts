% Run on the output files of tsvSplitter.py
% For whatever reason, this script will not run on Todd's work desktop, but
% seems to work everywhere else (invalid data range issue, xlswrite).
% Likely a RAM issue
% Output is a segmented xls file for each subject, ready to be run through
% the EGT Master file.

clear
thePath = 'C:\Users\tmc54\Desktop\ACE_EGT';
cd(thePath)
outputPath = 'C:\Users\tmc54\Desktop\ACE_Segmented_EGT';
mainFolder = dir;
listOfSubjectFolders = {mainFolder(3:end).name};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
segmentNames={'DB1' 'DB2' 'DB3' 'DB4' 'DB5' 'DB6' 'DB7' 'DB8' 'DB9' ...
    'DB10' 'DB11' 'JAmonkey' 'JAmoose' 'JArooster' 'JApenguin' 'sandwich1'...
    'sandwich2' 'MTmonkey' 'MTmoose' 'MTrooster' 'MTpenguin'};
numberOfSubjects=size(listOfSubjectFolders,2);

%% Create cell array of segment times

sampleRate = 120;
DB1 = floor([0.098, 5.527]*sampleRate);
Sandwich1 = floor([5.670, 46.955]*sampleRate);
DB2 = floor([48.813, 53.813]*sampleRate);
JA_Moose = floor([53.955, 61.955]*sampleRate);
DB3 = floor([62.670, 67.098]*sampleRate);
JA_Rooster = floor([67.241, 74.813]*sampleRate);
DB4 = floor([75.241, 79.385]*sampleRate);
JA_Monkey = floor([79.527, 85.527]*sampleRate);
DB5 = floor([86.955, 91.098]*sampleRate);
JA_Penguin = floor([92.098, 99.813]*sampleRate);
DB6 = floor([100.527, 106.384]*sampleRate);
Sandwich2 = floor([106.955, 124.527]*sampleRate);
DB7 = floor([126.527, 134.527]*sampleRate);
MT_Monkey = floor([136.098, 141.098]*sampleRate);
DB8 = floor([141.384, 145.527]*sampleRate);
MT_Penguin = floor([145.670, 152.098]*sampleRate);
DB9 = floor([152.384, 156.670]*sampleRate);
MT_Rooster = floor([157.813, 163.670]*sampleRate);
DB10 = floor([164.098, 168.527]*sampleRate);
MT_Moose = floor([169.527, 176.098]*sampleRate);
DB11 = floor([176.241, 180.813]*sampleRate);

conditions = [{DB1}, {Sandwich1}, {DB2}, {JA_Moose}, {DB3}, {JA_Rooster}, {DB4}, {JA_Monkey}, {DB5}, {JA_Penguin}, {DB6}, {Sandwich2}, {DB7}, {MT_Monkey}, {DB8}, {MT_Penguin}, {DB9}, {MT_Rooster}, {DB10}, {MT_Moose}, {DB11}];

%% Remove rows that aren't in segments

rowsToRemove = 0;
for i = 1:(size(conditions,2)-1)
    rowsToRemove = [rowsToRemove, conditions{i}(2):conditions{i+1}(1)]; % remove the rows between segment times
end

rowsToRemove = [1:conditions{1}(1), rowsToRemove]; % remove the rows before the first segment starts

%% Loop through each subject

for folderNumber=1:numberOfSubjects-1 % -1 becuase the unsplit tsv file generally reside in the folder with the split files
    cd(thePath)
    varname = listOfSubjectFolders{folderNumber}(1:9); % 1-9 to cut out the .xlsx part of the file name 
    filename=[ varname '.xlsx'] 
    [num, ~, raw]=xlsread(filename); % load the subject's Excel file
    headers = raw(1,2:end); % first row of the Excel file, will be removed to make the segmentation easier, and then added back in at the end
    raw = raw(2:end,2:end); % remove the first row, since it is just the headers, removing the first column, since the tsvSplitter keeps rowNumber as the first column, which is unnecessary for us
    totalNumberOfRows = size(num,1);
    rowsToRemove = [rowsToRemove, conditions{end}(2):totalNumberOfRows]; % remove the rows after the last segment finishes
    
    for i = 1:size(conditions,2)
        raw(conditions{i}(1):conditions{i}(2), 16) = {num2str(i)}; % the actual segmentation process, renaming the rows in the Segment Name column 
    end
    
    %% Give a simple yes or no on if a row should be removed or not from the final output
    % There is a better way to do this, so I'll be redoing this section at some point
    
    removeColumn = cell(totalNumberOfRows,1);
    for rowNumber = 1:totalNumberOfRows
        if any(ismember(rowsToRemove, rowNumber)) % if a row is listed in rowsToRemove, that row gets a 1
            removeColumn{rowNumber, 1} = 1;
        else 
            removeColumn{rowNumber, 1} = 0;
        end
    end
    
    cleanMatrix = raw(find([removeColumn{:,end}] == 0), :); % find where the removeColumn is 0, save all of those rows from raw to a new matrix
    cleanMatrix = [headers; cleanMatrix]; % add the headers column back in

    %% Output
    
    system('taskkill /F /IM EXCEL.EXE'); % kill Excel, sometimes this script crashes without this line
    outputFileName = [varname '_segmented.xls'];
    cd(outputPath)
    xlswrite(outputFileName,cleanMatrix)
    clear rowsToRemove
    clear removeColumn
    clear cleanMatrix
end