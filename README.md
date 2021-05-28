# MScGraduationProject
Models and data analysis scripts used for my graduation project in MSc Engineering and Policy Analysis. This projects builds on the work done by Bogel in 2020 (see repository: MeykeNB/Covid-19-in-refugee-camps)

Goal: find a robust policy for food distribution in refugee settlements during a COVID-19 outbreak given the mix of behaviour of refugees when queuing 
Process: Developed a queuing model, coupled the queuing model with the work done by Bogel, run experiments, analyze results 

The material in this github page is divided into 5 parts:
1. Model (all in NetLogo)
      1.1 Queuing Model [Model_Queuing_4122021]
      1.2 Coupled Model (Bogel's model with the queuing process integrated) [CoupledModel_Final]
      1.3 Model used for the Sensitivity Analysis (slight variation to include specific outputs) [CoupledModel_SA]
      
2. Supportive Conceptualization
      2.1 Flowchart Queuing model - shows the logic behind the queuing model [Flowchart_Queuing]
      2.2 Flowchart Model Bogel - shows the logic behind the activities in Bogel's model [Flowchart_ActivitiesBogel]
      2.3 Flowchart Coupling process - shows the coupling process (at a very high level) [Flowchart_Coupling]

3. Running in a cluster
      3.1 Running NetLogo headless for experiments [new_experiments.sh]
      3.2 Running NetLogo headless for senstivity analysis [SA_headless.sh]
      3.3 Pre-processing .csv from sensitivity analysis [script3.py]
    
4. Results (both .csv and text files; organized in folders to make it easier)
      4.1 Experiment 0 - Baseline across all scenarios
      4.2 Experiment 1 - Scenario 0 with all representative-based policies
      4.3 Experiment 2 - Scenario 1 with all representative-based policies
      4.4 Experiment 3 - Scenario 2 with all representative-based policies
      4.5 Experiment 4 - Scenario 3 with all representative-based policies
      4.6 Experiment 5 - Scenario 4 with all representative-based policies
      4.7 Experiment 6 - Timeslot-based policy with policy 1 across two scenarios
      4.8 Sensitivity Analysis 
      
7. Data preparation, analysis and visualization (Jupyter Notebooks)
      7.1 Notebook Senstivity Analysis 
      7.2 Notebook Baseline 
      7.3 Notebook Experiments
      7.4 Notebook Experiment 6
      7.5 Notebook Hypothesis I
      7.6 Notebook Hypothesis II 


