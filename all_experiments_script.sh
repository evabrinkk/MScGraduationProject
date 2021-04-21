#!/bin/bash

# Script to run all the experiments in the server
# Mikhail: make sure path is right and the number of threads

# E99 Test Run to see if everything ok
~/Downloads/NetLogo6.1.1/netlogo-headless.sh --model Model_Coupled_withoutplots_4152021.nlogo --experiment E99_Experiment --table results_E99test.csv --threads 1
echo 'Experiment 99 TEST finished'

# E0 BaselineAllScenarios
~/Downloads/NetLogo6.1.1/netlogo-headless.sh --model Model_Coupled_withoutplots_4152021.nlogo --experiment E0_BaselineAllScenarios --table E0_BaselineAllScenarios.csv --threads 1
echo 'Experiment 0 finished'

# E1 AllPoliciesCompetitive0
~/Downloads/NetLogo6.1.1/netlogo-headless.sh --model Model_Coupled_withoutplots_4152021.nlogo --experiment E1_AllPoliciesCompetitive0 --table E1_AllPoliciesCompetitive0.csv --threads 1
echo 'Experiment 1 finished'


# E2
~/Downloads/NetLogo6.1.1/netlogo-headless.sh --model Model_Coupled_withoutplots_4152021.nlogo --experiment E2_AllPoliciesCompetitive10 --table E2_AllPoliciesCompetitive10.csv --threads 1
echo 'Experiment 2 finished'

# E3
~/Downloads/NetLogo6.1.1/netlogo-headless.sh --model Model_Coupled_withoutplots_4152021.nlogo --experiment E3_AllPoliciesCompetitive20 --table E3_AllPoliciesCompetitive20.csv --threads 1
echo 'Experiment 3 finished'


# E4
~/Downloads/NetLogo6.1.1/netlogo-headless.sh --model Model_Coupled_withoutplots_4152021.nlogo --experiment E4_AllPoliciesCompetitive30 --table E4_AllPoliciesCompetitive30.csv --threads 1
echo 'Experiment 4 finished'

# E5
~/Downloads/NetLogo6.1.1/netlogo-headless.sh --model Model_Coupled_withoutplots_4152021.nlogo --experiment E5_AllPoliciesCompetitive40 --table E5_AllPoliciesCompetitive40.csv --threads 1
echo 'Experiment 5 finished'

# E6
~/Downloads/NetLogo6.1.1/netlogo-headless.sh --model Model_Coupled_withoutplots_4152021.nlogo --experiment E6_BaselineTimeSlotAllScenarios --table E6_BaselineTimeSlotAllScenarios.csv --threads 1
echo 'Experiment 6 finished'

# SA
# this one is 180 000 runs!! think about this
~/Downloads/NetLogo6.1.1/netlogo-headless.sh --model Model_Coupled_withoutplots_4152021.nlogo --experiment SA_All --table SA_All.csv --threads 1
echo 'Experiment SA finished'
