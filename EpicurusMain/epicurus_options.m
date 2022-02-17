classdef epicurus_options < staliro_options
% This file is part of EPIcuRus
% Copyright © [2020] – [2021] University of Luxembourg.
% Class definition for the EPIcuRus options
%
% opt = epicurus_options;
%
% The above function call sets the default values for the class properties. 
% For a detailed description of each property open the <a href="matlab: doc assume_options">assume_options help file</a>.
%
% To change the default values to user-specified values use the default
% object already created to specify the properties.
%
% E.g.: to change the number of assume iterations to 100, type
% opt.assumeIterations = 100;
     properties
        % the maximum number of iterations 
        assumeIterations= 30;
        % The number of Epicurus runs
        assumeStartRun=1;
        assumeEndRun=1;
        % Enabling writing internal assumptions of each iteration 
        writeInternalAssumptions=0;
        % the number of test cases per iteration
        testSuiteSize=30;
        % The number of test cases in the first iteration
        iteration1Size=30;
        % the number of control points 
        nbrControlPoints=1;
        % the test case generation policy. choose one from : 'UR','ART','IFBT_UR','IFBT_ART'
        policy='UR';
        % the desired fitness value
        desiredFitness=0;
        epsilon=10; % the fitness tolerence value in IFBT policy
        exploit=0;
        first=1;
        % Qvtrace check enabling
        qvtraceenabled=true;
        % Learning Method 
        learningMethod='DT';
        % Population size
        n=20;
        % maximum number of Pop
        MaxGen=10000;
        % crossover rate
        cr=0.9;
        % mutation rate
        mr=0.1;
        % parents selection threshold
        selection_threshold=0.9;
        % min value of the rand constant in assumptions 
        minRand=0;
        % max value of the rand constant in assumptions 
        maxRand=20;
        % best parents rate set for rank Selection
        selectionrate=0.2;
        % reproduction rate: probability of performing direct reproduction.
        % Usually 0.1
        reproduction_rate=0.1;
        
     end
        methods
          function obj = set.assumeIterations(obj,assumeIterations)
            obj.assumeIterations=assumeIterations;
          end
          function obj = set.qvtraceenabled(obj,qvtraceenabled)
            obj.qvtraceenabled=qvtraceenabled;
          end
          function obj = set.writeInternalAssumptions(obj,writeInternalAssumptions)
            obj.writeInternalAssumptions=writeInternalAssumptions;
          end        
          function obj = set.nbrControlPoints(obj,nbrControlPoints)
            obj.nbrControlPoints=nbrControlPoints;
          end
          function obj = set.policy(obj,policy)
            obj.policy=policy;
          end
          function obj = set.desiredFitness(obj,desiredFitness)
            obj.desiredFitness=desiredFitness;
          end
          function obj = set.epsilon(obj,epsilon)
            obj.epsilon=epsilon;
          end
          function obj = set.exploit(obj,exploit)
            obj.exploit=exploit;
          end
          function obj = set.iteration1Size(obj,iteration1Size)
            obj.iteration1Size=iteration1Size;
          end
          function obj = set.testSuiteSize(obj,testSuiteSize)
            obj.testSuiteSize=testSuiteSize;
          end
          function obj = set.first(obj,first)
            obj.first=first;
          end
          function obj = set.learningMethod(obj,learningMethod)
            obj.learningMethod=learningMethod;
          end
          function obj = set.n(obj,n)
            obj.n=n;
          end
          function obj = set.MaxGen(obj,MaxGen)
            obj.MaxGen=MaxGen;
          end
          function obj = set.cr(obj,cr)
            obj.cr=cr;
          end
          function obj = set.mr(obj,mr)
            obj.mr=mr;
          end
          function obj = set.selectionrate(obj,selectionrate)
            obj.selectionrate=selectionrate;
          end
          function obj = set.reproduction_rate(obj,reproduction_rate)
            obj.reproduction_rate=reproduction_rate;
          end
            function obj = set.assumeStartRun(obj,assumeStartRun)
                obj.assumeStartRun=assumeStartRun;
            end
        function obj = set.assumeEndRun(obj,assumeEndRun)
            obj.assumeEndRun=assumeEndRun;
        end

        end
end
