% run in Training and Validation folders which only contain imagefiles

filenames=dir
for i=3:size(filenames,1),
    folder=strsplit(filenames(i).name,'-');
    folder=folder{1};
    mkdir(string(folder));
    movefile(string(filenames(i).name),strcat(string(folder),'/'));
end

