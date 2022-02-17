#!/bin/bash
source /etc/profile

module use swenv/default-env/v1.2-20191021-production
module load math/MATLAB/2019b

matlab -nodisplay -nosplash -r "addpath(genpath('/home/users/kgaaloul/Projects/snt200023-epicurus/staliro'));setup_staliro(); exit();"
