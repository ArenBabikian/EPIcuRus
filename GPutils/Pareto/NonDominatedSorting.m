% This file is part of GP-utils
% Copyright © [2020] – [2021] University of Luxembourg.
function [pop, F]=NonDominatedSorting(pop,opt)

    for i=1:opt.n
        pop(i).DominationSet=[];
        pop(i).DominatedCount=0;
    end
    
    F{1}=[];
    
    for i=1:opt.n
        for j=i+1:opt.n
            p=pop(i);
            q=pop(j);
            
            if Dominates(p,q)
                p.DominationSet=[p.DominationSet j];
                q.DominatedCount=q.DominatedCount+1;
            end
            
            if Dominates(q,p)
                q.DominationSet=[q.DominationSet i];
                p.DominatedCount=p.DominatedCount+1;
            end
            
            pop(i)=p;
            pop(j)=q;
        end
        
        if pop(i).DominatedCount==0
            F{1}=[F{1} i];
            pop(i).Rank=1;
        end
    end
    
    k=1;
    
    while true
        
        Q=[];
        
        for i=F{k}
            p=pop(i);
            
            for j=p.DominationSet
                q=pop(j);
                
                q.DominatedCount=q.DominatedCount-1;
                
                if q.DominatedCount==0
                    Q=[Q j]; 
                    q.Rank=k+1;
                end
                
                pop(j)=q;
            end
        end
        
        if isempty(Q)
            break;
        end
        
        F{k+1}=Q; 
        
        k=k+1;
        
    end
    

end
