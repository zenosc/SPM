function s=config

%%%%
%   FORMAT
%%%%
s.Format = {'nanoscope5','sdf','nanonisspectrum','sxm','gxsmvp'};

%%%%
%   USER POSTPROCESSING FUNCTIONS
%%%%
s.UserFunctions = {'Fit(channel,name)'};

%%%%
%   CACHING
%%%%
s.Caching.Enabled = false;
s.Caching.Folder = '.'; % either an absolute path or relative path from parent directory of the file
end
