% This file is part of GP-utils
% Copyright © [2020] – [2021] University of Luxembourg.
% EVALUATEPOP evaluates a population of individuals
% candidate assumptions are assumptions with fitness =1 
% the number of total candidate assumption should not be greater than the
% maximum setting
function pop=evaluatePop(pop,count,opt)

% Non-Dominated Sorting
% [pop, F]=NonDominatedSorting(pop,opt);
% Show Iteration Information
% disp(['Iteration ' num2str(count) ': Number of best assumptions = ' num2str(numel(F{1}))]);
%     
% for f=F{1}
%     disp(['v-safe and informative fitness of best assumption A_',num2str(f),' = ',num2str(pop(f).f1),' and ',num2str(pop(f).f2),' (respectively)']);
% end
% Plot individuals 
%     figure(1);
%     PlotFitness(pop,F);
%     pause(0.01);
% Calculate Crowding Distance
% pop=CalcCrowdingDistance(pop,F);


%%
    % [id1, minval1]=min (pop.f1)
    % [id2, minval2]=min (pop.f2)
    % goal =[minval1, minval2];
%     nf = 2; % number of objective functions
%     N = opt.n; % number of points for plotting = number of individuals / pop
%     onen = 1/N;
%     x = zeros(N+1,1);
%     f = zeros(N+1,nf);
%     fun = @simple_mult;
%     x0 = 0.5;
%     options = optimoptions('fgoalattain','Display','off');
%     for r = 0:N
%         t = onen*r; % 0 through 1
%         weight = [t,1-t];
%         [x(r+1,:),f(r+1,:)] = fgoalattain(fun,x0,goal,weight,...
%             [],[],[],[],[],[],[],options);
%     end
% 
%     figure
%     plot(f(:,1),f(:,2),'k.');
%     xlabel('f_1')
%     ylabel('f_2')

%%
end
