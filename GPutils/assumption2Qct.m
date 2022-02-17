% This file is part of GP-utils
% Copyright © [2020] – [2021] University of Luxembourg.
function qctassumption=assumption2Qct(A,kmax,inputs,state,opt)
% ASSUMPTION2QCT takes the assumption statement and returns an assumption statement readable in qct language
    qctassumption='';
    if isempty(A.cp)
        return;
    else
        if state.isboolean==1
            
            assumption=A.assum;

                for in = 1 : numel(inputs)   
                    %index of the input in name in the assumption statement
                    %for all control points
                    indexes_not=regexp(assumption,['not ',inputs{in},'\d']);
                    %index of the control points associated with the input
                    first_index_not_after_assumption_update=indexes_not;
                    cp_index_not_after_assumption_update=first_index_not_after_assumption_update+length(['not ',inputs{in}]);
                    while ~isempty(cp_index_not_after_assumption_update)

                        if opt.nbrControlPoints>1
                            control_point=str2double(assumption(cp_index_not_after_assumption_update(1)));
                            startk= control_point-1;
                            endk=control_point-1;
                        else
                            startk=0;
                            endk=kmax-1;
                            control_point='1';
                        end
                        k_statement=strjoin(['all_k(k>=',num2str(startk),' and k<=',num2str(endk),' impl not',strcat(inputs(in),'{k})')]);
                        assumption=replace(assumption,['not ',inputs{in},num2str(control_point)],k_statement);
                        first_index_not_after_assumption_update=regexp(assumption,['not ',inputs{in},'\d']);
                        cp_index_not_after_assumption_update=first_index_not_after_assumption_update+length(['not ',inputs{in}]);
                    end
                    indexes=regexp(assumption,[inputs{in},'\d']);
                    %index of the control points associated with the input
%                     cp_indexes=indexes+length(inputs{in});
                    first_index_after_assumption_update=indexes;
                    cp_index_after_assumption_update=first_index_after_assumption_update+length(inputs{in});
                    while ~isempty(cp_index_after_assumption_update)

                        if opt.nbrControlPoints>1
                            control_point=str2double(assumption(cp_index_after_assumption_update(1)));
                            startk= control_point-1;
                            endk=control_point-1;
                        else
                            startk=0;
                            endk=kmax-1;
                            control_point='1';
                        end
                        k_statement=strjoin(['all_k(k>=',num2str(startk),' and k<=',num2str(endk),' impl ',strcat(inputs(in),'{k})')]);
                        assumption=replace(assumption,[inputs{in},num2str(control_point)],k_statement);
                        first_index_after_assumption_update=regexp(assumption,[inputs{in},'\d']);
                        cp_index_after_assumption_update=first_index_after_assumption_update+length(inputs{in});
                    end

                end
            qctassumption=assumption;

                
        else
            cp_index=1;
            disjunctions=strsplit(A.qct,'or');
            for d=1:size(disjunctions,2)
                conjassumption='';
                constraints=strsplit(disjunctions{d},'and');
                for i = 1:size(constraints,2)
                    try
                        control_point=A.cp(cp_index);
                    catch
                        control_point=-1;
                    end
                    nbr_inputs=size(strfind(constraints{i},'of_k'),2);
                    if control_point==-1
                        % in case constant<constant
                        qctconstraint='';
                    else
                        ksteps=round((kmax)/opt.nbrControlPoints);
                        startk= round((control_point-1)*ksteps);
                        endk=round(startk+ksteps);
                        qctconstraint=strjoin(['all_k(k>=',num2str(startk),' and k<=',num2str(endk),' impl ',constraints(i),')']);
                        qctconstraint=replace(qctconstraint,'of_k','{k}');
                    end
                    if ~isempty(conjassumption) && ~isempty(qctconstraint)
                        conjassumption=strjoin({conjassumption,qctconstraint},' and ');
                    else
                        conjassumption=qctconstraint;
                    end
                    cp_index=cp_index+nbr_inputs;
                end
                if ~isempty(qctassumption) && ~isempty(conjassumption)
                    qctassumption=strjoin({qctassumption,conjassumption},') or (');
                else
                    qctassumption=conjassumption;
                end
            end
            if ~isempty(qctassumption)
                qctassumption=strcat('(',qctassumption,')');
            end
        end
    end
end
