% Script to print content between 'reqdef' and 'endreqdef' in files ending with 'V1'
% in all subfolders of 'Yasuo Slash Eleanor challenges RT'
% Writes all results to a single CSV file

cd(fileparts(mfilename('fullpath')));
cd('..');
rootDir = 'LM_Challenges_rt';
filePattern = '**/*v1.rt'; % Recursive search for files ending with 'V1'
outputFile = '.output/all_reqdef_blocks.csv'; % Output file in current directory

files = dir(fullfile(rootDir, filePattern));
allRows = {}; % Collect all rows from all files

for k = 1:length(files)
    filePath = fullfile(files(k).folder, files(k).name);
    fid = fopen(filePath, 'r');
    if fid == -1
        fprintf('Could not open file: %s\n', filePath);
        continue;
    end
    % Add a row with only the file path in the first column
    allRows{end+1,1} = {'', '', ''};
    inBlock = false;
    while ~feof(fid)
        line = fgetl(fid);
        if ischar(line)
            if contains(line, 'reqdef') && ~contains(line, 'endreqdef')
                inBlock = true;
                continue; % skip the 'reqdef' line itself
            elseif contains(line, 'endreqdef')
                inBlock = false;
            elseif inBlock
                % Split the line at ', ' and store in a cell array
                line = strtrim(line);
                parts = strsplit(line, ', ');
                % Optionally, add filename as first column for traceability
                allRows{end+1,1} = [{filePath}, parts]; %#ok<AGROW>
            end
        end
    end
    fclose(fid);
end

% Write all collected rows to a single CSV file
if ~isempty(allRows)
    % Find the maximum number of columns
    maxCols = max(cellfun(@numel, allRows));
    % Pad rows with fewer columns
    paddedRows = cellfun(@(x) [x, repmat({''}, 1, maxCols-numel(x))], allRows, 'UniformOutput', false);
    T = cell2table(vertcat(paddedRows{:}));
    writetable(T, fullfile(outputFile), 'WriteVariableNames', false);
    fprintf('Written all reqdef blocks to %s\n', outputFile);
else
    fprintf('No reqdef blocks found in any file.\n');
end
disp('--- End of file content ---');