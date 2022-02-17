% This file is part of Evaluation
% Copyright © [2020] – [2021] University of Luxembourg.
function information=inf_index(file,inputsnames,inputsRanges)
    
    fid=fopen(file,'r');
    assumptions=textscan(fid,'%s','Delimiter','\n');
    fclose(fid);
    information=zeros(numel(assumptions{:}),1);
    for i=1 : numel(assumptions{:})
        inputs_of_as={};
        ranges_of_as={};
        testcases={};
        index=0;
        assumption=assumptions{:}{i};
        evaluation_statement=assumption;
        for inputindex=1: numel(inputsnames) 
            if contains(assumption,inputsnames{inputindex})
                index=index+1;
                inputs_of_as{index}=inputsnames{inputindex};
                ranges_of_as{index}=inputsRanges(inputindex,:);  
                testcases{index}=inputsRanges(inputindex,1):0.01:inputsRanges(inputindex,2);
            end
        end
        D = testcases;
        try
            [D{:}] = ndgrid(testcases{:});
        catch
            [D{:}] = ndgrid(testcases);
        end
        ts = cell2mat(cellfun(@(m)m(:),D,'uni',0));
        for in = 1 : numel(inputs_of_as)
            evaluation_statement=replace(evaluation_statement,inputs_of_as{in},['ts(:,',num2str(in),')'] );            
        end
        evaluation_statement=replace(evaluation_statement,'^','.^');
        evaluation_statement=replace(evaluation_statement,'*','.*');
        %evaluation_statement=replace(evaluation_statement,'=','==');
        evaluation_statement=replace(evaluation_statement,'and','&');
        evaluation_statement=replace(evaluation_statement,'or','|');
        try
            assumption_holds=eval(evaluation_statement);
        catch
            disp('err');
        end
        nbr_hold=sum(assumption_holds);
        information(i)=nbr_hold/size(ts,1);
    end
end
