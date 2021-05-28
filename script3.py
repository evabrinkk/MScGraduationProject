import pandas as pd

# function to get the values of the intermediate outcomes (before the food distro and after the food distro)
def select_intermediate_outcome(df_per_run, kpi_string,at_tick):
    
    return df_per_run.loc[df_per_run.ticks == at_tick, kpi_string].iloc[0]


# function to get the outcomes at the end of the run 
def select_atendofrun_outcome(df_per_run, kpi_string):
    

    return df_per_run[kpi_string].iloc[0]


if __name__=='__main__':

	df = pd.read_csv("results_SA.csv", skiprows=6)


	
# rename the column names 
	df.columns = ['run', 'threshold-competitive', 'impact-long-queues', 'initial-corona-number', 'service-timeSA', 'policy-implemented', 
             'time-slot?', 'percentage-competitive', 'step', 'ticks', 'day', 'hour', 'minute', 'total-tents', 'cum-infected', 'average-timequeue',
             'min-timequeue', 'max-timequeue']

# sort by run and by time tick
	df = df.sort_values(by = ['run', 'ticks'], ascending=[True, True])


# list of the outcomes I want to evaluate
	list_of_kpis = ['cum-infected', 'average-timequeue', 'min-timequeue','max-timequeue' ]

# list of the inputs I used for the runs 
	list_of_inputs = ['threshold-competitive', 'impact-long-queues', 'initial-corona-number', 'service-timeSA', 'policy-implemented', 'time-slot?', 'percentage-competitive']

# the ticks of the moment before and after the food distribution
	list_of_intermediate_ticks = [10080,18720]

# the number of runs conducted in the whole SA 
	n_runs = df['run'].max() 




# initializing the dictionary to store all this data
	the_legendary_dictionary = {}


# setting up the dictionary keys as the inputs of the model , the outcomes and the intermediate ticks 
	for new_key in (list_of_inputs+list_of_kpis+list_of_intermediate_ticks):
    
    		the_legendary_dictionary[new_key] = list()

    
# For Loop to evaluate every run and get the values per run 
	for i in range(1,n_runs+1):
    		df_perrun = df[df['run'] == i]    # this reads per run 
    
    
    		df_lastvalues_perrun = df_perrun[df_perrun.ticks == df_perrun.ticks.max()] #make last value without .max()
    
    ### to get outcomes
    		for tick in list_of_intermediate_ticks:
        		the_legendary_dictionary[tick].append(select_intermediate_outcome( df_per_run=df_perrun,
                                                                          kpi_string=list_of_kpis[0],
                                                                          at_tick=tick ))
    		for kpi in list_of_kpis+list_of_inputs:
        
        		the_legendary_dictionary[kpi].append( select_atendofrun_outcome( df_per_run=df_lastvalues_perrun,
                                                                           kpi_string = kpi) )

# deleting the 240 and 480 columns and copying them to columns with better names
	for old_key in list_of_intermediate_ticks:
    
    		the_legendary_dictionary['cum-infected-%s'%old_key]=the_legendary_dictionary[old_key] 
    		del the_legendary_dictionary[old_key]
    
    
# saving to a easier to handle .csv that will have nbr rows = nbr runs 
	pd.DataFrame(the_legendary_dictionary).to_csv('SA_cleanresults3.csv')
	print('privet tovarish, spasiba for running')