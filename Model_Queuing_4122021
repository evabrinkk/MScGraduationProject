; This is the final version of the queuing model for my MSc Graduation (this was the version used for the coupling with Bogel's work)
; For full explanation of some of the procedures in this code, please see the thesis in the following link: xxx
; For assumptions, Ctrl + F: ASSUMPTIONS
; Eva Brink Carvalho, MSc Engineering and Policy Analysis

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; SUPPORTING VARIABLES AND PARAMETERS ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ; %% Set up the global variables for the model %%
  ; ===================================================== ;
globals [
  patchespertick              ; to control how much they can move every timetick (sort of speed)
  freeRefugees                ; this is an agentset of refugees that are not busy getting food
  firstInLine                 ; this is an agentset of the refugees that are the first in line (if there is only one food distro, it's only one)
  distanceFirstToFood         ; this is the distance from the first refugee in line to the food distribution point (adaptable depending on startingpointx and startingpointy)
  wall                        ; to create walls in some patches to represent spatial constraints (from with-obstacles? -- note: not used at the moment)
  supportive                  ; supportive variable for placements (can be -1 or 1)
  day                         ; to keep track of time
  hour                        ; to keep track of time
  minute                      ; to keep track of time
  middle_distribution_time    ; calculates the hour that is the middle of the distribution time (i.e. if distribution is open from 9 to 17 this is 13)
  num-refugees                ; nr of refugees attending food distribution (this is a % of the total number of inhabitants, depending on the policy)

  ; placement of the first element in the queue
  ;startingpointx     ; now it is in the interface
  ;startingpointy     ; now it is in the interface


  ; % variables to support the placement of competitive agents (spatially)
  ; logic behind this: three zones are created for competitive agents to stand in - frontal, medium and far. These are all created with the in-cone function and distance to the food distribution
  ; The placement of agents in each one of these zones depends on the position they have in the serving list
  ; frontal zone: from the agent with position frontal_position_min to the agent with medium_position_min, agents are placed in a in-cone xx xx that is xxx away from the food distribution
  ; medium zone: from the agent with position medium_position_min to the agent with medium_position_max, agents are placed in an in-cone xx xx that is xxx away from the food distribution
  ; far zone: all the agents placed from medium_position_max onwards

  ; frontal zone
  frontal_position_min    ; position in serving queue of the first agent to be in the frontal zone
;  frontal_position_max ; will be equal to medium_position_min
  ; medium zone
  medium_position_min     ; position in serving queue of the first agent to be in the medium zone (and consequently determining the last in the frontal one)
  medium_position_max     ; position in serving queue of the last agent to be in the medium zone (and consequently determining the first in the far one)
  ; far zone
; far_position_min ; will be equal to medium_position_max


  ; % some variables to keep track of the performance of the model
  total_served                             ; total number of refugees that have been served in the food distribution

  ; tracking time spent in the process of getting food
  timeSpentFood_average_output
  timeSpentFood_output_list
  timeSpentFood_output
  ; time but per attitude
  timeSpentFood_cooperative_output_list
  timeSpentFood_cooperative_output
  timeSpentFood_competitive_output_list
  timeSpentFood_competitive_output
  timeSpentFood_newcompetitive_output_list
  timeSpentFood_newcompetitive

  ; tracking the actual time in queue (which is the correct variable to use in order to evaluate the performance of the queue)
  trackingTimeInQueue_average_output
  trackingTimeInQueue_output_list
  ; tracking the actual time per attitude
  trackingTimeInQueue_cooperative_output_list
  trackingTimeInQueue_competitive_output_list
  trackingTimeInQueue_newcompetitive_output_list


  numberNewCompetitive_output          ; number of agents who turned into new competitive
  numberCompetitiveJoining_output      ; number of competitive agents who joined the queue
  averageQueueSize_serving_output      ; variable to keep track of the size of the serving queue
  averageQueueSize_physical_output     ; varuable to keep track of the size of the physical queue

]

  ; %% Different type of agents in the model %%
  ; These are refugees and fooddistro because of the context in which the model was used but can be changed into more general names with a Ctrl+F replace-all
  ; ===================================================== ;
breed [refugees refugee]               ; general alternative: person, citizen
breed [fooddistros fooddistro]         ; general alternative: service

  ; %% Attributes each agent type has %%
  ; ===================================================== ;
refugees-own
[
  ; % general attributes
  xc                           ; unwrapped xcor
  yc                           ; unwrapped ycor
  dist                         ; distance from initial patch using xc, yc
  destinationx                 ; X coordinates of their next destination
  destinationy                 ; Y coordinates of their next destination
  current-task                 ; task they are currently busy with
  ;walkable?                   ; attribute to guarantee people do not walk in the same patch as others (not fully implemented and not being used)
  preferred-fooddistro-time    ; time each agent prefers to go pick up their food (it is dependent on the distribution chosen in the interface but it stays the same once initialized) (ASSUMPTION: early morning people will be early morning people, late night people will always be... doomed)

  ; % attitude attributes
  natural-tendency             ; natural characteristic of a person that shows how competitive they are (is initialized once and stays the same the whole time) (ASSUMPTION: although they might change their behaviour when queuing and stimulated by different people, their personality doesn't change)
  tendency-to-competitiveness  ; variable that keeps track an agent's current tendency to become competitive
  tendency-after-queuing       ; value of their tendency to competitiveness after checking the length of the queue
  attitude                     ; attitude they have: cooperative, competitive or new-competitive

  list-influencing             ; list of agents that influence one to become more competitive (the competitive people who are waiting to be served and are at an in-cone distance xx from the agent - i.e. the queue jumpers around)
  currently-influencing        ; list of the influent people (see explanation above) around a refugee at a given time


  ; % placement or queue attributes
  number-in-physical-queue     ; their position in the physical queue
  number-in-serving-queue      ; their position in the serving queue
  before-me-queue              ; only for cooperative: the turtle that is before them in the physical queue
  before-me-x                  ; only for cooperative: the X coordinates of the person before them in the (physical) queue
  before-me-y                  ; only for cooperative: the Y coordinates of the person before them in the (physical) queue
  how-close-x                  ; only for competitive: says how close they managed to put themselves in the serving list
  how-close-y                  ; only for competitive: variable only to help placing agent in the y axes
  time-spent-food              ; how much time they already spent with the process of getting food
  time-remaining-service       ; time left to be served when in the first place of the line
  up-or-down                   ; only for new-competitive: to help placement of these agents in the queue
  tracking-time-in-queue       ; how much time agent has been in the queue (it's the fixed version)
  start-tracking-time          ; boolean to check if they have already started tracking the time
  first-destination            ; only for competitive: the first destination they join in the queue
  first-jump                   ; only for competitive: boolean to help me keep track if agent hasn't cut the line yet (ASSUMPTION: they only cut the line once)

  ; % temporary variables only to check if things are working (can be deleted later but don't forget to change eventual set variable to let variable)
  jumping-position
  desirable-area
  placing-new-competitive
  impact-on-me
  first-person-frontofme
]

fooddistros-own [        ; food distribution points have logistical attributes but they also manage the waiting-lists

  ; % logistical attributes
  service-time           ; time it takes to serve an agent
  opening-time           ; self explanatory
  closing-time           ; self explanatory (calculated as opening-time + hours-open (to be chosen in the interface))

  ; % waiting-list management
  physical-waiting-list  ; this is the list used to place agents in a queue (so only includes cooperative people)
  serving-waiting-list   ; this is the list used to serve agents (similar to the physical-waiting-list but includes the competitive people who occupy places in between)

  ;walkable?             ; attribute to guarantee people do not stand on patches that are occupied by something else (not finished and not being used)

]

patches-own [
  walkable?              ; attribute to make it possible to include spatial constraints (not being used)
  queuing-zone           ; can be frontal, medium or far (to place competitive people)
  start-queue            ; identifies the patch where the queue for the food distribution starts
]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; INTERFACE FUNCTIONS ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ; %% SETUP: Function to set up each new run %%
  ; calls on: setup-refugees, setup-foodpoint
  ; ===================================================== ;
to setup
  clear-all                  ; clear the interface and everything related to the previous run

  ; % Implementation of policies (very MSc thesis related: potentially not interesting for future use)
  ; the number of refugees being created in the simulation is dependent on the policy in place.
  ; This is because these agents are only created to pick up food so if policies using representatives are in place, it is only needed to create the agents that are representatives.
  if policy-implemented = "policy 0 (baseline)" [set num-refugees int(0.2 * total-number-inhabitants) ]    ; baseline: 20% of the population attends food distribution (head of households)
  if policy-implemented = "policy 1" [set num-refugees int(0.02 * total-number-inhabitants)]               ; policy 1: 2% of the population attends it (representatives of large groups)
  if policy-implemented = "policy 2" [set num-refugees int(0.04 * total-number-inhabitants)]               ; policy 2: 4% of the population attends it (representatives of medium groups)
  if policy-implemented = "policy 3" [set num-refugees int(0.07 * total-number-inhabitants)]               ; policy 3: 7% of the population attends it (representatives of small groups)
  if policy-implemented = "policy 4" [set num-refugees total-number-inhabitants]                           ; policy 4: 100% of the population attends it (every indiviudal picks their own food)


  setup-foodpoint            ; set up the food distribution points

  ; % supportive for the distribution: calculating the middle of the distribution schedule (i.e. if distribution is open from 9 to 17 this is 13)
  set middle_distribution_time ([opening-time] of one-of fooddistros + ([closing-time] of one-of fooddistros - 1)) * 0.5

  setup-refugees             ; set up the refugees


  set patchespertick 0.2
  set distanceFirstToFood sqrt(startingpointx ^ 2 + startingpointy ^ 2) ; pitagoras theorem, calculating distance from the point where the queue starts (place of the first in line) to food distribution
  set supportive [-1 1]



  ; % setting up time to initial values
  set day 0
  set hour 0
  set minute 0

  if with-obstacles? [setup-obstacles] ; setting up spatial constraints (not fully implemented and not being used)


  ; % set up the outputs as empty lists
  set timeSpentFood_cooperative_output_list []
  set timeSpentFood_competitive_output_list []
  set timeSpentFood_newcompetitive_output_list []
  set timeSpentFood_output_list []
  set timeSpentFood_newcompetitive 0
  set numberNewCompetitive_output 0
  set averageQueueSize_serving_output 0
  set averageQueueSize_physical_output 0
  set numberCompetitiveJoining_output 0
  set total_served 0
  set timeSpentFood_average_output 0
  set trackingTimeInQueue_average_output 0
  set trackingTimeInQueue_output_list []
  set trackingTimeInQueue_cooperative_output_list []
  set trackingTimeInQueue_competitive_output_list []
  set trackingTimeInQueue_newcompetitive_output_list []

  ; % set up variables to support the placement of competitive agents (spatially)
  ; this means that from 1 to 3 they are place in the frontal zone, from 3 to 40 in the medium and from 40 on they are in the far zone
  set frontal_position_min 1
  set medium_position_min 3
  set medium_position_max 40

  ; % identifies the patch where the queue for the food distribution starts and sets the "start-queue" attribute to yes
  ask patches with [(pxcor = [xcor] of one-of fooddistros - startingpointx ) and (pycor = [ycor] of one-of fooddistros - startingpointy)]
    [ set pcolor grey
      set start-queue "yes"]

  reset-ticks

end


  ; %% GO: This is the main function that is constantly being repeated (every time-tick) %%
  ; calls on: move-around, refugee-served, influencing-people
  ; ===================================================== ;
to go
  ; % stop condition (food distribution has finished by this point)
  if ticks = 4000 [stop]

  ; % update agentsets
  set freeRefugees refugees with [current-task != one-of fooddistros]                                 ; update the agentset freeRefugees with the Refugees that are not getting food each time tick
  set firstInLine refugees with [current-task = one-of fooddistros and number-in-serving-queue = 0]   ; update the agentset firstInLine with the Refugees that occupy position 0 in each one of the food distributions serving lists

  ; % update positions
  move-around                                                                                         ; call function to guarantee everyone moves to where they should

  ; % to make sure to update queues - ask the first in line to start the countdown to finish picking up their food and, once done, call refugee-served
  ask firstInLine [
    if (abs(xcor - destinationx) <= patchespertick and abs(ycor - destinationy) <= patchespertick) [set time-remaining-service time-remaining-service - 1] ; if the first in line is in the position there it should be, start countdown
    if time-remaining-service = 0 [refugee-served]                                                                                                         ; once it has been served, call refugee-served
    ]


  ; % to make sure every agent busy with food distribution tracks the time they have been in a queue for
  ask refugees with [tracking-time-in-queue != 0 and start-tracking-time = 1 and current-task = one-of fooddistros][set tracking-time-in-queue tracking-time-in-queue + 1]


  ; % to make sure (cooperative) agents take into account their surroundings and who is cutting the line around them
  influencing-people


  ; % making time pass in day, hour & minute format
  set minute minute + 1
  if minute = 60 [set hour (hour + 1) set minute 0]
  if hour = 24 [set day (day + 1) set hour 0]


  ; % to make people go get food according to their preffered time (and not the food-time function in the interface)
  ask refugees with [preferred-fooddistro-time = ticks] [set current-task (one-of fooddistros) set color orange]

  ; % every time tick check how big queue is?
  set averageQueueSize_serving_output length [serving-waiting-list] of one-of fooddistros
  set averageQueueSize_physical_output length [physical-waiting-list] of one-of fooddistros


tick  ; make sure time passes

end

  ; %% FOOD-TIME: once called, it gives the x% of the free refugees the task to get food  (NOT USED, was built initially before implementing the preferred distro time) %%
  ; ===================================================== ;
to food-time
  ask n-of (int (0.4 * count freeRefugees)) freeRefugees [        ; x is now set to 40%
    set current-task (one-of fooddistros)                         ; give them the task
    set color orange]                                             ; set color to yellow so it is easier to debug
  ; if the number of free refugees is less or equal to 2, ask one of (this is to guarantee that it is possible to ask all of them due to rounding numbers)
  if count freeRefugees <= 2 and count freeRefugees > 0  [ask one-of freeRefugees [set current-task (one-of fooddistros) set color yellow]]
end

  ; %% DEFAULT-VALUES: sets all the values in the interface back to their default %%
  ; ===================================================== ;
to default-values
  set percentage-competitive 20           ; percentage of the population that starts up as competitive
  set threshold-competitive 50            ; tendency to competitiveness threshold to turn competitive
  set radius-visibility 4                 ; the visibility of agents (used to influence some agents when they see people cutting the line around them)
  set impact-seeing-cutting 5             ; impact of seeing a person cutting the line (adds up to tendency-to-competitiveness)
  set impact-long-queues 5                ; impact of long queues (adds up to tendency-to-competitiveness)
  set acceptable-length 15                ; maximum length of queue that people still accept (from this length on, people add the "impact-long-queues" value to their competititveness)

  set startingpointx 4                    ; defining the beginning of the queue (x coordinates)
  set startingpointy 2                    ; defining the beginning of the queue (y coordinates)

  set natural-distancing-x 0.8            ; natural distance people keep from each other without a COVID social distancing measure (x coordinates)
  set natural-distancing-y 0.8            ; "" (y coordinates)

  set width-queuing-area 3                ; to decide how far from the queue new competitive can go
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; ADDITIONAL FUNCTIONS THAT ARE CALLED  ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; SETUP FUNCTIONS ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;

  ; %% SETUP-REFUGEES: self-explanatory %%
  ; ===================================================== ;
to setup-refugees
  create-refugees num-refugees
    [ setxy random-xcor random-ycor
      set color blue
      set shape "person"
      set size 1.7
      set current-task -42                     ; set up a random number so that it doesn't initialize with 0
      set number-in-physical-queue -42         ; ""
      set number-in-serving-queue -42          ; ""
      set time-remaining-service -42           ; ""
      set tendency-to-competitiveness -42      ; ""
      set before-me-queue -42                  ; ""
      set before-me-x -42                      ; ""
      set before-me-y -42                      ; ""
      set xc xcor
      set yc ycor
      set walkable? "no"                       ; this is to avoid colisions between agents (NOT USED)
      set list-influencing []                  ; initializing the lists for people to be influenced by others
      set currently-influencing []             ; ""
      set tracking-time-in-queue 0
      set start-tracking-time 0


    ; % Giving people different times to pick up food depending on the input from the interface (distribution-pick-up: normal or poisson; if poisson, choose the poisson-mean)

    ; some notes: - this is the time they leave their house and not the time they get to the food point (so it can happen that place opens at 9am and no one is there yet)
    ;             - it can also happen that people get a late preferred time so they can still be in the line when the service point is theoretically closed already ; ASSUMPTION: food distribution still serves the people that are in the line % ASSUMPTION: no food scarcity - everyone who lines up is served
    ;             - values have to be capped to never be less than the opening time nor more than the closing-time (or one hour before the closing time just in case)

      ; capping the values
      let min_value_time ([opening-time] of one-of fooddistros * 60 )         ; *60 to make sure it is in minutes
      let max_value_time (([closing-time] of one-of fooddistros - 1) * 60)    ; *60 to make sure it is in minutes ( - 1 to guarantee that people dont only leave their house at the time the food distribution closes)

    ; TIME-SLOT: if the time slot policy is in place: the preferred-fooddistro-up time follows a uniform distribution instead of a poisson/normal one
    ifelse time-slot? [set preferred-fooddistro-time int((random-float (hours-open - 1) + [opening-time] of one-of fooddistros) * 60)] [    ; *60 to make sure it is in minutes

      ; NORMAL:
      if distribution-pick-up = "normal" [
        let mean_value_time_normal int (random-normal middle_distribution_time 2 * 60)                                  ; *60 to make sure it is in minutes, std deviation of 2 because this leads to the wanted outcome regarding distribution (done by trial and error)
        set preferred-fooddistro-time max ( list min( list mean_value_time_normal max_value_time) min_value_time )]     ; capping
        ;output-print preferred-fooddistro-time
        ;output-print preferred-fooddistro-time]

      ; POISSON: (limitation of this approach is that everyone goes in even number with a major gap. (60, 120, 180, so for a long time no one goes))
      if distribution-pick-up = "poisson" [
        let supportive_poisson (poisson-mean + [opening-time] of one-of fooddistros)
        let mean_value_time_poisson random-poisson supportive_poisson
        set preferred-fooddistro-time mean_value_time_poisson * 60                                                      ; *60 to make sure it is in minutes
        set preferred-fooddistro-time max ( list min( list preferred-fooddistro-time max_value_time) min_value_time )]] ; capping
        ;output-print preferred-fooddistro-time
        ;output-print preferred-fooddistro-time]

  ]

    ; % Giving people attitudes (and tendencies)
    ; COOPERATIVE: according to the input given by the user in the interface, ask a percentage of refugees (= 100% - %competitive) to set up their tendency-to-competitiveness as a value lower or equal than the threshold
    ask n-of (int (num-refugees * (100 - percentage-competitive) * 0.01)) refugees [
      set tendency-to-competitiveness random threshold-competitive + 1
      set natural-tendency tendency-to-competitiveness                           ; store the initial value they have
      set tendency-after-queuing tendency-to-competitiveness
      set color orange]                                                          ; help debugging

    ; COMPETITIVE: ask the ones that still have no value (which will equal the % competitive from the interface) to set up a tendency-to-competitiveness value between the threshold and 100
    ask refugees with [tendency-to-competitiveness = -42] [
      set tendency-to-competitiveness random (100 - threshold-competitive) + threshold-competitive
      set natural-tendency tendency-to-competitiveness                           ; store the initial value they have
      set tendency-after-queuing tendency-to-competitiveness
      set color cyan]

    determine-attitude                                                           ; this function will determine their attitude depending on the tendency values that they have
end

  ; %% SETUP-FOODPOINTS: self-explanatory %% ;
  ; ===================================================== ;
to setup-foodpoint
  create-fooddistros 1
  [ setxy 23 11
    set color pink
    set shape "truck"
    set size 4
    set walkable? "no"                           ; for the spatial constraints (not being used)
    set physical-waiting-list []                 ; initializing lists
    set serving-waiting-list []                  ; ""
    set opening-time 1                           ; hour at which the food distribution starts (set to 1 because the model only has this dynamic so it is useless to wait longer)
    set heading 250                              ; for the in-cone procedures later on
    set closing-time opening-time + hours-open   ; assumption: the number of hours a food point is open can be change but it will always open at the same time


    ; % Implementation of policies (very MSc thesis related: potentially not interesting for future use)
    ; depending on the policy implemented, the service-time will change
    ; service-time is the number of ticks (minutes) it takes for each person to get served at the food point
    if policy-implemented = "policy 0 (baseline)" [set service-time 4]     ; baseline: 20% of the population attends it (head of households)
    if policy-implemented = "policy 1" [set service-time 10]               ; policy 1: 2% of the population attends it (representatives of large groups)
    if policy-implemented = "policy 2" [set service-time 7]                ; policy 2: 4% of the population attends it (representatives of medium groups)
    if policy-implemented = "policy 3" [set service-time 6]                ; policy 3: 7% of the population attends it (representatives of small groups)
    if policy-implemented = "policy 4" [set service-time 1]                ; policy 4: everyone (100%) attends food distribution



    ; % Supportive placement of competitive people (complementary to what is done in the setup function - there we decided which agents are placed in each area, here we decide the spatial constraints)
    ; the frontal zone (for agents with place from to 1 to 3 - see setup)
    ask patches in-cone 5 60 with [distance one-of fooddistros > 3]
      [ set pcolor red
        set queuing-zone "queuing_frontal"]
    ; the medium positions
    ask patches in-cone 10 90 with [distance one-of fooddistros < 10 and distance one-of fooddistros > 4]
      [ set pcolor pink
        set queuing-zone "queuing_medium"]
    ; the far positions
    ask patches in-cone 20 90 with [distance one-of fooddistros < 20 and distance one-of fooddistros > 10 and pycor > 5 and pycor < 15]
      [ set pcolor yellow
        set queuing-zone "queuing_far"]


  ]
end

  ; %% DETERMINE-ATTITUDE: this function is called when setting up the refugees. It sets up refugee's attitude according to their initial tendency-to-competitiveness value AND the threshold to become competitive %%
  ; called by: setup-refugees
  ; ======================================================= ;
to determine-attitude
  ask refugees with [natural-tendency <= threshold-competitive] [           ; if their natural-tendency is equal or less than the threshold, they are cooperative
    set attitude "cooperative"]
  ask refugees with [natural-tendency > threshold-competitive] [            ; if their natural-tendency is more than the threshold, they are competitive
    set attitude "competitive"
    ;output-print who
  ] ;output-print "test" ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; GENERAL FUNCTIONS ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ; %% MOVE-AROUND: this function is called every time tick and is responsible for making refugees do what they are supposed to %%
  ; It is divided into (1) people who are getting food and (2) people who are just moving around ;
  ; called by: go
  ; calls on: go-get-food
  ; ===================================================== ;
to move-around


  ; % 1) ask refugees that need to get food (i.e. have it as current-task) to do so
  ask refugees with [current-task = one-of fooddistros][
    go-get-food ]

  ; % 2) make refugees without task to move around
  ask freeRefugees [
    rt random 360               ; face random direction
    forward 1                   ; advance one step
  ]

end


  ; GO-GET-FOOD: this is the function responsible to determine how agents that have the task of getting food behave depending on their attitude
  ; This is divided into two parts: joining the waiting lists and physical movements during queuing %%
  ; called by: move-around
  ; calls on: walking-forward, update-competitiveness-length, got-influenced, line-up-cooperative, line-competitive and line-new-competitive
  ; =================================================;
to go-get-food

  ; % 1) Joining the waiting lists

  ; % getting closer: first, set destination as the beginning of the queue and head there
  ; (to guarantee it only sends the right ones, we have 3 conditions in the IF statement: not member - means that they are just starting the process and haven't been added to a list yet; time-remaining != 0 - means that they weren't just served; attitude != new-competitive - because at the beginning of the queuing process no one can be new competitive yet (people are cooperative or competitive by nature))
  let starting-patch one-of patches with [start-queue = "yes"]       ; save location of the beginning of the queue
  if (not member? self [serving-waiting-list] of current-task) and (time-remaining-service != 0 ) and (attitude != "new-competitive") [set color yellow set destinationx ([pxcor] of starting-patch) set destinationy ([pycor] of starting-patch) facexy destinationx destinationy walking-forward]

    ; % FOR COOPERATIVE: when they are close-ish to the beginning of the queue (less than 2 patches), add themselves to both the physical and the serving-waiting list
    if (distance starting-patch) <= 2 and (not member? self [physical-waiting-list] of current-task) and (attitude = "cooperative") ; not member? to guarantee that it only happens once
        [ask current-task [set physical-waiting-list lput myself physical-waiting-list]                                             ; add self to physical-waiting-list
         ask current-task [set serving-waiting-list lput myself serving-waiting-list]                                               ; add self to serving-waiting-list
         set number-in-physical-queue ([position myself physical-waiting-list] of current-task)                                     ; update the variable number-in-physical-queue with their position
         set number-in-serving-queue ([position myself serving-waiting-list] of current-task)                                       ; update the variable number-in-serving-queue with their position to be served
         set color green                                                                                                            ; set color to green so it is easier to debug
         set time-remaining-service [service-time] of current-task                                                                  ; set the service time as the one from the food distribution they are queuing for
         if impact-length? [update-competitiveness-length]                                                                          ; update-competitiveness-length: update their tendency-to-competitiveness
         set time-spent-food 0                                                                                                      ; initialize this variable

  ]



    ; % FOR COMPETITIVE: when they are close-ish to the beginning of the queue (less than 2 patches), add themselves to the serving-waiting-list in a relatively frontal position (as they desire to get served quickly)
    if (distance starting-patch) <= 2 and (not member? self [serving-waiting-list] of current-task) and (attitude = "competitive")[      ; not member? to guarantee that it only happens once
      if [serving-waiting-list] of current-task = [] [ask current-task [set serving-waiting-list fput myself serving-waiting-list]]      ; if the list is empty when they get there, simply add themselves
      if [serving-waiting-list] of current-task != [] [                                                                                  ; if the list is not empty
        set desirable-area int((length [physical-waiting-list] of current-task * 0.8 ))                                                  ; considers the relatively frontal position to be somewhere in the 80% beginning of the (physical) queue
        set jumping-position int(desirable-area * (100 - tendency-to-competitiveness) * 0.01) + 1                                        ; position in which they will force themselves in the queue is inversely proportional to their tendency to competitiveness ASSUMPTION: the more competitive they are, the more frontal they will be ; ASSUMPTION: person serving will not allow someone to jump to first position (hence the +1)
        let jumpy-jumpy jumping-position
        ask current-task [set serving-waiting-list insert-item jumpy-jumpy serving-waiting-list myself]]                                 ; add self to serving-waiting-list in the position calculated before  ; ASSUMPTION: no one objects to people cutting in line ASSUMPTION: competitive people only cut the line once
      set number-in-serving-queue ([position myself serving-waiting-list] of current-task)                                               ; update the variable number-in-serving-queue with their position to be served
      set how-close-y (random-float natural-distancing-y + 0.5)                                                                          ; supportive variable to help placing agent when waiting
      set color cyan                                                                                                                     ; supportive for debug
      set time-remaining-service [service-time] of current-task                                                                          ; set the service time as the one from the food distribution they are queuing for
      set time-spent-food 0                                                                                                              ; initialize this variable
      set up-or-down one-of supportive                                                                                                   ; supportive variable to help placing agent when waiting (takes either value of 1 or -1)
      set numberCompetitiveJoining_output numberCompetitiveJoining_output + 1                                                            ; update KPI of competitive people joining


         ; % when a competitive person joins the queue, it is important to trigger two events: update the serving-list and update the tendency-to-competitiveness of people who saw that happening

         ; % a) update serving-list - everytime a competitive person jumps in, the serving waiting list changes so the attributes related to people's positions needs to be updated
         ; assumption: this is assuming that if a cooperative person is almost getting served and a competitive person jumps in, their service is nulified and they have to start from the beginning
         ; this assumption is not true anymore (13.1.2021 - because i added in the upper block that they cannot add themselves to position 1 of the queue)
         update-serving-queue
         ask refugees with [(current-task = one-of fooddistros) and (member? self [serving-waiting-list] of current-task)][
            ;set number-in-serving-queue ([position myself serving-waiting-list] of current-task)                            ; update the attribute with position of each individual in the serving-waiting-list
            set time-remaining-service [service-time] of current-task]                                                      ; so not necessary anymore because of the + 1 above but let's keep it jic



         ; % b) updating tendency-to-competitiveness - if there are people cutting the line within the agent's visibility, update their tendency to competitiveness
         ask refugees with [current-task = one-of fooddistros and member? self [physical-waiting-list] of current-task and attitude = "cooperative" and (abs(xcor - destinationx) <= patchespertick and abs(ycor - destinationy) <= patchespertick)]  ; ask the cooperative refugees who are both in the waiting list but also already in their correct place
           [ let cutting-queues-people refugees with [current-task = one-of fooddistros and member? self [serving-waiting-list] of current-task and attitude = "competitive"] in-cone radius-visibility 60                                            ; count the amount of people cutting the line around them
             if count cutting-queues-people > 0                                                                                                                                                                                                       ; if that is more than 0 (so if they can see someone cutting the line)
             [ ;set color yellow
               set list-influencing [self] of refugees with [current-task = one-of fooddistros and member? self [serving-waiting-list] of current-task and attitude = "competitive"] in-cone radius-visibility 60                                     ; add the person(s) cutting the line to the "list-influencing" attribute of the cooperative person seeing it
               set tendency-to-competitiveness min( list (tendency-after-queuing + (impact-seeing-cutting * length list-influencing)) 100)]                                                                                                           ; update the tendency-to-competitiveness to the tendency-after-queuing plus the length of the list of people influencing them times the impact of seeing one person cutting. note: necessary to cap tendency-to-competitiveness between 0 and 100 to make it comparable
               if tendency-to-competitiveness > threshold-competitive [got-influenced]]                                                                                                                                                               ; if the value is now higher than the threshold, call "got-influenced" where the attitude is determined

  ]





   ; 2) Physical movements during queuing


   ; % FOR COOPERATIVE
   if (member? self [physical-waiting-list] of current-task) and (attitude = "cooperative")     ; if they are already in the physical-waiting-list (so they have been through the initial procedure and are close to the beginning of the queue)
     [;set color red                                                                            ; to make it easier to debug
      set time-spent-food time-spent-food + 1                                                   ; track the time spent in the process of getting food
      line-up-cooperative]                                                                      ; call function to line-up in the cooperative way


   ; % FOR COMPETITIVE
   if (member? self [serving-waiting-list] of current-task) and (attitude = "competitive")      ; if they are already in the physical-waiting-list (so they have been through the initial procedure and are close to the beginning of the queue)
      [set color white                                                                          ; to make it easier to debug
       set time-spent-food time-spent-food + 1                                                  ; track the time spent in the process of getting food
       ;line-competitive-old                                                                    ; call function to "line-up" the competitive way
       line-competitive]                                                                        ; new version of this function

  ; % FOR NEW-COMPETITIVE
  if (member? self [serving-waiting-list] of current-task) and (attitude = "new-competitive")   ; tbh they are always already in the list, most important thing here is the check of the attitude
      [set time-spent-food time-spent-food + 1                                                  ; track the time spent in the process of getting food
       line-new-competitive]                                                                    ; call function to "line up" in the new competitive way


