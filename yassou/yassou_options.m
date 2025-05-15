classdef yassou_options < epicurus_options
    % YassouOptions - Class to manage default options for the Yassou application.
    %
    % Properties:
    %   verbose      - Enable verbose output (default: true)
    %   logFile      - Log file name (default: 'yassou.log')
    %   maxIterations - Maximum number of iterations (default: 1000)
    %   tolerance    - Convergence tolerance (default: 1e-6)
    %   showPlots    - Enable or disable plotting (default: false)
    %   plotStyle    - Plot style (default: 'default')
    %
    % Methods:
    %   YassouOptions - Constructor to initialize default options.

    properties

        runsStartId = 1; % Start ID for runs
        runsEndId = 1;   % End ID for runs

        overallApproach = 'iterative'; % 'iterative' | 'direct' | 'epicurus'
        repairMethod = 'none'; % 'none' | 'epicurus' | 'yassou'
        reqIdToRepair = -1; % ID of the requirement to repair. If -1, repair all of them 


    end

    methods
        function obj = YassouOptions()
            % Constructor to initialize default options.
            % No additional setup required for now.
        end
    end
end