% This file is part of Evaluation
% Copyright © [2020] – [2021] University of Luxembourg.
function correctqct1(filename,added)
    n=0;
    fid = fopen(filename);
    tline = fgetl(fid);
    if (tline==-1)
        disp('file is empty');
    else
        i=1;
        s={};
        while ischar(tline)
%             if contains(tline,added)
%                 n=1;
%             end
            if contains(tline,'set k_max')
                disp(tline);
%                 tline=strrep(tline,uncorrect,correct);
                s{i}=tline;
                s{i+1}=added;
                i=i+2;
            else
                s{i}=tline;
                i=i+1;
            end
            tline = fgetl(fid);
        end
        if (n==1)
            delete(filename);
        else
            fid1 = fopen(filename, 'w');
            if fid1 == -1, error('Cannot open file %s', filename); end
            fprintf(fid1,'%s\n', s{:});
            fclose(fid1);
        end
    end
    fclose(fid);
end