end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; TURNING COOPERATIVE INTO COMPETITIVE ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ; %% UPDATE-COMPETITIVENESS-LENGTH: function where cooperative agents adapt their tendency-to-competitiveness due to the length of the queue %%
  ; called by: go-get-food
  ; calls on: got-influenced
  ; ===================================================== ;
to update-competitiveness-length

  ; % checking legnth of queue
  let how-long length [physical-waiting-list] of current-task                                                      ; store the length of the physical waiting list of the task they are busy with in a temporary variable

  ; % calculate impact depending on length
  if how-long >= 0 and how-long < (acceptable-length * 0.33)  [set impact-on-me 0]                                                           ; if the queue length is between 0 and 1/3 of the aceptable length, no impact (reasonable length so people don't get mad about it)
  if how-long >= (acceptable-length * 0.33) and how-long < acceptable-length [set impact-on-me how-long * impact-long-queues * 0.05 ]        ; if the queue length is between 1/3 of the acceptable length and the acceptable length, the impact is equal to the length times the impact of long queues * 0.05 (to scale it down because of the queue size)
  if how-long >= acceptable-length [set impact-on-me impact-long-queues]                                                                     ; if the queue length is more than the acceptable length, add the full impact of long queues

  ; % update value
  set tendency-after-queuing (natural-tendency + impact-on-me)                                                                               ; update tendency-after-queuing as the natural-tendency they are born with plus the impact just calculated

  ; % check if went over threshold
  if tendency-after-queuing > threshold-competitive [got-influenced]                                                                         ; if the value is now higher than the threshold, update both attitude and behaviour (got-influenced)


end


  ; %% INFLUENCING-PEOPLE: this function guarantees that at each time tick, the tendency-to-competitiveness of agents in queues is updated according to the presence (or not) of others queue jumpers in line
  ; everytime a competitive person gets into the line, it directly affects the people around - this is coded in the function of adding competitive people to the queue.
  ; however, it could be that competitive people show up next to someone after they were both queueing (because either they move forward or because it is a new competitive)
  ; for that reason, in the go function there is a extra list that tracks the amount of people who have this behaviour and are in radius at a current time. it merges this with the other list and removes duplicates to guarantee each refugee can only influence once.
  ; this guarantees that the tendency to competitiveness takes into account all the influent people (queue jumpers around) that the agent has seen since it has been lining up %%
  ; note: it is not possible to influence someone who is in ahead in the queue (in-cone is used instead of in-radius)
  ; called by: go
  ; calls on: got-influenced
  ; ====================================================== ;
to influencing-people

  ask refugees with [current-task = one-of fooddistros and member? self [physical-waiting-list] of current-task and attitude = "cooperative" and (abs(xcor - destinationx) <= patchespertick and abs(ycor - destinationy) <= patchespertick) and [position myself serving-waiting-list] of current-task  != 0] ; ask cooperative agents who are in their spot in the line
    [ set currently-influencing [self] of refugees with [current-task = one-of fooddistros and member? self [serving-waiting-list] of current-task and (attitude = "competitive" or attitude = "new competitive")] in-cone radius-visibility 60                                                                ; add people cutting the line within their vision to the list ; ASSUMPTION: they only see in front of them
      set list-influencing sentence list-influencing currently-influencing                  ; merge with the list that was already created (list-influencing)
      set list-influencing remove-duplicates list-influencing                               ; remove duplicates (to guarantee each refugee can only be influenced once by each queue jumper)
      set tendency-to-competitiveness min( list (tendency-after-queuing + (impact-seeing-cutting * length list-influencing)) 100)  ; update the tendency to competitiveness to be equal to the tendency after queuing plus the nr of people jumping queues around * the influence that each has in a refugee (while capping it to a maximum of 100)
      if tendency-to-competitiveness > threshold-competitive [got-influenced]]              ; if the value is now higher than the threshold, update both attitude and behaviour (got-influenced)

end


  ; %% GOT-INFLUENCED: once an agent has a tendency-to-competitiveness equal or higher than the threshold, it adopts a competitive behaviour. This function adjust their attitude and their behaviour %%
  ; called by: update-competitiveness-length and influencing-people
  ; calls on: update-physical-queue and update-serving-queue
  ; ===================================================== ;
to got-influenced
  set color grey                                                    ; to debug
  set attitude "new-competitive"                                    ; behaviour is "new-competitive" so it is easy to distinguish the naturally competitive people and the ones that were influenced and changed attitude
  set numberNewCompetitive_output numberNewCompetitive_output + 1   ; update KPI to know how people people turned new competitive in total

  ; % remove them from lists
  ask current-task [set physical-waiting-list remove myself physical-waiting-list]  ; remove themselves from the physical waiting list (as they are not cooperative anymore)
  set number-in-physical-queue -33                                                  ; set to a random value (easier to debug)
  set before-me-queue -33                                                           ; ""
  set before-me-x -33                                                               ; ""
  set before-me-y -33                                                               ; ""

  update-physical-queue      ; there was a change in the physical waiting list so its necessary to update it

  ask current-task [set serving-waiting-list remove myself serving-waiting-list]    ; remove themselves from serving waiting list (they will join again but in a better position)


  ; % add again to serving list (but in a better position!)
  if [serving-waiting-list] of current-task = [] [ask current-task [set serving-waiting-list fput myself serving-waiting-list]]      ; if the list is empty when they get there, simply add themselves
  if [serving-waiting-list] of current-task != [] [                                                                                  ; if the list is not empty
    set placing-new-competitive int( random-float(number-in-serving-queue - 1) * (100 - tendency-to-competitiveness) * 0.01) + 1     ; their placement in the serving list can only be better than the one they had (hence the random-float number-in-serving-queue), is related to their tendency to competitiveness (the higher the tendency, the more they will jump - hence the 100 - tendency) and cannot be to the first position
    let jumpy-new placing-new-competitive                                                                                            ; store value
    ask current-task [set serving-waiting-list insert-item jumpy-new serving-waiting-list myself ]]                                  ; rejoin the serving-list but in this new spot

  set time-remaining-service [service-time] of current-task                                                                          ; set the time remaining as the service time (not necessarily but doesn't hurt)


  ; % supportive variables for physical placement
  set how-close-y (random-float natural-distancing-y + 0.5)                                                                          ; supportive variable for where they are going to stand (used in line-new-competitive)
  set how-close-x random-float natural-distancing-x + 0.5                                                                            ; ""
  set up-or-down one-of supportive                                                                                                   ; ""


  update-serving-queue       ; there was a change in the serving list so it is necessary to update it


end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; LINING-UP FUNCTIONS ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ; %% LINE-UP-COOPERATIVE: this is the function that defines how cooperative people lineup. At a high level: once refugees are placed in physical-waiting-list, they get values of the person before them and always stay behind them (except for first in line) %%
  ; called by: go-get-food
  ; calls on: walking-forward
  ; ===================================================== ;
to line-up-cooperative

  ; % if they are first in line
  ask refugees with [(current-task = one-of fooddistros) and (member? self [physical-waiting-list] of current-task) and (attitude = "cooperative")][
    if number-in-physical-queue = 0 [                                                 ; if it is the first person in the waiting list
      set before-me-queue -30                                                         ; set to random value (first person in line does not have anyone in front)
      set before-me-x -30                                                             ; "
      set before-me-y -30                                                             ; "
    ]

    ; % if they are not the first in line
    if number-in-physical-queue != 0 [                                                ; if it's not the first person
      let before (number-in-physical-queue - 1)                                       ; create supportive variable so we are able to access physical-list
      set before-me-queue [item before physical-waiting-list ] of current-task        ; set before-me-queue as the person before agent in the physical-list
      set before-me-x [xcor] of before-me-queue                                       ; get coordinates of the person before (x)
      set before-me-y [ycor] of before-me-queue]                                      ; get coordinates of the person before (y)

    ; % Setting destination: if the agent is the first one on the list, set the destination as the initial point of the queue; if it is not, set the destination as the coordinates of the person before them in the queue (minus the social distancing in the x coordinates)
    ifelse (self = [item 0 physical-waiting-list] of current-task) [set destinationx ([xcor] of current-task) - startingpointx set destinationy ([ycor] of current-task) - startingpointy] [set destinationx (before-me-x - social-distancing) set destinationy before-me-y]

    ; % If they are not at their destination yet, walk forward. Once they are at their destination, start tracking time in queue
    ifelse (abs(xcor - destinationx) > patchespertick or abs(ycor - destinationy) > patchespertick)[facexy destinationx destinationy walking-forward][if start-tracking-time = 0 [set tracking-time-in-queue 1 set start-tracking-time 1]]] ; start-tracking-time is a supportive boolean variable to guarantee that this count only starts once and only counts after having initialized it

end


  ; %% LINE-COMPETITIVE: after having integrated the competitive people in the serving-waiting-list, this function places them physically - this physical position is dependent on their position in the list %%
  ; called by: go-get-food
  ; calls on: walking-forward
  ; ===================================================== ;
to line-competitive
; ASSUMPTION: competitive people do not follow social distancing

  ; % if they are the number one in the serving queue, they go to the starting point of the queue (this is the same for everyone, regardless of their attitude)
  if self = [item 0 serving-waiting-list] of current-task [

    set destinationx ([xcor] of current-task - startingpointx)  ; get coordinates of the start of the queue (x)
    set destinationy ([ycor] of current-task) - startingpointy  ; get coordinates of the start of the queue (y)

    ; If they are not at their destination yet, walk forward. Once they are at their destination, start tracking time in queue
    ifelse (abs(xcor - destinationx) > patchespertick or abs(ycor - destinationy) > patchespertick)[facexy destinationx destinationy walking-forward][if start-tracking-time = 0 [set tracking-time-in-queue 1 set start-tracking-time 1]]]

  ; % if they are not the first ones in the serving queue, place them in a physical location that mimics their number in serving queue
  if self != [item 0 serving-waiting-list] of current-task and first-jump = 0 [

    ; if their number in serving-waiting-list is between 1 and 3 (frontal_position_min & medium_position_min)
    if number-in-serving-queue > frontal_position_min and number-in-serving-queue <= medium_position_min [
      set color cyan                                                                 ; to debug
      set first-destination one-of patches with [queuing-zone = "queuing_frontal"]   ; set destination as one of the frontal patches
      set destinationx ([pxcor] of first-destination)                                ; get coordinates of this destination (x)
      set destinationy ([pycor] of first-destination)]                               ; "" (y)

    ; if their number in serving-waiting-list is between 3 and 40 (medium_position_min & medium_position_max, respectively)
    if number-in-serving-queue > medium_position_min and number-in-serving-queue <= medium_position_max [
      set color red                                                                  ; to debug
      set first-destination one-of patches with [queuing-zone = "queuing_medium"]    ; set destination as one of the medium patches
      set destinationx ([pxcor] of first-destination)                                ; get coordinates of this destination (x)
      set destinationy ([pycor] of first-destination)]                               ; get coordinates of this destination (y)

    ; if their number in serving-waiting-list is bigger than 40 (medium_position_max)
    if number-in-serving-queue > medium_position_max[
      set color orange                                                               ; to debug
      set first-destination one-of patches with [queuing-zone = "queuing_far"]       ; set destination as one of the far patches
      set destinationx ([pxcor] of first-destination)                                ; get coordinates of this destination (x)
      set destinationy ([pycor] of first-destination)]                               ; get coordinates of this destination (y)

    set first-jump 1                                                                 ; supportive variable to keep track if the agent has already been placed somewhere physically
   ]

  ; % if agent is not the first one in the list BUT has already been given a destination
  if self != [item 0 serving-waiting-list] of current-task and first-jump = 1 [
    ; % If they are not at their destination yet, walk forward. Once they are at their destination, start tracking time in queue
    ifelse (abs(xcor - destinationx) > patchespertick or abs(ycor - destinationy) > patchespertick)[facexy destinationx destinationy walking-forward][if start-tracking-time = 0 [set tracking-time-in-queue 1 set start-tracking-time 1]]]

end




  ; %% LINE-NEW-COMPETITIVE: function to place the new competitive (initially cooperative agents who changed attitude). The placement of these agents is connected to the placement of the person in front of them in the serving waiting list %%
  ; called by: go-get-food
  ; calls on: walking-forward
  ; ===================================================== ;
to line-new-competitive

  set color brown                                                                             ; for visual purposes and help debugging

  ; % Get necessary info for placements
  let before-new-competitive (number-in-serving-queue - 1)                                    ; temporary variable that stores the number of the person before in the serving queue
  if number-in-serving-queue = 0 [                                                            ; if it is the first person in the serving queue, there is no one in front
    set before-me-queue -30                                                                   ; set it to random value
    set before-me-x -30                                                                       ; ""
    set before-me-y -30                                                                       ; ""
  ]


  if number-in-serving-queue != 0 [                                                           ; if it is not the first person in the serving queue
    set before-me-queue [item before-new-competitive serving-waiting-list] of current-task    ; access list and store the agent that is in front in the serving list
    set before-me-x [xcor] of before-me-queue                                                 ; save coordinates of the person in front (x)
    set before-me-y [ycor] of before-me-queue]                                                ; "" (y)



  ; % Send them to places
  ; FURTHERDEVELOPMENT: this was done before introducing the frontal, medium, far zone for the competitive people. potentially this would be interesting here as well)

  ; for the first in line, send to the beginning of the queue
  if self = [item 0 serving-waiting-list] of current-task [                                   ; if it is the first person in the serving queue,
    set destinationx ([xcor] of current-task - startingpointx)                                ; set destination as the start of the queue (x)
    set destinationy ([ycor] of current-task - startingpointy)]                               ; "" (y)

  ; for the ones that are not the first in line
  if self != [item 0 serving-waiting-list] of current-task [                                  ; if it is not the first person in the serving queue
    set destinationx (before-me-x - how-close-x)                                              ; set the X destination as the place where the person before stands minus a supportive variable (can vary between 0.5 and 1.3 - see got-influenced)


    ; set the Y destination related to the place where the person before stands minus (or plus) a supportive value (but cap it!)
    let value before-me-y + (how-close-y * up-or-down)                                        ; save destination in a temporary variable (up or down can be 1 or -1 so it allows for a certain variation of the place where they stand)

    let max_value [ycor] of current-task + width-queuing-area                                 ; create upper limit based on an interface set "width-queuing-area"
    let min_value [ycor] of current-task - width-queuing-area                                 ; "" lower limit ""
    set destinationy max ( list min( list value max_value) min_value)]                        ; set destination y as the resultant value

  ; % If they are not at their destination yet, walk forward. Once they are at their destination, start tracking time in queue
  ifelse (abs(xcor - destinationx) > patchespertick or abs(ycor - destinationy) > patchespertick)[facexy destinationx destinationy walking-forward][if start-tracking-time = 0 [set tracking-time-in-queue 1 set start-tracking-time 1]]


end



;;;;; OTHER FUNCTIONS ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;



  ; %% REFUGEE-SERVED: once the first in the serving-line has been served (time-remaining-queue = 0), this function updates the waiting list of the food distribution centers by removing the agent from the first place.
  ; It is also necessary to set the served agent's attributes back to their original values (or a negative one that doesn't mess up the running and supports debugging)
  ; Note: different things happen if it is a cooperative (1), a competitive (2) or a new-competitive (3) agent being served %%
  ; called by: go
  ; calls on: update-physical-queue and update-serving queue
  ; ===================================================== ;
