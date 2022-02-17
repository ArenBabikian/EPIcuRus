classdef gp_epicurus_options < staliro_options
% This file is part of EPIcuRus
% Copyright © [2020] – [2021] University of Luxembourg.
% Class definition for the gp_epicurus options
%
% gp_opt = gp_epicurus_options;
%
% The above function call sets the default values for the class properties. 
% For a detailed description of each property open the <a href="matlab: doc gp_epicurus_options">gp_epicurus_options help file</a>.
%
% To change the default values to user-specified values use the default
% object already created to specify the properties.
%
% E.g.: to change the population size to 100, type
% gp_opt.pop_size = 100;
     properties      
        % Population size
        pop_size=20;
        % maximum number of Pop
        gen_size=10000;
        % crossover rate
        cross_rate=0.9;
        % mutation rate
        mut_rate=0.1;
        % min value of the rand constant in assumptions 
        minRand=-0.01;
        % max value of the rand constant in assumptions 
        maxRand=0.01;
        % best parents rate set for rank Selection
        sel_rate=0.2;
        % The maximum depth level of an assumption's tree 
        max_depth=5;        
        % The maximum number of conjunctions that will be considered during the generation
        maxNbrConj=3;
        maxNbrDisj=2;
        % the selection method to choose for the selection phase (rankSelection, rouletteSelection, tournamentSelection or bestSelection)
        sel_crt='tournamentSelection';
        % tournamentk is the tournament size - the proportion selected from the previous generation as parents for the next population.
        t_size=5;
        % Search algorithm. Select among: GP, Randomsearch
        algorithm='GP';
        % old population usage percentage in initial population
        init_Ratio=0.5;
        % the maximum number of nodes allowed in the first crosspoint
        crosspointsMaxNodes=3;
        % the fitness function
        fitness=@(vsafe,informative)vsafe+(floor(vsafe)*informative);
     end
        methods
          function obj = set.t_size(obj,t_size)
            obj.t_size=t_size;
          end
          function obj = set.sel_crt(obj,sel_crt)
            obj.sel_crt=sel_crt;
          end
          function obj = set.max_depth(obj,max_depth)
            obj.max_depth=max_depth;
          end
          function obj = set.pop_size(obj,pop_size)
            obj.pop_size=pop_size;
          end
          function obj = set.gen_size(obj,gen_size)
            obj.gen_size=gen_size;
          end
          function obj = set.cross_rate(obj,cross_rate)
            obj.cross_rate=cross_rate;
          end
          function obj = set.mut_rate(obj,mut_rate)
            obj.mut_rate=mut_rate;
          end 
          function obj = set.minRand(obj,minRand)
            obj.minRand=minRand;
          end 
          function obj = set.maxRand(obj,maxRand)
            obj.maxRand=maxRand;
          end
          function obj = set.sel_rate(obj,sel_rate)
            obj.sel_rate=sel_rate;
          end
          function obj = set.algorithm(obj,algorithm)
            obj.algorithm=algorithm;
          end
          function obj = set.maxNbrDisj(obj,maxNbrDisj)
            obj.maxNbrDisj=maxNbrDisj;
          end
          function obj = set.maxNbrConj(obj,maxNbrConj)
            obj.maxNbrConj=maxNbrConj;
          end
          function obj = set.init_Ratio(obj,init_Ratio)
            obj.init_Ratio=init_Ratio;
          end
          function obj = set.crosspointsMaxNodes(obj,crosspointsMaxNodes)
            obj.crosspointsMaxNodes=crosspointsMaxNodes;
          end
          function obj = set.fitness(obj,fitness)
            obj.fitness(vsafe,informative)=fitness(vsafe,informative);
          end
        end
end
