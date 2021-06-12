# MScGraduationProject
Models and data analysis scripts used for my graduation project in MSc Engineering and Policy Analysis. This projects builds on the work done by Bogel in 2020 (see repository: MeykeNB/Covid-19-in-refugee-camps)

Goal: find a robust policy for food distribution in refugee settlements during a COVID-19 outbreak given the mix of behaviour of refugees when queuing  <br />
Process: Developed a queuing model, coupled the queuing model with the work done by Bogel, run experiments, analyze results  <br />


The material in this github page is divided into 5 folders. The name of each file is written as _[nameofthefile]_  <br />

**1. Model and running**  <br />
      1.1. Queuing Model _[Model_Queuing_4122021]_  <br />
      1.2  Coupled Model (Bogel's model with the queuing process integrated) _[CoupledModel_Final]_ <br />
      1.3  Running NetLogo headless for experiments _[new_experiments.sh]_ <br />

**2. Supportive Conceptualization** <br />
    2.1 Flowchart Queuing model - shows the logic behind the queuing model _[Flowchart_Queuing]_ <br />
    2.2 Flowchart Model Bogel - shows the logic behind the activities in Bogel's model _[Flowchart_ActivitiesBogel]_ <br />
    2.3 Flowchart Coupling process - shows the coupling process (at a very high level) _[Flowchart_Coupling]_ <br />
    
**3. Results (both .csv and text files; organized in folders to make it easier)** <br />
    3.1 Experiment 0 - Baseline across all scenarios <br />
    3.2 Experiment 1 - Scenario 0 with all representative-based policies <br />
    3.3 Experiment 2 - Scenario 1 with all representative-based policies <br />
    3.4 Experiment 3 - Scenario 2 with all representative-based policies <br />
    3.5 Experiment 4 - Scenario 3 with all representative-based policies <br />
    3.6 Experiment 5 - Scenario 4 with all representative-based policies <br />
    3.7 Experiment 6 - Timeslot-based policy with policy 1 across two scenarios <br />
    
    (not uploaded yet)
      
**4. Data preparation, analysis and visualization (Jupyter Notebooks)** <br />
    4.1 Notebook Baseline - Queuing dynamics  <br />
    4.2 Notebook Experiments - Infection dynamics <br />
    4.3 Notebook Representative-based policies <br />
    4.4 Notebook Timeslot-based policies <br />
      
**5. Sensitivity Analysis** <br />
    5.1 Model used for the Sensitivity Analysis (slight variation to include specific outputs) _[CoupledModel_SA]_ <br />
    5.2 Running NetLogo headless for senstivity analysis _[SA_headless.sh]_ <br />
    5.3 Pre-processing .csv from sensitivity analysis _[script3.py]_ <br />
    5.4 .csv file for Sensitivity Analysis  _[SA_cleanresults3.csv]_ <br />  
    5.5 Notebook Senstivity Analysis _[SensitivityAnalysis.ipynb]_ <br />



