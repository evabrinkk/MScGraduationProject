#!/bin/bash

# Script for the Sensitivity Analysis


# E99 Test Run to see if everything ok
~/Downloads/NetLogo6.1.1/netlogo-headless.sh --model CoupledModel_SA.nlogo --experiment ExSA --table results_SA.csv --threads 24
echo 'Sensitivity Analysis finished'


