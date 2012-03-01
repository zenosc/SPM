classdef spm < handle
    %Abstract class representing a scan
    % SPM Properties:
    %   Date - Date of acquisition
    %   Channel - Array of channel object
    %   Width - Scan width in nm
    %   Height - Scan height in nm
    %   Format - File format
    %
    % SPM Methods:
    %   load - Load file
    %
    %SPM forms the abstraction that is common to all scan (we mean by scan
    %a set of data channel acquired simultaneously). Every format reader is
    %subclassed from it which enforces a set of common properties and
    %methods that allow to interact with the data in a standard way.
    %
    %Configuration file has to be completed in order for this class to work
    %properly. You need to specify the formats you want to support and the
    %location where you want to cache data.

    properties(SetAccess=protected,Abstract=true)
        Date; % Date of acquisition
        Channel; % Array of channel object
        Width; % Scan width in nm
        Height; % Scan height in nm
        Format; % File format
        Type;
    end
    
    properties(Hidden=true,SetAccess=protected)
        UserDataFile; % Absolute filepath to XML with UserData
    end
    
    properties(SetAccess=protected)
        FromCache=false; % Read from cache?
        Filename; % Filename
        Path; % Absolute filepath
        Header=struct; % Headers of the file
    end
    
    properties
        UserChannel; % Array of userchannel object
    end
    properties(Dependent=true,SetAccess=protected)
        UserData;
    end
    
    methods
        function obj=spm(path)
            % Sanitize file path and try loading from cache 
            [pathstr, name, ext] = fileparts(path);
            obj.Path = GetFullPath(path);
            obj.UserDataFile = [obj.Path '.xml'];
            obj.Filename = [name ext];
            cfg = SPM.config;
            
            % If caching enabled, look for cached file
            if cfg.CachingEnabled == true
                [path_cached_file,cached_filename] = obj.cachedFile;
                
                % Look if cached file exists and loads it
                if (exist(path_cached_file,'file')==2)
                    disp('Loading from cache');
                    load(path_cached_file,'-mat');
                    % Retrieve the object stored in a dummy variable
                    eval(['obj=' genvarname(obj.Filename) ';']);
                    % Clear the dummy variable
                    eval(['clear ' genvarname(obj.Filename)]);
                    
                    % Make sure the cached path is defined in current
                    % filesystem (in case it was saved on a different
                    % system)
                    obj.Path = GetFullPath(path);
                    
                    % Flagged in order to skip file parsing in subclass
                    obj.FromCache = true;
                    return;
                end
            end
        end
    end
    
    methods(Access=public)
        ch=ChannelByName(spm,name)
        uch=UserChannelByName(spm,name)
        getChannelInfo(spm)
        Save(spm)
        Delete(spm)
    end
    
    methods(Static=true)
        function spm=load(path)
            % Try to load the file using the formats defined in the
            % configuration file
            cfg = SPM.config;
            for i=1:length(cfg.Format)
                eval(['bool=SPM.parser.' cfg.Format{i} '.spm.is_valid_format(''' path ''');']);
                if(bool)
                    disp(['File format is ' cfg.Format{i}]);
                    eval(['spm=SPM.parser.' cfg.Format{i} '.spm(''' path ''');']);
                    return
                end
            end
            
            disp('Cannot load this file');
            spm=false;
        end
    end
    
    methods(Abstract=true,Access=public,Static=true)
        bool=is_valid_format(filename);
    end
    
    methods
        function s=get.UserData(spm)
            % Sanitize file path and try loading from cache
            s=SPM.xml_io_tools.xml_read(spm.UserDataFile)
        end
    end
    
    methods(Access=protected)
        [path_cached_file,cached_filename] = cachedFile(spm)
    end
end