to refugee-served

  if [serving-waiting-list] of current-task != [] [                                                          ; to guarantee we only do this when the list isn't empty

    ; % Update time related KPIs
    set timeSpentFood_output_list lput time-spent-food timeSpentFood_output_list
    set trackingTimeInQueue_output_list lput tracking-time-in-queue trackingTimeInQueue_output_list
    set timeSpentFood_output time-spent-food
    set total_served total_served + 1
    set timeSpentFood_average_output ( sum timeSpentFood_output_list / total_served)
    set trackingTimeInQueue_average_output ( sum trackingTimeInQueue_output_list / total_served)


    ; % (1) if the agent served is COOPERATIVE it is necessary to update both lists (as the agent is member of both) and update attributes
    if attitude = "cooperative" and [physical-waiting-list] of current-task != [] [                          ; make sure that physical list is not empty otherwise it will give an error
      ask current-task [set physical-waiting-list remove myself physical-waiting-list]                       ; remove self from the physical waiting list (as self was just served)
      update-physical-queue                                                                                  ; update the physical waiting list so that everyone moves forward
      ask current-task [set serving-waiting-list remove myself serving-waiting-list]                         ; remove self from the serving waiting list (as self was just served)
      set timeSpentFood_cooperative_output_list lput time-spent-food timeSpentFood_cooperative_output_list   ; track time depending on their attitude
      set trackingTimeInQueue_cooperative_output_list lput tracking-time-in-queue trackingTimeInQueue_cooperative_output_list ; same but with the perfected tracked time
      update-serving-queue                                                                                   ; update the serving queue
      set current-task -50                              ; set the current-task of the refugee who was served to -50 so it goes back into wandering around again
      set number-in-physical-queue -50                  ; set attribute to after queuing value (helps debugging)
      set number-in-serving-queue -50                   ; ""
      set time-remaining-service -50                    ; ""
      set before-me-queue -50                           ; ""
      set before-me-x -50                               ; ""
      set before-me-y -50                               ; ""
      set time-spent-food -50                           ; ""
      set tracking-time-in-queue -50                    ; ""
      set tendency-to-competitiveness natural-tendency  ; go back to the initial value of competitiveness (otherwise the next food distribution everyone will come already super competitive)
      set list-influencing []                           ; empty list
      set currently-influencing []                      ; ""
      set start-tracking-time 0                         ; set the boolean back to 0
      set first-jump 0                                  ; ""
      set color pink                                    ; to help debugging


      ; reset attitude: update attitude to their natural one and related attributes ; ASSUMPTION: even though someone might be influenced into cutting in line, their natural attitude is not changed
      if natural-tendency <= threshold-competitive [set attitude "cooperative"]
      if natural-tendency > threshold-competitive [set attitude "competitive"]
      set tendency-to-competitiveness natural-tendency
      set tendency-after-queuing natural-tendency

    ]

    ; % (2) if the agent served is COMPETITIVE it is only necessary to update the serving list (as it was never part of the physical and the position of cooperative people won't change) and update attributes
    if attitude = "competitive" [
      ask current-task [set serving-waiting-list remove myself serving-waiting-list]                        ; remove self from the serving waiting list (as self was just served)
      set timeSpentFood_competitive_output_list lput time-spent-food timeSpentFood_competitive_output_list  ; track time depending on their attitude
      set trackingTimeInQueue_competitive_output_list lput tracking-time-in-queue trackingTimeInQueue_competitive_output_list ; same but with the perfected tracked time
      update-serving-queue                                                                                  ; update the serving queue
      set current-task -50                              ; set the current-task of the refugee who was served to -50 so it goes back into wandering around again
      set number-in-physical-queue -50                  ; set attribute to after queuing value (helps debugging)
      set number-in-serving-queue -50                   ; ""
      set time-remaining-service -50                    ; ""
      set before-me-queue -50                           ; ""
      set before-me-x -50                               ; ""
      set before-me-y -50                               ; ""
      set time-spent-food -50                           ; ""
      set tracking-time-in-queue -50                    ; ""
      set start-tracking-time 0                         ; set the boolean back to 0
      set first-jump 0                                  ; ""
      set color violet                                  ; to help debugging
    ]


    ;; (3) if the agent served is NEW COMPETITIVE, it is only necessary to update the serving list and update attributes
    if attitude = "new-competitive" [
      ask current-task [set serving-waiting-list remove myself serving-waiting-list]                               ; remove self from the serving waiting list (as self was just served)
      set timeSpentFood_newcompetitive_output_list lput time-spent-food timeSpentFood_newcompetitive_output_list   ; track time depending on their attitude
      set trackingTimeInQueue_newcompetitive_output_list lput tracking-time-in-queue trackingTimeInQueue_newcompetitive_output_list ; same but with the perfected tracked time
      update-serving-queue                                                                                         ; update the serving queue
      set current-task -22                              ; set the current-task of the refugee who was served to -22 so it goes back into wandering around again
      set number-in-physical-queue -22                  ; set attribute to after queuing value (helps debugging)
      set number-in-serving-queue -22                   ; ""
      set time-remaining-service -22                    ; ""
      set before-me-queue -22                           ; ""
      set before-me-x -22                               ; ""
      set before-me-y -22                               ; ""
      set time-spent-food -22                           ; ""
      set tracking-time-in-queue -22                    ; ""
      set tendency-to-competitiveness natural-tendency  ; go back to the initial value of competitiveness (otherwise the next food distribution everyone will come already super competitive)
      set list-influencing []                           ; empty list
      set currently-influencing []                      ; ""
      set start-tracking-time 0                         ; set the boolean back to 0
      set first-jump 0                                  ; ""
      set color turquoise                               ; to help debugging

      ; reset attitude: update attitude to their natural one and related attributes ; ASSUMPTION: even though someone might be influenced into cutting in line, their natural attitude is not changed
      if natural-tendency <= threshold-competitive [set attitude "cooperative"]
      if natural-tendency > threshold-competitive [set attitude "competitive"]
      set tendency-to-competitiveness natural-tendency
      set tendency-after-queuing natural-tendency

    ]

  ]

end


  ; %% UPDATE-PHYSICAL-QUEUE: everytime after having removed a member from the physical-waiting-list, it is necessary that each member in the queue updates their position both in the attributes and spatially
  ; Everyone's position is updated (i.e number 1 in queue becomes number 0, etc), everyone moves one step forward and the count starts again with the new number 0
  ; (this is basically the line-up-cooperative function with the only extra of reassigning the number-in-physical-queue) %%
  ; called by: got-influenced and refugee-served
  ; calls on: walking-forward
  ; ===================================================== ;
to update-physical-queue
  ask refugees with [(current-task = one-of fooddistros) and (member? self [physical-waiting-list] of current-task) and (attitude = "cooperative")][   ; ask everyone in the physical-waiting-list
    set number-in-physical-queue ([position myself physical-waiting-list] of current-task)                                                             ; update number-in-physical-queue attribute with their new position
    let beforenew (number-in-physical-queue - 1)                                                                                                       ; to access the person before them in the queue
    if number-in-physical-queue = 0 [                         ; if it is the first person in the waiting list
      set before-me-queue -30                                 ; set to random value (first person in line does not have anyone in front)
      set before-me-x -30                                     ; ""
      set before-me-y -30                                     ; ""
    ]


    if number-in-physical-queue != 0 [                                                    ; if it is not the first person
      set before-me-queue [item beforenew physical-waiting-list ] of current-task         ; set before-me-qeuue as the person that occupies the position in front in the physical-waiting-list
      set before-me-x [xcor] of before-me-queue                                           ; get coordinates of the person before (x)
      set before-me-y [ycor] of before-me-queue]                                          ; get coordinates of the person before (y)

    ; % Setting destination: if the agent is the first one on the list, set the destination as the initial point of the queue; if it is not, set the destination as the coordinates of the person before them in the queue (minus the social distancing in the x coordinates)
    ifelse (self = [item 0 physical-waiting-list] of current-task) [set destinationx ([xcor] of current-task) - startingpointx set destinationy ([ycor] of current-task) - startingpointy] [set destinationx (before-me-x - social-distancing) set destinationy before-me-y]

    ; % If they are not at their destination yet, walk forward
    if (abs(xcor - destinationx) > patchespertick or abs(ycor - destinationy) > patchespertick)[facexy destinationx destinationy walking-forward]
  ]
end

  ; %% UPDATE-SERVING-QUEUE: everytime after having removed or added a member to the serving-waiting-list, everyone in the serving line updates their "number-in-serving-queue" attribute. On top of this, competitive people also adjust their positions %%
  ; called by: go-get-food, got-influenced and refugee-served
  ; calls on: walking-forward
  ; ===================================================== ;
to update-serving-queue

  ; % update attributes
  ask refugees with [(current-task = one-of fooddistros) and (member? self [serving-waiting-list] of current-task)] [     ; ask all the members of the serving list
    set number-in-serving-queue ([position myself serving-waiting-list] of current-task)                                  ; update number-in-serving-queue attribute with their new position   ; ASSUMPTION: competitive (and new competitive) people only cut the line once
    set time-remaining-service [service-time] of current-task                                                             ; set the service time as the one from the food distribution they are queuing for

    ; % update positioning of competitive people (either because they are now in a better position or because other people have jumped in front of them and they are not in such a nice position anymore)

    ; if the agent is in the frontal area and should be backwards, update
    ; if it should be medium
    if [queuing-zone] of patch-here = "queuing_frontal" and number-in-serving-queue > medium_position_min and number-in-serving-queue <= medium_position_max [let second-destination one-of patches with [queuing-zone = "queuing_medium"] set destinationx ([pxcor] of second-destination) set destinationy ([pycor] of second-destination)]
    ; if it should be further
    if [queuing-zone] of patch-here = "queuing_frontal" and number-in-serving-queue > medium_position_max [let second-destination one-of patches with [queuing-zone = "queuing_far"] set destinationx ([pxcor] of second-destination) set destinationy ([pycor] of second-destination)]

    ; if the agent is in the medium and should be elsewhere, update
    ; if it should be frontal
    if [queuing-zone] of patch-here = "queuing_medium" and number-in-serving-queue > frontal_position_min and number-in-serving-queue <= medium_position_min [let second-destination one-of patches with [queuing-zone = "queuing_frontal"] set destinationx ([pxcor] of second-destination) set destinationy ([pycor] of second-destination)]
    ; if it should be further
    if [queuing-zone] of patch-here = "queuing_medium" and number-in-serving-queue > medium_position_max [let second-destination one-of patches with [queuing-zone = "queuing_far"] set destinationx ([pxcor] of second-destination) set destinationy ([pycor] of second-destination)]

    ; if the agent is in the further and should be elsewhere, update
    ; if it should be frontal
    if [queuing-zone] of patch-here = "queuing_far" and number-in-serving-queue > frontal_position_min and number-in-serving-queue <= medium_position_min [let second-destination one-of patches with [queuing-zone = "queuing_frontal"] set destinationx ([pxcor] of second-destination) set destinationy ([pycor] of second-destination)]
    ; if it should be further
    if [queuing-zone] of patch-here = "queuing_far" and number-in-serving-queue > medium_position_min and number-in-serving-queue <= medium_position_max [let second-destination one-of patches with [queuing-zone = "queuing_medium"] set destinationx ([pxcor] of second-destination) set destinationy ([pycor] of second-destination)]


    ; % If they are not at their destination yet, walk forward
    if (abs(xcor - destinationx) > patchespertick or abs(ycor - destinationy) > patchespertick)[facexy destinationx destinationy walking-forward]]

end


  ; %% WALKING-FORWARD: function responsible for walking. Logic is: if agent is not at their destination yet, continue walking forward %%
  ; called by: go-get-food, line-up-cooperative, line-competitive, line-new-competitive, update-physical-queue and update-serving-queue
  ; ===================================================== ;
to walking-forward
  let mydestiny patch destinationx destinationy        ; create temporary variable with the destination
  ifelse [walkable?] of mydestiny = "No" [set color yellow set destinationx destinationx - (patchespertick + 0.5) set destinationy destinationy - (patchespertick + 0.5)]  ; this is not being used
  [if (abs(xcor - destinationx) > patchespertick or abs(ycor - destinationy) > patchespertick)[facexy destinationx destinationy forward patchespertick]]
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; THINGS THAT COULD BE FIXED IN THE FUTURE:
; 1. when a competitive agent is being served, it stands on top of the cooperative person who occupies the first place in the physical line
; 2. time they get as preferred time to get food is the time they start heading there and not the time they arrive
; 3. the way cooperative and new competitive queue now is very dependent on the person in front - if there is something wrong with the person in front, error will spread ; BUG: this is happening


; TO HELP BEBUGGING (and also for verification)
; 1. Agents change colors after some procedures. This helps identifying at what stage the agent is
; 2. Similarly, some of the agent's parameters are changed to odd values (such as -22, -42, -50) after some functions

; TO MAKE IT USABLE IN OTHER SITUATIONS:
; right now they are refugees and food distro but this can be changed to more generic names


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;; POTENCIAL ADD-ONS ;;;;;;;;;;;;;;;;;;;;;;;,

; introducing obstacles in the middle of the camp and make sure refugees avoid them
to setup-obstacles

ask patches[
    set wall patches with
    [pxcor >= 3 and pxcor <= 5 and pycor  >=  8 and pycor <= 10 ]
  ]

  ask wall [
    set pcolor gray
    set walkable? "No"]

end


;;;;;;;; OLD CODE

  ; OUTDATED - using line-competitive now!
  ;; %% line-competitive-old: this function physically places the competitive agents somewhere along the first half of the line (assumption: this is the desirable area)
  ;; the physical position is dependent on the place where they got added in the list (see move-around) %%
  ;; called by: move-around
  ; ===================================================== ;
to line-competitive-old


  ; if they are the number one in the serving queue, they go to the point where people are serviced (this is the same for all agents)
  if self = [item 0 serving-waiting-list] of current-task [

    set destinationx ([xcor] of current-task - startingpointx)
    set destinationy ([ycor] of current-task) - startingpointy]


  ; if they are not the first ones in the serving queue, place them in a physical location that that mimics their number in serving queue
  if self != [item 0 serving-waiting-list] of current-task[
    set how-close-x ([position myself serving-waiting-list] of current-task)            ; the position in which they manage to force themselves in the serving waiting list will dictate where they wait


    set destinationx ([xcor] of current-task - (how-close-x + startingpointx - 6) ) * 0.5                      ; xcor: they wait along the line where others wait in a place that is similar to their position in the list (- startingpointx to account for the place where the first member waits)
    set destinationy ([ycor] of current-task - startingpointy) + (how-close-y * up-or-down)    ]         ; ycor: their position on the vertical axis can vary in between + 4 or -4 from the position of the others

  ; constant queueing: if they are not where they should be yet, forward
  if (abs(xcor - destinationx) > patchespertick or abs(ycor - destinationy) > patchespertick)[facexy destinationx destinationy walking-forward]

  ;;; try the solution kevin suggested
  ;;;; THIS IS NOT WORKING
;  if length [physical-waiting-list] of current-task <= 5 [

;    if self = [item 0 serving-waiting-list] of current-task [
;      set destinationx ([xcor] of current-task - startingpointx)
;      set destinationy ([ycor] of current-task) - startingpointy]

;    if self != [item 0 serving-waiting-list] of current-task [
;      set destinationx [xcor] of current-task
;      set destinationy [ycor] of current-task

;      facexy destinationx destinationy
;      if not any? other refugees in-cone social-distancing [fd patchespertick]]]



end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; fixed:
; 1; if i make the model run very slowly, i see that some competitive people jump constantly in values for destinationx and destinationy from 13 10 (food distro) and their own
;;;;;(because of of line 1.1. from go get food. However, if i do the not member? serving-waiting-list, the no one updates their behaviour anymore (dont know why)) -- how to fix this? I am doin gthis now with the time-remaining-queue != service-time

; 2. (people at the end of the qeuee turn into new competitive) -- this is because their inital is equal to the threshold, so they are adjusting their attitude. fixed
@#$#@#$#@
GRAPHICS-WINDOW
632
30
1450
449
-1
-1
10.0
1
10
1
1
1
0
1
1
1
-40
40
-20
20
0
0
1
ticks
30.0

BUTTON
112
84
175
117
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
182
84
245
117
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
254
82
339
115
NIL
food-time
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
17
178
155
223
social-distancing
social-distancing
0.5 1 1.5 2
2

SLIDER
166
177
347
210
percentage-competitive
percentage-competitive
0
100
20.0
1
1
NIL
HORIZONTAL

SLIDER
201
276
373
309
threshold-competitive
threshold-competitive
0
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
201
310
373
343
radius-visibility
radius-visibility
0
10
4.0
1
1
NIL
HORIZONTAL

SLIDER
201
345
373
378
impact-seeing-cutting
impact-seeing-cutting
0
50
5.0
1
1
NIL
HORIZONTAL

TEXTBOX
205
240
355
268
Determining attitudes and influence of queue jumpers
11
0.0
1

PLOT
1513
23
1796
250
Number of People Changing Behaviour
Time (ticks)
new-competitive
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count refugees with [attitude = \"new-competitive\"]"

TEXTBOX
20
242
170
284
Distance from queue to food distribution (placement of first in line)
11
0.0
1

SLIDER
17
291
189
324
startingpointx
startingpointx
0
6
4.0
0.2
1
NIL
HORIZONTAL

SLIDER
17
326
189
359
startingpointy
startingpointy
-3
4
2.0
0.2
1
NIL
HORIZONTAL

SLIDER
200
379
372
412
impact-long-queues
impact-long-queues
0
50
5.0
1
1
NIL
HORIZONTAL

SLIDER
199
414
371
447
acceptable-length
acceptable-length
0
100
15.0
1
1
NIL
HORIZONTAL

SWITCH
55
393
194
426
impact-length?
impact-length?
0
1
-1000

BUTTON
112
122
223
155
NIL
default-values
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
17
505
189
538
natural-distancing-x
natural-distancing-x
0
3
0.8
0.2
1
NIL
HORIZONTAL

SLIDER
16
539
188
572
natural-distancing-y
natural-distancing-y
0
3
0.8
0.2
1
NIL
HORIZONTAL

SLIDER
226
515
398
548
width-queuing-area
width-queuing-area
0
6
3.0
0.5
1
NIL
HORIZONTAL

SWITCH
54
446
195
479
with-obstacles?
with-obstacles?
1
1
-1000

MONITOR
347
119
404
164
NIL
day
17
1
11

MONITOR
409
120
466
165
NIL
hour
17
1
11

MONITOR
468
120
525
165
NIL
minute
17
1
11

CHOOSER
455
272
593
317
hours-open
hours-open
2 4 6 8
3

CHOOSER
451
453
589
498
distribution-pick-up
distribution-pick-up
"normal" "poisson"
1

PLOT
1512
255
1797
465
Time Spent Food vs TimeinQueue
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot timeSpentFood_average_output"
"pen-1" 1.0 0 -11033397 true "" "plot trackingTimeInQueue_average_output"

PLOT
1805
24
2055
246
Number of New competitive 
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot numberNewCompetitive_output"

PLOT
1805
256
2049
466
Number of new competitive joining
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot numberCompetitiveJoining_output"

PLOT
2059
25
2329
243
Size of the waiting lists
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -13791810 true "" "plot averageQueueSize_physical_output"
"pen-1" 1.0 0 -16050907 true "" "plot averageQueueSize_serving_output"

SLIDER
418
504
590
537
poisson-mean
poisson-mean
0.2
(hours-open * 0.5 ) + 1
3.0
0.2
1
NIL
HORIZONTAL

INPUTBOX
17
10
149
70
total-number-inhabitants
1200.0
1
0
Number

CHOOSER
152
24
300
69
policy-implemented
policy-implemented
"policy 0 (baseline)" "policy 1" "policy 2" "policy 3" "policy 4"
0

SWITCH
305
33
414
66
time-slot?
time-slot?
1
1
-1000

TEXTBOX
155
10
305
28
Representatitve-based policies
11
0.0
1

TEXTBOX
306
18
456
36
Time-slot-based policy
11
0.0
1

MONITOR
422
21
633
66
number of refugees attending distribution
num-refugees
17
1
11

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="no-competitive" repetitions="20" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>total_served</metric>
    <metric>timeInQueue_average_output</metric>
    <metric>timeInQueue_output_list</metric>
    <metric>timeInQueue_output</metric>
    <metric>timeInQueue_cooperative_output_list</metric>
    <metric>timeInQueue_cooperative_output</metric>
    <metric>timeInQueue_competitive_output_list</metric>
    <metric>timeInQueue_competitive_output</metric>
    <metric>timeInQueue_newcompetitive_output_list</metric>
    <metric>timeInQueue_newcompetitive</metric>
    <metric>numberNewCompetitive_output</metric>
    <metric>averageQueueSize_serving_output</metric>
    <metric>averageQueueSize_physical_output</metric>
    <metric>numberCompetitiveJoining_output</metric>
    <enumeratedValueSet variable="percentage-competitive">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-refugees">
      <value value="33"/>
      <value value="50"/>
      <value value="66"/>
      <value value="100"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="twenty-competitive" repetitions="20" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>total_served</metric>
    <metric>timeInQueue_average_output</metric>
    <metric>timeInQueue_output_list</metric>
    <metric>timeInQueue_output</metric>
    <metric>timeInQueue_cooperative_output_list</metric>
    <metric>timeInQueue_cooperative_output</metric>
    <metric>timeInQueue_competitive_output_list</metric>
    <metric>timeInQueue_competitive_output</metric>
    <metric>timeInQueue_newcompetitive_output_list</metric>
    <metric>timeInQueue_newcompetitive</metric>
    <metric>numberNewCompetitive_output</metric>
    <metric>averageQueueSize_serving_output</metric>
    <metric>averageQueueSize_physical_output</metric>
    <metric>numberCompetitiveJoining_output</metric>
    <enumeratedValueSet variable="percentage-competitive">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-refugees">
      <value value="33"/>
      <value value="50"/>
      <value value="66"/>
      <value value="100"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="fourty-competitive" repetitions="20" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>total_served</metric>
    <metric>timeInQueue_average_output</metric>
    <metric>timeInQueue_output_list</metric>
    <metric>timeInQueue_output</metric>
    <metric>timeInQueue_cooperative_output_list</metric>
    <metric>timeInQueue_cooperative_output</metric>
    <metric>timeInQueue_competitive_output_list</metric>
    <metric>timeInQueue_competitive_output</metric>
    <metric>timeInQueue_newcompetitive_output_list</metric>
    <metric>timeInQueue_newcompetitive</metric>
    <metric>numberNewCompetitive_output</metric>
    <metric>averageQueueSize_serving_output</metric>
    <metric>averageQueueSize_physical_output</metric>
    <metric>numberCompetitiveJoining_output</metric>
    <enumeratedValueSet variable="percentage-competitive">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-refugees">
      <value value="33"/>
      <value value="50"/>
      <value value="66"/>
      <value value="100"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="thirty-competitive" repetitions="20" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>total_served</metric>
    <metric>timeInQueue_average_output</metric>
    <metric>timeInQueue_output_list</metric>
    <metric>timeInQueue_output</metric>
    <metric>timeInQueue_cooperative_output_list</metric>
    <metric>timeInQueue_cooperative_output</metric>
    <metric>timeInQueue_competitive_output_list</metric>
    <metric>timeInQueue_competitive_output</metric>
    <metric>timeInQueue_newcompetitive_output_list</metric>
    <metric>timeInQueue_newcompetitive</metric>
    <metric>numberNewCompetitive_output</metric>
    <metric>averageQueueSize_serving_output</metric>
    <metric>averageQueueSize_physical_output</metric>
    <metric>numberCompetitiveJoining_output</metric>
    <enumeratedValueSet variable="percentage-competitive">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-refugees">
      <value value="33"/>
      <value value="50"/>
      <value value="66"/>
      <value value="100"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="no-competitive-fixedtime-1232021" repetitions="20" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>total_served</metric>
    <metric>timeSpentFood_average_output</metric>
    <metric>trackingTimeInQueue_average_output</metric>
    <metric>numberNewCompetitive_output</metric>
    <metric>averageQueueSize_serving_output</metric>
    <metric>averageQueueSize_physical_output</metric>
    <metric>numberCompetitiveJoining_output</metric>
    <enumeratedValueSet variable="percentage-competitive">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-refugees">
      <value value="33"/>
      <value value="50"/>
      <value value="66"/>
      <value value="100"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="twenty-competitive-fixedtime-1232021" repetitions="20" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>total_served</metric>
    <metric>timeSpentFood_average_output</metric>
    <metric>trackingTimeInQueue_average_output</metric>
    <metric>numberNewCompetitive_output</metric>
    <metric>averageQueueSize_serving_output</metric>
    <metric>averageQueueSize_physical_output</metric>
    <metric>numberCompetitiveJoining_output</metric>
    <enumeratedValueSet variable="percentage-competitive">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-refugees">
      <value value="33"/>
      <value value="50"/>
      <value value="66"/>
      <value value="100"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="ten-competitive-fixedtime-1232021" repetitions="20" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>total_served</metric>
    <metric>timeSpentFood_average_output</metric>
    <metric>trackingTimeInQueue_average_output</metric>
    <metric>numberNewCompetitive_output</metric>
    <metric>averageQueueSize_serving_output</metric>
    <metric>averageQueueSize_physical_output</metric>
    <metric>numberCompetitiveJoining_output</metric>
    <enumeratedValueSet variable="percentage-competitive">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-refugees">
      <value value="33"/>
      <value value="50"/>
      <value value="66"/>
      <value value="100"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="thirty-competitive-fixedtime-1232021" repetitions="20" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>total_served</metric>
    <metric>timeSpentFood_average_output</metric>
    <metric>trackingTimeInQueue_average_output</metric>
    <metric>numberNewCompetitive_output</metric>
    <metric>averageQueueSize_serving_output</metric>
    <metric>averageQueueSize_physical_output</metric>
    <metric>numberCompetitiveJoining_output</metric>
    <enumeratedValueSet variable="percentage-competitive">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-refugees">
      <value value="33"/>
      <value value="50"/>
      <value value="66"/>
      <value value="100"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="fourty-competitive-fixedtime-1232021" repetitions="20" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>total_served</metric>
    <metric>timeSpentFood_average_output</metric>
    <metric>trackingTimeInQueue_average_output</metric>
    <metric>numberNewCompetitive_output</metric>
    <metric>averageQueueSize_serving_output</metric>
    <metric>averageQueueSize_physical_output</metric>
    <metric>numberCompetitiveJoining_output</metric>
    <enumeratedValueSet variable="percentage-competitive">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-refugees">
      <value value="33"/>
      <value value="50"/>
      <value value="66"/>
      <value value="100"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="0.P0withS0S1S2S3S4" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>total_served</metric>
    <metric>timeSpentFood_average_output</metric>
    <metric>trackingTimeInQueue_average_output</metric>
    <metric>numberNewCompetitive_output</metric>
    <metric>averageQueueSize_serving_output</metric>
    <metric>averageQueueSize_physical_output</metric>
    <metric>numberCompetitiveJoining_output</metric>
    <enumeratedValueSet variable="percentage-competitive">
      <value value="0"/>
      <value value="10"/>
      <value value="20"/>
      <value value="30"/>
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-refugees">
      <value value="240"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-seed">
      <value value="40"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
