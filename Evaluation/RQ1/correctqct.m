% This file is part of Evaluation
% Copyright © [2020] – [2021] University of Luxembourg.
function correctqct(filename,uncorrect,correct)
    n=0;
    fid = fopen(filename);
    tline = fgetl(fid);
    if (tline==-1)
        disp('file is empty');
    else
        i=1;
        s={};
        while ischar(tline)
            if contains(tline,'NaN')
                n=1;
            end
            if contains(tline,uncorrect)
                disp(tline);
                tline=strrep(tline,uncorrect,correct);
            end
            s{i}=tline;
            tline = fgetl(fid);
            i=i+1;
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

