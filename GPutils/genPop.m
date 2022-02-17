% This file is part of GP-utils
% Copyright © [2020] – [2021] University of Luxembourg.
function pop=genPop(Best,state,ts_labels,ts,tsinputsMap,opt,gp_opt)
% GENPOP generates a new population by applying crossover and mutation on
% the previous population
% INputs:   Best: the selected individuals from last population
%           state: contains the operators list used for GP and other items(i.e.,root type)
%           tsinput: the test suite values
%           ts_labels: the verdicts associated to the test suite
%           inputnames: the list of input names 
%           opt: Epicurus options
%           gp_opt: GP options
% OUTPUTS:  pop: the new generation
    pop=struct('id',[],'tree',[],'str','','assum','','qct','','cp',[],'vsafe',[],'informative',[],'fitness',[],'depth',[],'origin','');
    popsize=gp_opt.pop_size;
    % the best assumption is always reproduced
    T = struct2table(Best);
    sortedT = sortrows(T, 'fitness');
    sortedS = table2struct(sortedT);
    pop(1)=sortedS(end);
    currentsize=2;
    while currentsize<popsize    
        % first choose between reproduction and crossover:
        rrate=1-gp_opt.cross_rate;
        if (rrate>0 && rand(1,1)<rrate)
            % reproduction
            rep=Best(1:end-1);
            pop(currentsize)=rep(randi(size(rep,2)));
            currentsize=currentsize+1;
        else   
            % Crossover
            
            x2=[];
            % search for the crosspoints until x2 is not empty
            while isempty(x2)
                parent=Best(randperm(numel(Best),2));
                ind1=parent(1);
                ind2=parent(2);
                if opt.nbrControlPoints>1
                    % For multiple control points
                    % problem: the control point associated to the crosspoint of Parent1 may not
                    % exist in parent2
                    % solution: select only parents that have common control points (for multiple control points)
                    cp1=getCP(ind1.tree);
                    cp2=getCP(ind2.tree);
                    % get common control points from two parents
                    common_cps=intersect(cp1,cp2);
                else
                    % for single control point, the common is cp =1
                    common_cps=1;
                end
                if state.isboolean==1
                    [x1,x2]= chooseCrosspointsForBooleans(ind1,ind2,gp_opt);
                else
                    [x1,x2] = chooseCrosspoints(ind1,ind2,common_cps,gp_opt,opt);
                end
            end
            try
            [pop(currentsize),pop(currentsize+1)]=feval('crossover',ind1,ind2,x1,x2,currentsize,ts_labels,ts,tsinputsMap,state,gp_opt);
                    catch
                        disp('crossover..');
                    end            % mutation
            if rand < gp_opt.mut_rate
                mutated=pop(currentsize);
                try
                    pop(currentsize)=feval('mutation',mutated,currentsize,state,ts_labels,ts,tsinputsMap,opt,gp_opt);
                catch
                    disp('mutating..');
                end
            end
            currentsize=currentsize+2;
        end
    end
    % check if the last individual is generated
    % if not, apply reproduction 
    if currentsize==popsize
        % reproduction
        Best=shuffle(Best);
        pop(currentsize)=Best(1);
    end      
end
