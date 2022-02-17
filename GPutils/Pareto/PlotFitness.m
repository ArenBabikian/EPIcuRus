% This file is part of GP-utils
% Copyright © [2020] – [2021] University of Luxembourg.
function PlotFitness(pop,F)
    F1=pop(F{1});
    plot([pop.f1],[pop.f2],'b.','MarkerSize',15)
    hold on;
    plot([F1.f1],[F1.f2],'r*','MarkerSize',15)
    xlabel('1^{st} Objective: v-safe');
    ylabel('2^{nd} Objective: informative');
    title('Solutions');
    grid on;

end
