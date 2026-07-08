function [opt] = GetFileFormat(filePath, ELEMENTS)
%{   
GetFileFormat - Returns the options for reading in a file containing 
access data. This function assumes variable types and names 
   
Input: 
    filePath - Path to the file to import options from
    ELEMENTS - Array containing all variable names
   
Output:
    opt - Contains the structure of the table, including variable name and
    type
%}   
arguments (Input)
    filePath
    ELEMENTS
end

arguments (Output)
    opt
end

    opt = detectImportOptions(filePath);
    
    % Set variable types
    opt.Delimiter = ',';
    opt.VariableTypes{1} = 'datetime';
    opt.VariableTypes{2} = 'datetime';
    opt.VariableTypes{3} = 'double';
    opt.VariableTypes{4} = 'double';
    opt.VariableNames = ELEMENTS;
    
    % Date time formatting
    opt = setvaropts(opt, ELEMENTS{1}, 'InputFormat', "dd MMMM yyyy HH:mm:ss.SSS");
    opt = setvaropts(opt, ELEMENTS{2}, 'InputFormat', "dd MMMM yyyy HH:mm:ss.SSS");
end
