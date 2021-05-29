#!/bin/bash

# Script to run all the experiments in the server
# Mikhail: make sure path is right and the number of threads


# E0 BaselineAllScenarios
~/Downloads/NetLogo6.1.1/netlogo-headless.sh --model CoupledModel_afterGL_195.nlogo --experiment Ex0_BaselineAllScenarios --table Ex0_BaselineAllScenarios.csv --threads 1
echo 'Experiment 0 finished'

# E1 AllPoliciesCompetitive0
~/Downloads/NetLogo6.1.1/netlogo-headless.sh --model CoupledModel_afterGL_195.nlogo --experiment Ex1_AllPoliciesCompetitive0 --table Ex1_AllPoliciesCompetitive0.csv --threads 1
echo 'Experiment 1 finished'


# E2
~/Downloads/NetLogo6.1.1/netlogo-headless.sh --model CoupledModel_afterGL_195.nlogo --experiment Ex2_AllPoliciesCompetitive10 --table Ex2_AllPoliciesCompetitive10.csv --threads 1
echo 'Experiment 2 finished'

# E3
~/Downloads/NetLogo6.1.1/netlogo-headless.sh --model CoupledModel_afterGL_195.nlogo --experiment Ex3_AllPoliciesCompetitive20 --table Ex3_AllPoliciesCompetitive20.csv --threads 1
echo 'Experiment 3 finished'


# E4
~/Downloads/NetLogo6.1.1/netlogo-headless.sh --model CoupledModel_afterGL_195.nlogo --experiment Ex4_AllPoliciesCompetitive30 --table Ex4_AllPoliciesCompetitive30.csv --threads 1
echo 'Experiment 4 finished'

# E5
~/Downloads/NetLogo6.1.1/netlogo-headless.sh --model CoupledModel_afterGL_195.nlogo --experiment Ex5_AllPoliciesCompetitive40 --table Ex5_AllPoliciesCompetitive40.csv --threads 1
echo 'Experiment 5 finished'

# E6
~/Downloads/NetLogo6.1.1/netlogo-headless.sh --model CoupledModel_afterGL_195.nlogo --experiment Ex6_TimeslotBaselineP1_AllScenarios --table Ex6_TimeslotBaselineP1_AllScenarios.csv --threads 1
echo 'Experiment 6 finished'


### do after
# SA
# this one is 180 000 runs!! think about this
#~/Downloads/NetLogo6.1.1/netlogo-headless.sh --model Model_Coupled_withoutplots_4152021.nlogo --experiment SA_All --table SA_All.csv --threads 1
#echo 'Experiment SA finished'
