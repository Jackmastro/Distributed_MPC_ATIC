function saveTikzPlot(filename, figHandle, varargin)
    % Save a specific figure as a TikZ file

    % Determine the current directory of the script
    currentDir = fileparts(mfilename('fullpath'));
    outputFilePath = fullfile(currentDir, filename);

    % Make the specified figure the current figure
    figure(figHandle);

    % Save the specified figure as a TikZ file with additional arguments
    matlab2tikz(outputFilePath, 'figurehandle', figHandle, varargin{:});
end
