function XMLdump(spm)
%XMLDUMP Dump a summary of the object in XML

f=get(spm);

for i=1:length(spm.Channel)
    Channel(i)=get(spm.Channel(1));
end
f=rmfield(f,'Channel');
f=setfield(f,'Channel',Channel);

Pref=[]; Pref.XmlEngine = 'Xerces';  % use Xerces xml generator directly
Pref.StructItem=false;

% Prepare final XML
final = [];
% Read the original XML
original=spm.XML;
% Final is original with overwritten "Package" part
final = setfield(original,'Package',f);

SPM.lib.xml_io_tools.xml_write(spm.UserDataFile,final,'SPM',Pref);

end
