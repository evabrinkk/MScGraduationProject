#!/bin/bash

# Script to run all the experiments in the server
# Mikhail: make sure path is right and the number of threads

# E99 Test Run to see if everything ok
~/Downloads/NetLogo6.1.1/netlogo-headless.sh --model Model_Coupled_withoutplots_4152021.nlogo --experiment E99_Experiment --table results_E99test.csv --threads 1
echo 'Experiment 99 TEST finished'

# E0 BaselineAllScenarios
~/Downloads/NetLogo6.1.1/netlogo-headless.sh --model Model_Coupled_withoutplots_4152021.nlogo --experiment E0_BaselineAllScenarios(10x) --table E0_BaselineAllScenarios(10x).csv --threads 1
echo 'Experiment 0 finished'

# E1 AllPoliciesCompetitive0
~/Downloads/NetLogo6.1.1/netlogo-headless.sh --model Model_Coupled_withoutplots_4152021.nlogo --experiment E1_AllPoliciesCompetitive0(10x) --table E1_AllPoliciesCompetitive0(10x).csv --threads 1
echo 'Experiment 1 finished'


# E2
~/Downloads/NetLogo6.1.1/netlogo-headless.sh --model Model_Coupled_withoutplots_4152021.nlogo --experiment E2_AllPoliciesCompetitive10(10x) --table E2_AllPoliciesCompetitive10(10x).csv --threads 1
echo 'Experiment 2 finished'

# E3
~/Downloads/NetLogo6.1.1/netlogo-headless.sh --model Model_Coupled_withoutplots_4152021.nlogo --experiment E3_AllPoliciesCompetitive20(10x) --table E3_AllPoliciesCompetitive20(10x).csv --threads 1
echo 'Experiment 3 finished'


# E4
~/Downloads/NetLogo6.1.1/netlogo-headless.sh --model Model_Coupled_withoutplots_4152021.nlogo --experiment E4_AllPoliciesCompetitive30(10x) --table E4_AllPoliciesCompetitive30(10x).csv --threads 1
echo 'Experiment 4 finished'

# E5
~/Downloads/NetLogo6.1.1/netlogo-headless.sh --model Model_Coupled_withoutplots_4152021.nlogo --experiment E5_AllPoliciesCompetitive40(10x) --table E5_AllPoliciesCompetitive40(10x).csv --threads 1
echo 'Experiment 5 finished'

# E6
~/Downloads/NetLogo6.1.1/netlogo-headless.sh --model Model_Coupled_withoutplots_4152021.nlogo --experiment E6_BaselineTimeSlotAllScenarios(10x) --table E6_BaselineTimeSlotAllScenarios(10x).csv --threads 1
echo 'Experiment 6 finished'

# SA
# this one is 180 000 runs!! think about this
~/Downloads/NetLogo6.1.1/netlogo-headless.sh --model Model_Coupled_withoutplots_4152021.nlogo --experiment SA_All --table SA_All.csv --threads 1
echo 'Experiment SA finished'
