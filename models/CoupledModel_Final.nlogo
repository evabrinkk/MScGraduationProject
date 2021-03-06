; This is the final version of the model for my MSc Graduation. Below you can find Bogel's model with further development in the queuing process (developed by me). These developments are marked with a ; QUEUING-MODEL before them and ;; at the end
; For full explanation of some of the procedures in this code, please see the thesis in the following link: xxx
; For assumptions, Ctrl + F: ASSUMPTIONS
; Eva Brink Carvalho, MSc Engineering and Policy Analysis

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


  ; %% Set up the global variables for the model %%
  ; ===================================================== ;
globals [
  Minute
  Hour
  Day
  day?
  facilities               ; agentset with all facilities
  roads                    ; used when walking is enabled
  speed                    ; patches / minute
  infection-distance       ; distance within which agents can infect each other
  cum-infected             ; total number of infections
  cum-symptomatic          ; total number of symptomatic agents
  cum-asymptomatic         ; total number of asymptomatic agents
  cum-severe               ; total number of severely sympatomatic agents
  cum-critical             ; total number of critically symptomatic agents
  cum-dead                 ; total number of fatalities
  cum-recovered            ; total number of recovered agents
  numpopulation            ; number of tents in the simulation
  patch-capacity           ; number of shelters a patch can hold in the simulation
  patch-length             ; dimensions of patches
  shelters                 ; list of the initial shelters, used to manage the households.
  ;infection-locations      ; holds information about the infections that occured (time, location, infector)
  show-colors?             ; option to color agents according to their infections
  householdsize            ; by default 5 (chooser contains text, this variable is only numerical)
  total_walker             ; supportive


  ; QUEUING-MODEL
  patchespertick            ; to control how much they can move every timetick (sort of speed)
  freetents                 ; this is an agentset of tents that are not busy getting food
  firstInLine               ; this is an agentset of the tents that are the first in line (if there is only one food distro, it's only one tent at each time)
  representatives           ; this is an agentset with the representatitives attending fooddistro (for policy implementation)
  distanceFirstToFood       ; this is the distance from the first refugee in line to the food distribution point (adaptable depending on startingpointx and startingpointy)
  wall                      ; to create walls in some patches to represent spatial constraints (from with-obstacles? -- note: not used at the moment)
  supportive                ; supportive variable for placements (can be -1 or 1)
  middle_distribution_time  ; calculates the hour that is the middle of the distribution time (i.e. if distribution is open from 9 to 17 this is 13)
  num-refugees              ; nr of refugees attending food distribution (this is a % of the total number of inhabitants, depending on the policy)


  ; QUEUING-MODEL (variables from the interface in the queuing model, the commented out ones were implemented in this interface as well)
  ;social-distancing
  startingpointx
  startingpointy
  ;impact-length?
  ;percentage-competitive
  ;threshold-competitive
  ;radius-visibility
  ;impact-seeing-cutting
  ;impact-long-queues
  ;acceptable-length

  natural-distancing-x
  natural-distancing-y

  width-queuing-area
  ;distribution-pick-up
  ;poisson-mean

  ;hours-open


  ; % variables to support the placement of competitive agents (spatially)
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
  total_cooperative_served                 ; "" of cooperative refugees ""
  total_competitive_served                 ; "" of competitive refugees ""
  total_newcompetitive_served              ; "" of newcompetitive refugees ""

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
  trackingTimeInQueue_cooperative_output
  trackingTimeInQueue_competitive_output_list
  trackingTimeInQueue_competitive_output
  trackingTimeInQueue_newcompetitive_output_list
  trackingTimeInQueue_newcompetitive_output


  numberNewCompetitive_output          ; number of agents who turned into new competitive
  numberCompetitiveJoining_output      ; number of competitive agents who joined the queue
  averageQueueSize_serving_output      ; variable to keep track of the size of the serving queue
  averageQueueSize_physical_output     ; varuable to keep track of the size of the physical queue
;;

  ;; post GL - infection things:
  infection-locations-coordinates            ; stores the GPS coordinates of the place where the infection happened
  attitude-infectee                          ; stores the attitude of the person being infected
  infection-locations-activity               ; stores where the person was when infected (from: shelter, fooddistribution, latrine, water or healthcare)
  attitude-infector                          ; stores the attitude of the person infecting
  infection-locations-activity-previous      ; stores where the person who infected me got infected (from: shelter, fooddistribution, latrine, water or healthcare)

  attitude-and-infections                    ; every hour it gives a list of the attitude of each agent and the number of people each has infected (if they are infected)
  infectious-competitive                     ; agentset of all the infected competitive at the moment
  nbr-infectious-competitive
  infections-provoked-competitive-total      ; total number of infections caused by competitive people
  infections-provoked-competitive-average    ; the number of infections one competitive person causes on average
  infectious-cooperative                     ; agentset of all the infected cooperative at the moment
  nbr-infectious-cooperative
  infections-provoked-cooperative-total      ; total number of infections caused by cooperative people
  infections-provoked-cooperative-average    ;number of infections one cooperative person causes on average

  total-infectious
  nbr-infectious


  ; post GL - queuing things:
  attitude-and-timeinqueue
  number_acting_competitive
  comb_maxmin_queuingtime_cooperative
  max_queuing_time_cooperative               ; the maximum time one agent spent queuing
  min_queuing_time_cooperative
  comb_maxmin_queuingtime_competitive
  max_queuing_time_competitive
  min_queuing_time_competitive
  comb_maxmin_queuingtime_newcompetitive
  max_queuing_time_newcompetitive
  min_queuing_time_newcompetitive

  max_queuingtime
  min_queuingtime


]

breed [tents tent]
breed [latrines latrine]

; QUEUING-MODEL
breed [fooddistros fooddistro]

breed [waterpoints waterpoint]
breed [foodpoints foodpoint]
breed [hc-facs hc-fac]
breed [COVID-facilities COVID-facility]

tents-own [ ;;; this is what a shelter has:
            myhome            ; patch of home
            latrine-time      ; time of the hour that latrine-usage is initiated
            water-time        ; hour of the day that obtaining water is initiated
            healthcare-time   ; hour of the day that visiting healthcare is initiated
            food-time         ; hour of the day that obtaining food is initiated
            walker?           ; whether an agent represents a refugee that is on the move
            household         ; consists initially of 5 or 7 members: child (<18) / adult (18-60) / elderly (60+)
            sick-household    ; all households members that are sick at home (also pre- and a-symptomatic)
      ;     food-supply       ;; For future use: let shelters keep track of how much food they have in stock, then impact of measures on access to food can be measured.

  ;;;; this is what walkers need.
          ;  myhome           ; (already defined above)
            my-age            ; child / adult / elderly
            compliant?        ; compliant to policy regulations? true / false
            infected?         ; true / false
            destination       ; myhome / facility / none
            occupancy         ; free / busy / in-hospital / in-queue
            infection         ; susceptible / infected / pre-symptomatic / asymptomatic / symptomatic / severely-symptomatic / critical / recovered
            infection-perception ; healthy / infectious / recovered
            time-until-next-stage  ; the number of days an agent is in a certain stage of COVID-19.
            next-stage        ; the next stage of COVID-19 (at setup, this is "infected")
            queue-time        ; time the agent has spent waiting in line for a facility
            ;destination-when-infected ; where the refugee was heading and what its queue-time was when getting infected

  ;; testing something for the infections (EVA 15.5.2021)
            nbr-people-i-infected
            who-is-infecting-me
            where-did-i-get-infected
            where-did-the-person-before-get-infected
            attitude-person-who-infected-me


  ; QUEUING-MODEL
           ; % general attributes
            xc                             ; unwrapped xcor
            yc                             ; unwrapped ycor
            dist                           ; distance from initial patch using xc, yc
            destinationx                   ; X coordinates of their next destination
            destinationy                   ; Y coordinates of their next destination
            current-task                   ; task they are currently busy with
            ;walkable?                     ; attribute to guarantee people do not walk in the same patch as others (not fully implemented and not being used)
            preferred-fooddistro-time      ; time each agent prefers to go pick up their food (it is dependent on the distribution chosen in the interface but it stays the same once initialized) (ASSUMPTION: early morning people will be early morning people, late night people will always be... doomed)
            preferred-fooddistro-time_sup  ; supportive variable to store the new time they get to go to food distro when no one is available at the preferred-fooddistro-time at first

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

            ; trying to track infections (EVA)
            x-when-infected
            y-when-infected

            ; % temporary variables only to check if things are working (can be deleted later but don't forget to change eventual set variable to let variable)
            jumping-position
            desirable-area
            placing-new-competitive
            impact-on-me
            first-person-frontofme
;;

]


latrines-own    [ waiting-list serving-time initial-serving-time ]
waterpoints-own [ waiting-list serving-time initial-serving-time ]
foodpoints-own  [ waiting-list serving-time initial-serving-time ]
hc-facs-own     [ waiting-list serving-time initial-serving-time ]
COVID-facilities-own [ bed-capacity IC-capacity       ; available (free) capacity in the COVID-19 facility
                      in-treatment in-IC              ; occupied capacity (number of patients) in the COVID-19 facility
                     ]
; QUEUING-MODEL
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
;;

; QUEUING-MODEL
patches-own [
  walkable?              ; attribute to make it possible to include spatial constraints (not being used)
  queuing-zone           ; can be frontal, medium or far (to place competitive people)
  start-queue            ; identifies the patch where the queue for the food distribution starts
]
;;

;;;;;; how to address all facilities:
;;;;;; foreach facilities [[the-turtle] -> ask the-turtle [print [who] of self] ]


to setup
  clear-all         ; clear the interface and everything related to the previous run
  reset-ticks

  ifelse poor-conditions? [create-facilities-poor][create-facilities-good]
  set show-colors? True
  ifelse household-size = 7 [set householdsize 7][set householdsize 5]  ; translates the chooser into a numerical variable

; QUEUING-MODEL
  ; % giving values to QUEUING-MODEL variables (that in the queuing model are in the interface)
  set startingpointx 4
  set startingpointy 2.0

  set natural-distancing-x 0.8
  set natural-distancing-y 0.8

  set width-queuing-area 3.0
;;

  ; QUEUING-MODEL
  setup-foodpoint            ; set up the food distribution points

  ; % supportive for the distribution: calculating the middle of the distribution schedule (i.e. if distribution is open from 9 to 17 this is 13)
  set middle_distribution_time ([opening-time] of one-of fooddistros + ([closing-time] of one-of fooddistros - 1)) * 0.5

  create-shelter-locations
  set numpopulation (count tents * householdsize)
  set day? False
  set shelters turtle-set [self] of tents

  ; % Implementation of policies (very MSc thesis related: potentially not interesting for future use)

  ; depending on the policy in place, num-refugees takes different values. then, an agent set with these is created
  if policy-implemented = "policy 0 (baseline)" [set num-refugees int(0.2 * numpopulation) ] ; baseline: 20% of the population attends it (head of households)
  if policy-implemented = "policy 1" [set num-refugees int(0.02 * numpopulation)]            ; policy 1: 2% of the population attends it (representatives of large groups)
  if policy-implemented = "policy 2" [set num-refugees int(0.04 * numpopulation)]            ; policy 2: 4% of the population attends it (representatives of medium groups)
  if policy-implemented = "policy 3" [set num-refugees int(0.07 * numpopulation)]            ; policy 3: 7% of the population attends it (representatives of small groups)
  ;if policy-implemented = "policy 4" [set num-refugees numpopulation]                       ; not implemented in this model because of the way Bogel implemented walkers to represent households

  ; creating agent set with the representatives
  set representatives n-of num-refugees tents

;;


  ; QUEUING-MODEL
  set patchespertick 0.2
  set distanceFirstToFood sqrt(startingpointx ^ 2 + startingpointy ^ 2)  ; pitagoras theorem, calculating distance from the point where the queue starts (place of the first in line) to food distribution
  set supportive [-1 1]
;;

  ; determine travel speed and queue space:
  if plotsize-shelters = "12,5 m2" [set patch-length 1.68 set patch-capacity 12 ]
  if plotsize-shelters = "25 m2"  [ set patch-length 2.38 set patch-capacity 20 ]
  if plotsize-shelters = "50 m2"  [ set patch-length 3.37 set patch-capacity 42 ]
  if plotsize-shelters = "100 m2" [ set patch-length 4.77 set patch-capacity 90 ]
  set infection-distance (1.5 / patch-length)
  set speed 83.33 / patch-length   ; 83.33 is a normal walking speed in meters per minute. Patch-length is in meters.




  ; QUEUING-MODEL
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
  set total_cooperative_served 0
  set total_competitive_served 0
  set total_newcompetitive_served 0
  set timeSpentFood_average_output 0
  set trackingTimeInQueue_average_output 0
  set trackingTimeInQueue_output_list []
  set trackingTimeInQueue_cooperative_output_list []
  set trackingTimeInQueue_cooperative_output 0
  set trackingTimeInQueue_competitive_output_list []
  set trackingTimeInQueue_competitive_output_list []
  set trackingTimeInQueue_newcompetitive_output_list []
  set trackingTimeInQueue_newcompetitive_output 0

  ;; testing how to track infections
  set attitude-and-infections []
  set attitude-and-timeinqueue []
  ;;

  set total_walker 0

  ; QUEUING-MODEL
  ; % set up variables to support the placement of competitive agents (spatially)
  ; this means that from 1 to 3 they are place in the frontal zone, from 3 to 40 in the medium and from 40 on they are in the far zone
  set frontal_position_min 1
  set medium_position_min 3
  set medium_position_max 40


  ; % identifies the patch where the queue for the food distribution starts and sets the "start-queue" attribute to yes
  ask patches with [(pxcor = [xcor] of one-of fooddistros - startingpointx ) and (pycor = [ycor] of one-of fooddistros - startingpointy)]
    [ set pcolor grey
      set start-queue "yes"]

;;

  ;; post GL stuff
  set max_queuing_time_cooperative 0
  set min_queuing_time_cooperative 1000     ; needs to be set to a high number otherwise it will always compare with 0 and return that
  set max_queuing_time_competitive 0
  set min_queuing_time_competitive 1000
  set max_queuing_time_newcompetitive 0
  set min_queuing_time_newcompetitive 1000

  set max_queuingtime 0
  set min_queuingtime 10000




end


to create-shelter-locations
  if block-size = "60 shelters" [setup4blocks]
  if block-size = "120 shelters" [setup2blocks]
  if block-size = "test-mode: few shelters" [create-a-few-tents]  ; is an option that can be used to run scenarios with only a few shelters for testing.

  ;; create the shelters and spread them across the environment
  ask tents [
    ;set color blue
    set shape "campsite"
    set size 1

    move-to one-of patches with [pcolor = black]
    while [ any? other tents-here] [move-to one-of patches with [pcolor = black]]
    set myhome patch-here
    set occupancy "free"
    set infection "susceptible"
    set infection-perception "healthy"
    set time-until-next-stage 0
    set next-stage "infected"
    set infected? False
    set destination "Home"
    set walker? false

   ;; define when activities will be initiated for this household
    set water-time (random 13) + 6       ; fetch water during day hours (between 6 and latest 18:00
    set healthcare-time (random 8) + 7   ; seek healthcare during opening-hours of facility (between 7:00 and latest 15:00
    ;set food-time (random 6) + 7         ; walk to food distribution in mornings between 7:00 and 13:00  ;; not used because of the QUEUING-MODEL
;    set food-supply random 28           ; food supply lasts 28 days.

    determine-households

    set queue-time 0


  ; QUEUING-MODEL
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
    set preferred-fooddistro-time "a"

    ;; testing something (EVA)
    set nbr-people-i-infected 0

    ; % Giving people different times to pick up food depending on the input from the interface (distribution-pick-up: normal or poisson; if poisson, choose the poisson-mean)

    ; some notes: - this is the time they leave their house and not the time they get to the food point (so it can happen that place opens at 9am and no one is there yet)
    ;             - it can also happen that people get a late preferred time so they can still be in the line when the service point is theoretically closed already ; ASSUMPTION: food distribution still serves the people that are in the line % ASSUMPTION: no food scarcity - everyone who lines up is served
    ;             - values have to be capped to never be less than the opening time nor more than the closing-time (or one hour before the closing time just in case)

    ; capping the values
    let min_value_time ([opening-time] of one-of fooddistros * 60 )         ; *60 to make sure it is in minutes
    let max_value_time (([closing-time] of one-of fooddistros - 1) * 60)    ; *60 to make sure it is in minutes ( - 1 to guarantee that people dont only leave their house at the time the food distribution closes)

    ; TIME-SLOT: if the time slot policy is in place: the preferred-fooddistro-up time follows a uniform distribution instead of a poisson/normal one
    ifelse time-slot? [set preferred-fooddistro-time int((random-float (hours-open - 1) + [opening-time] of one-of fooddistros) * 60) set preferred-fooddistro-time_sup preferred-fooddistro-time] [    ; *60 to make sure it is in minutes

      ; NORMAL:
      if distribution-pick-up = "normal" [
        let mean_value_time_normal int (random-normal middle_distribution_time 2 * 60)                                  ; *60 to make sure it is in minutes, std deviation of 2 because this leads to the wanted outcome regarding distribution (done by trial and error)
        set preferred-fooddistro-time max ( list min( list mean_value_time_normal max_value_time) min_value_time )      ; capping
        set preferred-fooddistro-time_sup preferred-fooddistro-time]                                                    ; save the value also in the supportive variable
        ;output-print preferred-fooddistro-time
        ;output-print preferred-fooddistro-time]

      ; POISSON: (limitation of this approach is that everyone goes in even number with a major gap. (60, 120, 180, so for a long time no one goes))
      if distribution-pick-up = "poisson" [
        let supportive_poisson (poisson-mean + [opening-time] of one-of fooddistros)
        let mean_value_time_poisson random-poisson supportive_poisson
        set preferred-fooddistro-time mean_value_time_poisson * 60                                                      ; *60 to make sure it is in minutes
        set preferred-fooddistro-time max ( list min( list preferred-fooddistro-time max_value_time) min_value_time )   ; capping
        set preferred-fooddistro-time_sup preferred-fooddistro-time]]                                                   ; save the value also in the supportive variable
        ;output-print preferred-fooddistro-time
        ;output-print preferred-fooddistro-time]

  ]


      ; % Giving people attitudes (and tendencies)
    ; COOPERATIVE: according to the input given by the user in the interface, ask a percentage of refugees (= 100% - %competitive) to set up their tendency-to-competitiveness as a value lower or equal than the threshold
    ask n-of (int (count tents * (100 - percentage-competitive) * 0.01)) tents [
      set tendency-to-competitiveness random threshold-competitive + 1
      set natural-tendency tendency-to-competitiveness                           ; store the initial value they have
      set tendency-after-queuing tendency-to-competitiveness
      set color orange]                                                          ; help debugging

    ; COMPETITIVE: ask the ones that still have no value (which will equal the % competitive from the interface) to set up a tendency-to-competitiveness value between the threshold and 100
    ask tents with [tendency-to-competitiveness = -42] [
      set tendency-to-competitiveness random (100 - threshold-competitive) + threshold-competitive
      set natural-tendency tendency-to-competitiveness                           ; store the initial value they have
      set tendency-after-queuing tendency-to-competitiveness
      set color cyan]

    determine-attitude                                                           ; this function will determine their attitude depending on the tendency values that they have



;;
end

to setup2blocks   ; slightly adjusted to guarantee there is enough room for the queues
  ask patches with [(pxcor >= max-pxcor ) or (pxcor <= min-pxcor + 1) or (pycor >= max-pycor - 0.20 * max-pycor) or (pycor <= min-pycor + 1) or (pxcor <= max-pxcor * 0.82)]
  [set pcolor white]

  let half (max-pycor * 0.375) ; adapted from pxcor to pycor
  ask patches with [(pxcor = floor half) or (pxcor = ceiling half) or (pycor = floor half) or (pycor = ceiling half) ][set pcolor white]

  ask patches with [(pxcor mod 2 = 1) and (pycor mod 2 = 1) and (pcolor = black)] [ sprout-tents 1]
  if (count tents - 240 > 0) [ask max-n-of 2 tents [who] [die]]

end

to setup4blocks   ; slightly adjusted to guarantee there is enough room for the queues
  ask patches with [(pxcor >= max-pxcor ) or (pxcor <= min-pxcor ) or (pycor >= max-pycor - 0.25 * max-pycor) or (pxcor <= max-pxcor * 0.82) ]
  [set pcolor white]

 ; let half (max-pxcor / 2)
  let quarter (max-pycor * 0.1875)
  ask patches with [(pycor mod (floor quarter) = 0) ][set pcolor white]

  ask patches with [(pxcor mod 2 = 1) and (pycor mod 2 = 0) and (pcolor = black)] [ sprout-tents 1 ;[set size 2 set shape "campsite"]
  ]
end

to create-a-few-tents   ; only used for testing (can be removed)
  ask patches with [(pxcor >= max-pxcor ) or (pxcor <= min-pxcor ) or (pycor >= max-pycor - 1) ] ; adapted for half camp
  [set pcolor white]

 ; let half (max-pxcor / 2)
  let quarter (max-pycor / 4)
  ask patches with [(pycor mod (floor quarter) = 0) ][set pcolor white]
  ask n-of 20 patches with [pcolor = black] [sprout-tents 1]

end

to determine-households
  let profile random 5 + 1
  if household-size = 7 [
  ifelse profile = 1 [
    set household shuffle (list "elderly" "adult" "adult" "adult" "child" "child" "child")] [
  ifelse profile = 2 [
    set household shuffle (list "elderly" "adult" "child" "child" "child" "child" "child")] [
  ifelse profile = 3 [
    set household shuffle (list "adult" "adult" "adult" "child" "child" "child" "child")] [
  ifelse profile = 4 [
    set household shuffle (list "elderly" "adult" "adult" "child" "child" "child" "child")] [
  ; if profile = 5
    set household shuffle (list "adult" "adult" "adult" "adult" "child" "child" "child")] ] ] ] ]

  if household-size = "5 - 10% elderly" [
    ifelse profile = 1 [
    set household shuffle (list "elderly" "adult" "adult" "child" "child")] [
  ifelse profile = 2 [
    set household shuffle (list "adult" "adult" "adult" "child" "child")] [
  ifelse profile = 3 [
    set household shuffle (list "elderly" "adult" "child" "child" "child")] [
  ifelse profile = 4 [
    set household shuffle (list "adult" "adult" "child" "child" "child")] [
  ; if profile = 5
    set household shuffle (list "adult" "adult" "child" "child" "child")] ] ] ] ]
  set sick-household []

  if household-size = "5 - 20% elderly" [
    ifelse profile = 1 [
    set household shuffle (list "elderly" "elderly" "adult" "child" "child")] [
  ifelse profile = 2 [
    set household shuffle (list "elderly" "adult" "child" "child" "child")] [
  ifelse profile = 3 [
    set household shuffle (list "elderly" "adult" "adult" "child" "child")] [
  ifelse profile = 4 [
    set household shuffle (list "elderly" "adult" "adult" "child" "child")] [
  ; if profile = 5
    set household shuffle (list "adult" "adult" "child" "child" "child")] ] ] ] ]
  set sick-household []
end

to create-facilities-good  ; depending on the chooser in the Model Interface, a large amount of facilities is created, or a very limited amount.
  ifelse householdsize = 5
  [ create-latrines 12 [
      set shape "toilet2"
      set size 1
      set color grey
      set heading 0
      set serving-time 2
      set initial-serving-time 2 ]
    create-waterpoints 48 [
      set shape "drop"
      set size 1
      set color cyan
      set heading 0
      set serving-time 15
      set initial-serving-time 15]
    create-hc-facs 1 [
      set shape "healthcare"
      set size 1
      set color white
      set heading 0
      set serving-time 2
      set initial-serving-time 2 ]]
  ; if household-size = 7 :
  [ create-latrines 16 [
      set shape "toilet2"
      set size 1
      set color grey
      set heading 0
      set serving-time 2
      set initial-serving-time 2 ]
    create-waterpoints 48 [ ; 76 [ ;76 is too many, they can't be placed!
      set shape "drop"
      set size 1
      set color cyan
      set heading 0
      set serving-time 15
      set initial-serving-time 15 ]
    create-hc-facs 2 [
      set shape "healthcare"
      set size 1
      set color white
      set heading 0
      set serving-time 10
      set initial-serving-time 10 ]]

  ; always create 1 food distribution point
    create-foodpoints 1 [
      set shape "truck"
      set size 2
      set color grey
      set heading 0
      set serving-time 2
      set initial-serving-time 2 ]

 ; locating facilities:
  ask turtles [
    let x random 2
    ifelse x = 1 [setxy min-pxcor random-ycor] [
        setxy random-xcor max-pycor ]
    while [any? other turtles in-radius 2] [set x random 2 ifelse x = 1 [setxy min-pxcor random-ycor] [setxy random-xcor max-pycor ]]
    set waiting-list [] ]
  ; to make latrines represent a block of 10 toilets:
  ask latrines [hatch 9 []]

  ; create agentset with all facilities in there:
  set facilities (turtle-set latrines waterpoints foodpoints hc-facs)
end

to create-facilities-poor  ; depending on the chooser in the Model Interface, a large amount of facilities is created, or a very limited amount.
  ifelse householdsize = 5
  [ create-latrines 5 [
      set shape "toilet2"
      set size 1
      set color grey
      set heading 0
      set serving-time 2
      set initial-serving-time 2 ]
    create-waterpoints 9 [
      set shape "drop"
      set size 1
      set color cyan
      set heading 0
      set serving-time 15
      set initial-serving-time 15]]
  ; if household-size = 7 :
  [ create-latrines 7 [
      set shape "toilet2"
      set size 1
      set color grey
      set heading 0
      set serving-time 2
      set initial-serving-time 2 ]
    create-waterpoints 9 [ ; 13 [  ; waterpoints number is not changing because the number of household remains equal.
      set shape "drop"
      set size 1
      set color cyan
      set heading 0
      set serving-time 15
      set initial-serving-time 15 ]]

  ; always create 1 HC facility and 1 food distribution point
    create-hc-facs 1 [
      set shape "healthcare"
      set size 1
      set color white
      set heading 0
      set serving-time 10
      set initial-serving-time 10 ]
    create-foodpoints 1 [
      set shape "truck"
      set size 2
      set color grey
      set heading 0
      set serving-time 2
      set initial-serving-time 2 ]
 ; locating facilities:
  ask turtles [
    let x random 2
    ifelse x = 1 [setxy min-pxcor random-ycor] [
        setxy random-xcor max-pycor ]
    while [any? other turtles in-radius 2] [set x random 2 ifelse x = 1 [setxy min-pxcor random-ycor] [setxy random-xcor max-pycor ]]
    set waiting-list [] ]
  ; to make latrines represent a block of 10 toilets:
  ask latrines [hatch 9 []]

  ; create agentset with all facilities in there:
  set facilities (turtle-set latrines waterpoints foodpoints hc-facs)
end

to create-COVID-facility    ;; separately creates a COVID-19 treatment facility of which the capacity can be defined below.
  create-COVID-facilities 1 [
    set shape "target"
    set size 2
    set heading 0
    setxy 25 24
    set bed-capacity 100
    set IC-capacity 8
 ;;; for not-severe consults: (not-used)
 ;   set consult-capacity 1
 ;   set initial-consult-time 10

    ;; If it needs to 'manage-queues', it must also be appended to the facilities agentset:
    ;; BUT: covid-facility currently doesn't have a waiting-list, so this is not implemented now.
  ]
end


to go ;;
  time-runs    ; time is running
  if Minute = 0 [ask tents with [infected? = true] [disease-progression]]

  ;; initiate food-collection
  if (Day mod 28) = food-delivery-day [ ; by default: day 1
    ;ask shelters [ if (Hour = food-time) and (Minute = 15) [go-get-food2]]]
    ; QUEUING-MODEL: if the time is equal to the preferred-fooddistro of the representatives, it's time to get food
    ask representatives [ if (Hour * 60 + Minute) = preferred-fooddistro-time_sup [go-get-food2]]]
  ;;

  if day?
   [ ;; initiate facility-usage
      if Minute = 0 [ if householdsize = 5 [ask shelters [set latrine-time (random 142 + 3) ;; determines when they will use the toilet in this hour.
        while [latrine-time = 15] [set latrine-time (random 142 + 3)] ]]  ;; if latrine-time is 15, it can cause friction with food-time.
                      if household-size = 7 [ask shelters [set latrine-time (random 98 + 3)
          while [latrine-time = 15] [set latrine-time (random 98 + 3) ]]]]
      ask shelters [ if Minute = latrine-time [go-to-latrines2]
                if (Hour = water-time) and (Minute = 1) [go-to-waterpoint2]
                if mobility != "isolation" [if (Hour = healthcare-time) and (Minute = 2) [let sick-chance random-float 1 if sick-chance < (0.388 / 7) [go-to-healthcare ] ]] ]
      ; also during isolation, people should go to normal healthcare if needed. (However, it is found that the chance of seeking healthcare is halved.
      if mobility = "isolation" [ask shelters [if (Hour = healthcare-time) and (Minute = 2) [let sick-chance random-float 1 if sick-chance < ((0.388 * 0.5) / 7) [go-to-healthcare ]]]]
                ;  Currently, healthcare-time is specified for normal healthcare usage. Not for COVID-19 care.
   new-walking

   manage-queues
      ;; at any moment of the day, people show their infection status by color:  (Can be ignored by setting show-colors? False
      ifelse mask-usage = "yes" [ show-infections-masks][show-infections]  ; when people wear masks, the chance of infection is lower, which is indicated with a darker green color than usual.
   infect
  ]


  ; QUEUING-MODEL
  ; % update agentsets
  set freetents tents with [current-task != one-of fooddistros]                                    ; update the agentset freeRefugees with the Refugees that are not getting food each time tick
  set firstInLine tents with [current-task = one-of fooddistros and number-in-serving-queue = 0]   ; update the agentset firstInLine with the Refugees that occupy position 0 in each one of the food distributions serving lists


  ; % to make sure to update queues - ask the first in line to start the countdown to finish picking up their food and, once done, call refugee-served
  ask firstInLine [
    if (abs(xcor - destinationx) <= patchespertick and abs(ycor - destinationy) <= patchespertick) [set time-remaining-service time-remaining-service - 1 ] ; if the first in line is in the position there it should be, start countdown
    if time-remaining-service = 0 [refugee-served]                                                                                                          ; once it has been served, call refugee-served
    ]

  ; % to make sure every agent busy with food distribution tracks the time they have been in a queue for
  ask tents with [tracking-time-in-queue != 0 and start-tracking-time = 1 and current-task = one-of fooddistros][set tracking-time-in-queue tracking-time-in-queue + 1]

  ; % to make sure (cooperative) agents take into account their surroundings and who is cutting the line around them
  influencing-people

  ; % to make people go get food according to their preffered time (and not the food-time function in the interface)
  ask tents with [preferred-fooddistro-time = ticks] [set current-task (one-of fooddistros) set color orange]

  ; % every time tick check how big queue is?
  set averageQueueSize_serving_output length [serving-waiting-list] of one-of fooddistros
  set averageQueueSize_physical_output length [physical-waiting-list] of one-of fooddistros

;; post GL stuff

  ifelse Hour = 22 and Minute = 22 [
    ask tents [
      if infected? [
        if nbr-people-i-infected != 0[
          let my-attitude-my-infections list attitude nbr-people-i-infected  set attitude-and-infections lput my-attitude-my-infections attitude-and-infections]]]]
  [set attitude-and-infections [] ]


  set number_acting_competitive count tents with [attitude = "competitive" or attitude = "new-competitive"]

  tick  ; make sure time passes

end



to time-runs ; makes the clock tick
  set Minute Minute + 1
  if Minute = 60 [set Minute 0 set Hour Hour + 1]
  if Hour = 6 [set day? true ]
  if (Hour = 23) and (Minute = 30) [set day? False]
  if Hour = 24 [set Hour 0 set Day (Day + 1)]
end


to-report a-walker
let counthousehold length household
if (mobility = "free") [
    ifelse (length household + length sick-household) = 0 [report 0]
    [ ifelse random (counthousehold + length sick-household) < counthousehold

      [report 1] [report 5] ]]

if mobility = "isolation" [
    ifelse any? tents with [(myhome = [myhome] of myself) and (infection = "symptomatic")]   ;; hier kan alleen 'true' op geantwoord worden als deze persoon niet-compliant is.
    ;; if there is a noncompliant person:
    [
      let noncompliant (count tents-here with [(compliant? = false) and (destination = "none")])
      ifelse noncompliant = 0 [report 0]  ;; if there is no noncompliant person at home, 0 is reported:
      ;; if the noncompliant person is at home, it depends on the destination (latrine/water) what the chance is that 6 is reported:
      [ifelse Minute = latrine-time [
        ifelse random-float 1 < (noncompliant / householdsize) [report 6] [report 0]]
        ;; if the command is go-to-waterpoint:
        [report 6]]]
    ;; if there is no symptomatic person, the same happens as if mobility = free
    [ifelse (length household + length sick-household) = 0 [report 0]
    [ ifelse random (counthousehold + length sick-household) < counthousehold
        [report 1] [report 5] ]]]

if mobility = "quarantined" [
    ifelse (counthousehold + (count tents-here with [((infection-perception = "healthy") or (compliant? = False)) and (destination = "none")])) = 0 [report 0]
    [ ifelse random (counthousehold + count tents-here with [((infection-perception = "healthy") or (compliant? = False)) and (destination = "none")]) < counthousehold
      [ report 1][report 4] ]]

if mobility = "no-elderly" [

   let e-household filter [ s -> s != "elderly" ] household
   let e-sick-household filter [ s -> s != "elderly" ] sick-household
   let e-counthousehold length e-household
    ifelse ((e-counthousehold + length e-sick-household) = 0) [report 0]
    [ ifelse random (e-counthousehold + length e-sick-household) < e-counthousehold
      [report 2] [report 3]
  ]]
end


to-report a-food-walker
  let c-household filter [ s -> s != "child" ] household   ; c-household is the household without children
  let c-sick-household filter [ s -> s != "child" ] sick-household  ; c-sick-household is the sick-household without children
  let c-counthousehold length c-household

if (mobility = "free")[ ;  [
    ifelse (c-counthousehold + length c-sick-household) = 0 [report 0]   ; if there is no-one at home: report 0
    [ ifelse random (c-counthousehold + length c-sick-household) < c-counthousehold  ; if a healthy person is chosen: report 1
      [report 1] [report 5] ]]                                                       ; if a sick person is chosen: report 5

if mobility = "isolation" [
    ifelse any? tents with [(myhome = [myhome] of myself) and (infection = "symptomatic")]   ;; can only return 'true' if this person is not compliant.
    ;; if there is a noncompliant person:
    [ let noncompliant (count tents-here with [(compliant? = false) and (my-age != "child")])
      ifelse noncompliant = 0 [report 0]  ;; if there is no noncompliant person at home, 0 is reported:
        [report 6]]
    ;; if there is no symptomatic person, the same happens as if mobility = free
    [ ifelse (c-counthousehold + length c-sick-household) = 0 [report 0]
      [ ifelse random (c-counthousehold + length c-sick-household) < c-counthousehold
        [report 1] [report 5] ]]]

if mobility = "quarantined" [
    ifelse (c-counthousehold + (count tents-here with [(my-age != "child") and ((infection-perception = "healthy") or (compliant? = False)) and (destination = "none")])) = 0 [report 0]
    [ ifelse random (c-counthousehold + count tents-here with [(my-age != "child") and ((infection-perception = "healthy") or (compliant? = False)) and (destination = "none")]) < c-counthousehold
      [ report 1][report 4] ]]

if mobility = "no-elderly" [
   let e-household filter [ s -> s != "elderly" ] c-household
   let e-sick-household filter [ s -> s != "elderly" ] c-sick-household
    ifelse ((length e-household + length e-sick-household) = 0) [report 0]
    [ ifelse random (length e-household + length e-sick-household) < length e-household
      [report 2] [ report 3]
  ]]
end


to go-get-food2
  let free-tents tents-here with [destination = "none"]
  let the-walker a-food-walker
  set total_walker total_walker + 1
  let c-household filter [ s -> s != "child" ] household
  let c-sick-household filter [ s -> s != "child" ] sick-household

  ifelse the-walker != 0
   [ ifelse the-walker = 1 [      ;; a random healthy person
      let person item (random (length c-household)) c-household   ;; gives 'adult' or 'elderly'
      let new-walker position person household
      hatch 1 [
        set walker? true set shape "person"
        set color brown
        set my-age item new-walker household
        set occupancy "busy"
        ; QUEUING-MODEL
        set destination (one-of fooddistros)
        set current-task (one-of fooddistros)
        set destinationx ([xcor] of destination)
        set destinationy ([ycor] of destination)
        ;;
        ifelse random 100 < compliance [set compliant? true ][set compliant? false] ]
      set household remove-item new-walker household ]
   [ ifelse the-walker = 2 [  ;; a non-elderly from the healthy people
      let e-household filter [ s -> s != "elderly" ] c-household
        let person item (random (length e-household)) e-household   ; gives 'adult'
        let new-walker position person household    ; because it is about healthy people, it doesn't matter which one specifically is going.
      hatch 1 [
        set walker? true set shape "person"
        set color brown
        set my-age item new-walker household
        set occupancy "busy"
        ; QUEUING-MODEL
        set destination (one-of fooddistros)
        set current-task (one-of fooddistros)
        set destinationx ([xcor] of destination)
        set destinationy ([ycor] of destination)
         ;;
        ifelse random 100 < compliance [set compliant? true ][set compliant? false] ]
      set household remove-item new-walker household ]
        [ ifelse the-walker = 3 [  ;; a non-elderly from the sick people
          let designated-walker one-of free-tents with [my-age = "adult"]
      ask designated-walker [   ;; here is the ASK error
        set walker? true set shape "person"
        set occupancy "busy"
        ; QUEUING-MODEL
        set destination (one-of fooddistros)
        set current-task (one-of fooddistros)
        set destinationx ([xcor] of destination)
        set destinationy ([ycor] of destination)]
        ;;
      let to-remove position [my-age] of designated-walker sick-household
        set sick-household remove-item to-remove sick-household]
   [ ifelse the-walker = 4 [  ;; a tent with [(destination = "none") and ((infection-perception = "healthy") or (compliant? = False))]
      let designated-walker one-of free-tents with [(my-age != "child") and ((infection-perception = "healthy") or (compliant? = False))]
      ask designated-walker [
        set walker? true set shape "person"
        set occupancy "busy"
        ; QUEUING-MODEL
        set destination (one-of fooddistros)
        set current-task (one-of fooddistros)
        set destinationx ([xcor] of destination)
        set destinationy ([ycor] of destination)]
        ;;
      let to-remove position [my-age] of designated-walker sick-household
        set sick-household remove-item to-remove sick-household]
   [ ifelse the-walker = 5 [  ;; a random sick-tent
        let designated-walker one-of free-tents with [my-age != "child"]
      ask designated-walker [    ;; Here is the ASK error
        set walker? true set shape "person"
        set occupancy "busy"
        ; QUEUING-MODEL
        set destination (one-of fooddistros)
        set current-task (one-of fooddistros)
        set destinationx ([xcor] of destination)
        set destinationy ([ycor] of destination)]
        ;;
      let to-remove position [my-age] of designated-walker sick-household
        set sick-household remove-item to-remove sick-household]
   [if the-walker = 6 [
     let designated-walker one-of free-tents with [(compliant? = False) and (my-age != "child")]
     ask designated-walker [
        set walker? true set shape "person"
        set occupancy "busy"
        ; QUEUING-MODEL
        set destination (one-of fooddistros)
        set current-task (one-of fooddistros)
        set destinationx ([xcor] of destination)
        set destinationy ([ycor] of destination)]
        ;;
      let to-remove position [my-age] of designated-walker sick-household
        set sick-household remove-item to-remove sick-household]]

  ]]]]]


  ; QUEUING-MODEL: changed this to preferred-fooddistro (logic is: if no one is home to walk, they try again in 15 minutes (store it in the supportive variable). if by then no ones is home to walk, they return to initial value (and consequently didnt attend food distro)
  ;; if the-walker reports 0, there is no one at home to walk, so the timer is reset:
  [set preferred-fooddistro-time_sup (preferred-fooddistro-time_sup + 15)
    if preferred-fooddistro-time_sup > [closing-time] of current-task * 60 [set preferred-fooddistro-time_sup preferred-fooddistro-time]]  ; if it's too late, the timer is set to the next day (this is a choice, it should be possible from the aid deliverers as well).
  ;;


end


to go-to-latrines2  ; create a walker and head for nearest latrine
  if ((length household + length sick-household) != 0) [
    let best-latrines min-n-of 2 latrines [distance myself]
    let best-latrine min-one-of latrines [length waiting-list]
  let the-walker a-walker
    ifelse the-walker = 1 [  ;; a random healthy person
      let new-walker random (length household)
      hatch 1 [
        set walker? true set shape "person"
        set color brown
        set my-age item new-walker household
        set occupancy "busy"
        set destination best-latrine
        ifelse random 100 < compliance [set compliant? true ][set compliant? false] ]
      set household remove-item new-walker household ]
   [ ifelse the-walker = 2 [  ;; a non-elderly from the healthy people
      let e-household filter [ s -> s != "elderly" ] household
        let person item (random (length e-household)) e-household   ; gives 'adult' or 'child'
        let new-walker position person household    ; gives a number - because it is about healthy people, it doesn't matter which one specifically is going.
      hatch 1 [
        set walker? true set shape "person"
        set color brown
        set my-age item new-walker household
        set occupancy "busy"
        set destination best-latrine
        ifelse random 100 < compliance [set compliant? true ][set compliant? false] ] ; compliance is measured on a scale [1-100]
      set household remove-item new-walker household ]
   [ ifelse the-walker = 3 [ ;; a non-elderly from the sick people
      let designated-walker one-of tents-here with [(destination = "none") and (my-age != "elderly")]
        ask designated-walker [
        set walker? true set shape "person"
        set occupancy "busy"
        set destination best-latrine ]
      let to-remove position [my-age] of designated-walker sick-household
      set sick-household remove-item to-remove sick-household]
   [ ifelse the-walker = 4 [
      let designated-walker one-of tents-here with [(destination = "none") and ((infection-perception = "healthy") or (compliant? = False))]
      ask designated-walker [
        set walker? true set shape "person"
        set occupancy "busy"
        set destination best-latrine ]
      let to-remove position [my-age] of designated-walker sick-household
        set sick-household remove-item to-remove sick-household]
   [ ifelse the-walker = 5 [  ;; a random sick-tent
      let designated-walker one-of tents-here with [destination = "none"]
      ask designated-walker [
        set walker? true set shape "person"
        set occupancy "busy"
        set destination best-latrine ]
      let to-remove position [my-age] of designated-walker sick-household
        set sick-household remove-item to-remove sick-household]
   [if the-walker = 6 [
     let designated-walker one-of tents-here with [(destination = "none") and (compliant? = False)]
     ask designated-walker [
        set walker? true set shape "person"
        set occupancy "busy"
        set destination best-latrine ]
      let to-remove position [my-age] of designated-walker sick-household
        set sick-household remove-item to-remove sick-household]
  ]]]]]]
end


to go-to-waterpoint2   ; create a walker and head for nearest waterpoint
  let free-tents tents-here with [destination = "none"]
  ifelse ((length household + length sick-household) != 0) [
    let best-waterpoints min-n-of 2 waterpoints [distance myself]
    let best-waterpoint min-one-of waterpoints [length waiting-list]
    let the-walker a-walker
   ifelse the-walker = 1 [  ;; a random healthy person
      let new-walker random (length household)
      hatch 1 [
        set walker? true set shape "person"
        set color brown
        set my-age item new-walker household
        set occupancy "busy"
        set destination best-waterpoint
        ifelse random 100 < compliance [set compliant? true ][set compliant? false] ]
      set household remove-item new-walker household ]
   [ ifelse the-walker = 2 [  ;; a non-elderly from the healthy people
      let e-household filter [ s -> s != "elderly" ] household
        let person item (random (length e-household)) e-household   ; gives 'adult' or 'child'
        let new-walker position person household    ; because it is about healthy people, it doesn't matter which one specifically is going.
      hatch 1 [
        set walker? true set shape "person"
        set color brown
        set my-age item new-walker household
        set occupancy "busy"
        set destination best-waterpoint
        ifelse random 100 < compliance [set compliant? true ][set compliant? false] ]
      set household remove-item new-walker household   ]
   [ ifelse the-walker = 3 [  ;; a non-elderly from the sick people
        let designated-walker one-of free-tents with [(my-age != "elderly")]
      ask designated-walker [
        set walker? true set shape "person"
        set occupancy "busy"
        set destination best-waterpoint ]
      let to-remove position [my-age] of designated-walker sick-household
      set sick-household remove-item to-remove sick-household]
   [ ifelse the-walker = 4 [
      let designated-walker one-of tents-here with [(destination = "none") and ((infection-perception = "healthy") or (compliant? = False))];; free-tents with [((infection-perception = "healthy") or (compliant? = False))]
      ask designated-walker [
        set walker? true set shape "person"
        set occupancy "busy"
        set destination best-waterpoint ]
      let to-remove position [my-age] of designated-walker sick-household
        set sick-household remove-item to-remove sick-household]
   [ ifelse the-walker = 5 [  ;; a random sick-tent
      let designated-walker one-of free-tents
      ask designated-walker [
        set walker? true set shape "person"
        set occupancy "busy"
        set destination best-waterpoint ]
      let to-remove position [my-age] of designated-walker sick-household
        set sick-household remove-item to-remove sick-household]
   [if the-walker = 6 [
     let designated-walker one-of tents-here with [(destination = "none") and (compliant? = False)]
     ask designated-walker [ ;;;; hier zit een error!
        set walker? true set shape "person"
        set occupancy "busy"
        set destination best-waterpoint ]
      let to-remove position [my-age] of designated-walker sick-household
        set sick-household remove-item to-remove sick-household]
  ]]]]]]
;  if there's no-one at home now, set water-time + 1.
    [set water-time (water-time + 1)]
end


to go-to-healthcare  ; Currently, healthcare-time is specified for normal healthcare usage. Not for COVID-19 care.
  let free-tents tents-here with [destination = "none"]
    let counthousehold length household

  if mobility = "isolation" [  ; when mobility is isolation, the chance of visiting healthcare is already reduced with 50%. Still, people can go, if a household is healthy or the agent in question is not compliant.
    if any? tents with [(myhome = [myhome] of myself) and (infection = "symptomatic")]
    [ let noncompliant count free-tents with [(infection-perception = "healthy") and (compliant? = False)]
      if noncompliant != 0 [
        let designated-walker one-of free-tents with [(infection-perception = "healthy") and (compliant? = False)]
        ask designated-walker [
          set walker? true set shape "person"
          set occupancy "busy"
          set destination (min-one-of hc-facs [distance myself]) ]
        let to-remove position [my-age] of designated-walker sick-household
          set sick-household remove-item to-remove sick-household]
     stop] ]  ; if this part is exectued, the following should not be executed.

    ;; if there is no symptomatic person in the household, while mobility = isolation, or if mobility != isolation:
  if (counthousehold + (count free-tents with [infection-perception = "healthy"])) > 0
   [ ifelse random (counthousehold + count tents-here with [(destination = "none") and (infection-perception = "healthy")]) < counthousehold
      [ let new-walker random (counthousehold)
        hatch 1 [
          set walker? true set shape "person"
          set occupancy "busy"
          set my-age item new-walker household
          set destination (min-one-of hc-facs [distance myself])
          ifelse random 100 < compliance [set compliant? true ][set compliant? false] ]
        set household remove-item new-walker household ]
      [let designated-walker one-of free-tents with [infection-perception = "healthy"]
        ask designated-walker [
          set walker? true set shape "person"
          set occupancy "busy"
          set destination (min-one-of hc-facs [distance myself]) ]
        let to-remove position [my-age] of designated-walker sick-household
          set sick-household remove-item to-remove sick-household] ]
end


to new-walking
  ask tents with [walker? = True] [

    ;;; if you want to ENABLE WALKING, the next 2 rows should be un-commented:
;    ifelse distance destination > speed [new-lookout-and-walk]
;     [

    ;; if distance < speed:
    ;; if destination = myhome, no need to queue, so just go home:
    ;; but if destination != myhome, tents follow the last tent in the queue (if there is a queue). If there is no queue, they move to the patch, (round?)
    ;; COVID-facilities don't have a queue, so ask for bed-capacity.

    if destination = myhome [ move-to myhome
      set destination "none"
      set occupancy "free"
      ifelse infected? = True [
        ;; if you're critically ill, you go to a covid-facility:
        ifelse (infection = "severely-symptomatic") or (infection = "critical") [set destination min-one-of COVID-facilities [distance myself]
        ]
        ;; otherwise you add yourself to sick-household
        [ ask shelters in-radius 0 [set sick-household lput ([my-age] of myself) sick-household]
            set walker? false] stop]
      ;; if you're healthy, add yourself to household.
        [ ask shelters in-radius 0 [set household lput ([my-age] of myself) household]
          die] stop]

    ifelse destination = one-of COVID-facilities [            ; IMPROVEMENT: this should be member? agent agentset (this if there is more than one, otherwise its ok)
      ifelse [bed-capacity] of destination < 1 [ ; there is no room in-hospital right now -> wait for room in hospital.
      ]

      ;; when bed-capacity is sufficient:
        [ if occupancy = "free" [ move-to destination
          set occupancy "in-hospital"
        set walker? False
          if infection = "critical" [demand-IC-capacity]
           ; Not specified yet what happens if no bed-capacity is available.
          if infection = "severely-symptomatic" [demand-bed-capacity]]
          ; in 'to become-recovered', the person releases the capacity and sets its new destination (home) when recovered
    ]]

    ;; if destination is any other facility:
      ;; Two possibilities: (2nd is implemented now)
      ;; 1) Queue behind the last one in line
      ;; 2) Move in a straight line towards the facility and stop when you've reached people in the queue (CURRENTLY IMPLEMENTED)
      [


      ; QUEUING-MODEL: this is the main integration: if the destination is the food distribution, follow other functions instead of these!
      ifelse destination = one-of fooddistros [go-get-food-queuingmodel] [  ;;

        ifelse queue-time = 0  [ ;; when stepping into a queue
        ifelse [length waiting-list] of destination > 0 [

        face destination
        fd (distance destination - (social-distancing / patch-length))
        while [any? other tents with [(occupancy = "in-queue") and (destination = [destination] of self)] in-radius (social-distancing / patch-length)][fd ( 0 - social-distancing)]

;        ;; uncomment the next two lines if you're using option 1) to queue behind the last one in line.
;          let p [last waiting-list] of destination
;          face p fd (distance p - (social-distancing / patch-length))

          set queue-time (queue-time + 1)
          if queue-time = 1 [ask destination [set waiting-list lput myself waiting-list]
          set occupancy "in-queue"]]    ;; 3!


        ;; if waiting-list is empty:
         [ move-to destination
;          [if (distance destination > speed) [set color yellow facexy destinationx destinationy forward patchespertick]
          set queue-time (queue-time + 1)
          if queue-time = 1 [ask destination [set waiting-list lput myself waiting-list] ]] ]

      ;; if queue-time was not 0: (already in queue)
      [ ;while-in-queue
  if (patch-here != [patch-here] of destination) and (occupancy = "in-queue") [
        face destination
      let vision (sqrt((social-distancing * social-distancing) * 2))
        if not any? other tents with [occupancy = "in-queue"] in-cone vision 90 [;;; a^2 + b^2 = c^2, keep distance in 90 degrees
        fd social-distancing ]]
  ]]]]

;   ]
end

to while-in-queue   ;; queueing 1) gebruikt occupancy 'in-queue'
;if occupancy = "in-queue" [
  show myself
  if (patch-here != [patch-here] of destination) and (occupancy = "in-queue") [
        face destination
      let vision (sqrt((social-distancing * social-distancing) * 2))
        if not any? other tents with [occupancy = "in-queue"] in-cone vision 90 [;;; a^2 + b^2 = c^2, keep distance in 90 degrees
        fd social-distancing ]] ;]
end


to new-lookout-and-walk ;; not used if walking is not enabled
  face destination
  fd speed
  if any? shelters in-radius (social-distancing / patch-length)
   [rt -135
      while [any? shelters in-radius (social-distancing / patch-length)] [fd (social-distancing / patch-length)] ]
end


to manage-queues
  ask facilities [
    if length waiting-list >= 1 [
    ; if there is a waiting list:
      set serving-time (serving-time - 1)
      if serving-time = 0 [ask item 0 waiting-list [ set destination [myhome] of self set queue-time 0 set occupancy "busy" ]
      set waiting-list but-first waiting-list
        set serving-time initial-serving-time
        ; also bring the next customer:
        if length waiting-list >= 1 [
          while [item 0 waiting-list = nobody][
          set waiting-list but-first waiting-list
          ask item 0 waiting-list [move-to myself ;set queue-time 0
        ]]
  ]]]
;  ;; queueing 2) Let the facility ask people in the queue to move forward. ; works, but too slow.
;    foreach waiting-list [[the-turtle] -> ask the-turtle [
;      if patch-here != [patch-here] of destination [
;        face destination
;        if not any? other tents in-cone 90 (sqrt((social-distancing * social-distancing) * 2)) with [occupancy = "in-queue"] [;;; a^2 + b^2 = c^2, keep distance in 90 degrees
;          fd social-distancing]
;      ]]]

    ;;;;;; foreach facilities [[the-turtle] -> ask the-turtle [print [who] of self] ]
    ]
end






;;;;;;;;;;;;;;; VIRUS SPREAD ;;;;;;;;;;;;;;

to initiate-corona
  ask n-of initial-corona-number tents [
    let age-of-sick-agent random (length household)
    set sick-household lput item age-of-sick-agent household sick-household
    set household remove-item age-of-sick-agent household
    hatch 1 [
      set my-age item 0 sick-household
      set infected? True
      set infection "infected"
      set where-did-i-get-infected "patient-zero"
      set next-stage "pre-symptomatic"
      set time-until-next-stage 3 * 24
      set destination "none"
      ifelse random 100 < compliance [set compliant? true ][set compliant? false] ]
    show-infections  ]

  ;set infection-locations [] ;; to enable listing all infection locations during simulation

  ; trying to track infections (EVA)
  set infection-locations-coordinates []
  set attitude-infectee []
  set attitude-infector []
  set infection-locations-activity []
  set infection-locations-activity-previous []
  set comb_maxmin_queuingtime_cooperative [0 0 0]
  set comb_maxmin_queuingtime_competitive [0 0 0]
  set comb_maxmin_queuingtime_newcompetitive [0 0 0]
end

to show-infections-masks    ; colors turtles according to their health status:
  if show-colors? = True [
  ask tents with [infection = "infected"] [set color cyan]
  ask tents with [infection = "pre-symptomatic"] [set color yellow]
  ask tents with [infection = "asymptomatic"] [set color yellow]
  ask tents with [infection = "symptomatic"] [set color orange]
  ask tents with [infection = "severely-symptomatic"] [set color red]
  ask tents with [infection = "critical"] [set color magenta]
  ask tents with [infection = "recovered"] [set color grey]
  ]
  ;; tents that are within 1,5m(infection-distance) of an infectious tent can become infected. This risk is indicated with a green color.
  ask tents with [infected? = False]
  [ let infecting-agents (tents with [(infected? = True) and (infection = "pre-symptomatic") or (infection = "symptomatic") or (infection = "asymptomatic")] in-radius infection-distance)
    ifelse any? infecting-agents
    ; yes, there are infecting agents:
    [ifelse all? infecting-agents [compliant? = True] [
      set color 53 set time-until-next-stage time-until-next-stage + 1
      let infecting-agent one-of infecting-agents
      set who-is-infecting-me infecting-agent ]
      ;ifelse destination = myhome [set destination-when-infected (list who my-age infecting-agent ([infection] of infecting-agent) ([my-age] of infecting-agent) (min-one-of facilities [distance myself]) queue-time)]
      ;[set destination-when-infected (list who my-age infecting-agent ([infection] of infecting-agent) ([my-age] of infecting-agent) destination queue-time) ]]
      ;; if not all infecting-agents comply (so some are not wearing a mask):
      [
      set color green set time-until-next-stage time-until-next-stage + 1
        let infecting-agent one-of infecting-agents]]
      ;ifelse destination = myhome [set destination-when-infected (list who my-age infecting-agent ([infection] of infecting-agent) ([my-age] of infecting-agent) (min-one-of facilities [distance myself]) queue-time)]
        ;[set destination-when-infected (list who my-age infecting-agent ([infection] of infecting-agent) ([my-age] of infecting-agent) destination queue-time) ]]]
    ; if there are no infecting-agents:
    [set time-until-next-stage 0
     ifelse walker? [set color brown][set color blue]]]

end


to show-infections    ; colors turtles according to their health status:
  if show-colors? = True [
  ask tents with [infection = "infected"] [set color cyan]
  ask tents with [infection = "pre-symptomatic"] [set color yellow]
  ask tents with [infection = "asymptomatic"] [set color yellow]
  ask tents with [infection = "symptomatic"] [set color orange]
  ask tents with [infection = "severely-symptomatic"] [set color red]
  ask tents with [infection = "critical"] [set color magenta]
  ask tents with [infection = "recovered"] [set color grey]
  ]
  ;; tents that are within 1,5m(infection-distance) of an infectious tent can become infected. This risk is indicated with a green color.
  ask tents with [infected? = False]
  [ let infecting-agents (tents with [(infected? = True) and (infection = "pre-symptomatic") or (infection = "symptomatic") or (infection = "asymptomatic")] in-radius infection-distance)
    ifelse any? infecting-agents
    ;; yes, there are infecting agents:
    [set color green set time-until-next-stage time-until-next-stage + 1
      let infecting-agent one-of infecting-agents
      set who-is-infecting-me infecting-agent]
      ;ifelse destination = myhome [set destination-when-infected (list who my-age infecting-agent ([infection] of infecting-agent) ([my-age] of infecting-agent) (min-one-of facilities [distance myself]) queue-time)]
      ;[set destination-when-infected (list who my-age infecting-agent ([infection] of infecting-agent) ([my-age] of infecting-agent) destination queue-time) ]]
      ;; if not all infecting-agents comply (so some are not wearing a mask):
    ; if there are no infecting-agents:
    [set time-until-next-stage 0
     ifelse walker? [set color brown][set color blue]]
  ]

end


to infect   ; is currently initiated every tick.
  ask tents with [color = green] [
    ;; if a sick person passed by a shelters and infects the shelter:
    ifelse destination = "Home" [
      foreach household [[instance]  -> if (random-float 1 < (0.01 * transmission-probability * time-until-next-stage)) and (instance != "child") [  ; deze regel zou nog dubieus kunnen zijn.
        ask shelters in-radius 0 [
          set household remove-item (position instance household) household
          set sick-household lput instance sick-household
          hatch 1 [
            set my-age instance
            set destination "none"
            ifelse random 100 < compliance [set compliant? true ][set compliant? false] ]
        ] ]]]
    [ ifelse time-until-next-stage < 15    ; below 15 minutes of contact with an infected person, there's still a chance of no infection.
      [ let chance random-float 1
        ifelse my-age = "child" [if chance < (0.005 * transmission-probability * time-until-next-stage) [ become-infected ]] ; children have a 50% smaller chance to get infected.
        [ if chance < (0.01 * transmission-probability * time-until-next-stage) [ become-infected ]]]
      [ become-infected ]                  ; if more than 15 minutes around an infected person: become infected.
  ]]

  if mask-usage = "yes" [
    let transmission-probability-mask (0.01 * transmission-probability * mask-effect * 0.01)
  ask tents with [color = 53] [
    ifelse destination = "Home" [

      foreach household [[instance]  -> if (random-float 1 < (transmission-probability-mask * time-until-next-stage)) and (instance != "child") [  ; deze regel zou nog dubieus kunnen zijn.
        ask shelters in-radius 0 [
          set household remove-item (position instance household) household
          set sick-household lput instance sick-household
          hatch 1 [
            set my-age instance
            set destination "none"
            ifelse random 100 < compliance [set compliant? true ][set compliant? false] ]
        ] ]]]
    [ ifelse time-until-next-stage < 15    ; below 15 minutes of contact with an infected person, there's still a chance of no infection.
      [ let chance random-float 1
        ifelse my-age = "child" [if chance < (0.5 * transmission-probability-mask * time-until-next-stage) [ become-infected ]] ; children have a 50% smaller chance to get infected.
        [ if chance < (transmission-probability-mask * time-until-next-stage) [ become-infected ]]]
      [ become-infected ]                  ; if more than 15 minutes around an infected person: become infected.
  ]]]
end


to disease-progression
  set time-until-next-stage (time-until-next-stage - 1)
  if time-until-next-stage =  0
  [ ifelse next-stage = "pre-symptomatic" [ become-pre-symptomatic stop ]
    [ ifelse next-stage = "symptomatic" [ become-symptomatic stop ]
      [ ifelse next-stage = "asymptomatic" [ become-asymptomatic stop ]
        [ ifelse next-stage = "recovered" [ become-recovered ]
          [ ifelse next-stage = "severely-symptomatic" [ become-severely-symptomatic stop ]
            [ ifelse next-stage = "critical" [ become-critical stop ]
              [ if next-stage = "dead" [ become-dead ]
  ]]]]]]]
end

to become-infected
  set infected? True
  set infection "infected"
  set cum-infected cum-infected + 1
  let x random 10    ;;; might be removed
  if x = 0 [set infection-perception "infected"]
  set next-stage "pre-symptomatic"
  set time-until-next-stage incubation-time ; determined with the 'to-report' below:
  ;set infection-locations lput destination-when-infected infection-locations


  ;; after GL
  ; updating the agentsets of the nbr of infectious cooperative and infectious competitive
  set infectious-competitive tents with [(infection = "pre-symptomatic" or infection = "symptomatic" or infection = "asymptomatic") and (attitude = "competitive" or attitude = "new-competitive")]
  ifelse any? tents with [(infection = "pre-symptomatic" or infection = "symptomatic" or infection = "asymptomatic") and (attitude = "competitive" or attitude = "new-competitive")] [set nbr-infectious-competitive count infectious-competitive][set nbr-infectious-competitive 0]

  set infectious-cooperative tents with [(infection = "pre-symptomatic" or infection = "symptomatic" or infection = "asymptomatic") and attitude = "cooperative"]
  ifelse any? tents with [(infection = "pre-symptomatic" or infection = "symptomatic" or infection = "asymptomatic") and attitude = "cooperative"] [set nbr-infectious-cooperative count infectious-cooperative][set nbr-infectious-cooperative 0]

  set total-infectious tents with [(infected? = True) and (infection = "pre-symptomatic") or (infection = "symptomatic") or (infection = "asymptomatic")]
  ifelse any? tents with [(infection = "pre-symptomatic" or infection = "symptomatic" or infection = "asymptomatic")] [set nbr-infectious count total-infectious][set nbr-infectious 0]



  ;; testing infection tracking
  ask who-is-infecting-me [
    set nbr-people-i-infected nbr-people-i-infected + 1   ;; about this.. i am afraid this "who is infectign me" changes and its not a constant person the whole 15 min.. so i think this will be a bit random...
    ; tracking and getting info about infections
    ifelse attitude = "cooperative" [
      set infections-provoked-cooperative-total infections-provoked-cooperative-total + 1
      set infections-provoked-cooperative-average infections-provoked-cooperative-total / nbr-infectious-cooperative] [
      set infections-provoked-competitive-total infections-provoked-competitive-total + 1
      set infections-provoked-competitive-average infections-provoked-competitive-total / nbr-infectious-competitive]]


  ; trying to track infections (EVA)
  set x-when-infected xcor
  set y-when-infected ycor
  set infection-locations-coordinates lput x-when-infected infection-locations-coordinates
  set infection-locations-coordinates lput y-when-infected infection-locations-coordinates

  set where-did-i-get-infected destination
  set infection-locations-activity lput where-did-i-get-infected infection-locations-activity
  set attitude-infectee lput attitude attitude-infectee


  set where-did-the-person-before-get-infected [where-did-i-get-infected] of who-is-infecting-me
  set infection-locations-activity-previous lput where-did-the-person-before-get-infected infection-locations-activity-previous
  set attitude-person-who-infected-me [attitude] of who-is-infecting-me
  set attitude-infector lput attitude-person-who-infected-me attitude-infector


end

to-report incubation-time
  let sigma 2.1
  let mu 5.5

  let incubationperiod (exp random-normal ln(mu) ln(sqrt(sigma)))
  let pre-symptomatic-infectious-time ((random 24) + 24) ;; 1-2 days before symptom onset, people become infectious
  report round ((incubationperiod * 24) - pre-symptomatic-infectious-time)
end


to become-pre-symptomatic
  set infection "pre-symptomatic"
  let chance1 random-float 1
  let chance (chance1 / factor-asymptomatic)
  ifelse ((chance < 0.383) and (my-age = "elderly")) or ((chance < 0.52) and (my-age = "adult")) or ((chance < 0.444) and (my-age = "child"))
    [ set next-stage "asymptomatic" ]
    [ set next-stage "symptomatic" ]
  set time-until-next-stage (random 24 + 24) ;; between 1 and 2 days
end

to become-symptomatic
  set infection "symptomatic"
  set infection-perception "infected"
  set cum-symptomatic cum-symptomatic + 1
  let chance random-float 1

  ifelse ((chance < 0.063) and (my-age = "child")) or ((chance < 0.096) and (my-age = "adult")) or ((chance < 0.281) and (my-age = "elderly"))
  [ if ((chance < 0.033) and (my-age = "elderly")) [become-dead]
    set next-stage "severely-symptomatic"
    set time-until-next-stage symptomatic-to-hospital-time]
  [ set next-stage "recovered"
    set time-until-next-stage 7 * 24]

  if mobility = "isolation"[  ; as soon as there is 1 symptomatic person in a house, no one can go out anymore, unless one of them is non-compliant.
    if compliant? = True [
      if not any? tents with [(myhome = [myhome] of myself) and (compliant? = False)]
      [ ask myhome [ask shelters in-radius 0 [set shelters shelters with [self != myself]]]]]]
end

to-report symptomatic-to-hospital-time
  let alpha ( 3.3 * 3.3 / 17.64)
  let lambda ( 1 / (17.64 / 3.3))
  report round ( (random-gamma alpha lambda) * 24)
end


to become-asymptomatic
  set infection "asymptomatic"
  set infection-perception "healthy"
  set cum-asymptomatic cum-asymptomatic + 1
  set next-stage "recovered"
  set time-until-next-stage 4 * 24
end

to become-severely-symptomatic
  set infection "severely-symptomatic"
  set cum-severe cum-severe + 1
  let chance random-float 1

  ifelse ((chance < 0.043) and (my-age = "child")) or ((chance < 0.152) and (my-age = "adult")) or ((chance < 0.275) and (my-age = "elderly"))
  [ if ((chance < 0.022) and (my-age = "adult")) or ((chance < 0.145) and (my-age = "elderly")) [
    set next-stage "dead"
    set time-until-next-stage severe-to-dead-time ]
    set next-stage "critical"
    set time-until-next-stage 2 * 24]
  [ set next-stage "recovered"
    set time-until-next-stage ((14 * 24) - symptomatic-to-hospital-time)]
  ; when at home, go to hospital when situation becomes severe:
  if destination = "none" [
    set walker? true set shape "person"
    let leaving self
    ask shelters in-radius 0 [
      let to-remove position [my-age] of leaving sick-household
      set sick-household remove-item to-remove sick-household]
    set destination min-one-of COVID-facilities [distance myself]
  if mobility = "isolation" [
    ask myhome [if count tents-here with [(infection = "symptomatic") and (compliant? = True)] = 0 [ask shelters in-radius 0
      [set shelters (turtle-set shelters self)]]]]
   ]
end


to-report severe-to-dead-time ;[#scale #shape]
  let time-in-days random-normal 8.8 1.8
  let time-in-hours time-in-days * 24
  report round (time-in-hours)
end


to become-critical
  set infection "critical"
  set cum-critical cum-critical + 1
  let chance random-float 1

  ifelse ((chance < 0.0006) and (my-age = "child")) or ((chance < 0.153) and (my-age = "adult")) or ((chance < 0.394) and (my-age = "elderly"))
  [ set next-stage "dead"
    set time-until-next-stage critical-to-dead-time]
  [ set next-stage "recovered"
    set time-until-next-stage critical-to-recovered-time]
  ; when at home, go to hospital when situation becomes critical:
  if destination = "none" [
    set walker? true set shape "person"
    let leaving self
    ask shelters in-radius 0 [
      let to-remove position [my-age] of leaving sick-household
      set sick-household remove-item to-remove sick-household]
    set destination min-one-of COVID-facilities [distance myself]]
  if destination = one-of COVID-facilities [demand-IC-capacity]
end

to-report critical-to-recovered-time  ;; random triangular distribution
  let FC ((7 - 5) / (12 - 5))
  let U random-float 1
  ifelse U < FC [
    report (5 + (sqrt (U * (12 - 5) * (7 - 5)))) * 24 ]
  [report round (12 - (sqrt ((1 - U ) * (12 - 5) * (12 - 7)))) * 24]
end

to-report critical-to-dead-time
  let time-in-days random-normal 7.5 3
  let time-in-hours time-in-days * 24
  report round (time-in-hours)
end


to become-recovered
  release-capacity
  set infection "recovered"
  set cum-recovered cum-recovered + 1
  set infection-perception "immune"
  set time-until-next-stage 1000 * 24  ;; 1000 days, it is unlimited.
  if patch-here != myhome [
    set destination myhome
    set walker? true set shape "person"
    set occupancy "free"]

  if mobility = "isolation" [
    ask myhome [if count tents-here with [(infection = "symptomatic") and (compliant? = True)] = 0 [ask shelters in-radius 0
      [set shelters (turtle-set shelters self)]]]]
end

to become-dead
  let dying self
  ifelse patch-here = myhome [
    ask shelters in-radius 0 [
      let to-remove position [my-age] of dying sick-household
      set sick-household remove-item to-remove sick-household
;      show sick-household
    ]] [release-capacity]
  set cum-dead cum-dead + 1
  set numpopulation numpopulation - 1
  if mobility = "isolation" [
    ask myhome [if count tents-here with [(infection = "symptomatic") and (compliant? = True)] = 0 [ask shelters in-radius 0
      [set shelters (turtle-set shelters self)]]]]
  die
end

to demand-IC-capacity
  ask destination [ ifelse IC-capacity > 0  ; change from hospital bed to IC bed]
    [set IC-capacity IC-capacity - 1    set in-IC in-IC + 1
     set bed-capacity bed-capacity + 1  set in-treatment in-treatment - 1 ]
    [if bed-capacity > 0 [
      set bed-capacity (bed-capacity - 1 ) set in-treatment (in-treatment + 1) ]]]
end

to demand-bed-capacity
  ask destination [if bed-capacity > 0 [
    set bed-capacity (bed-capacity - 1 ) set in-treatment (in-treatment + 1) ]]
end

to release-capacity
  if destination = one-of COVID-facilities [
    if infection = "critical" [ask destination [ set IC-capacity (IC-capacity + 1)  set in-IC (in-IC - 1)]]
    if infection = "severely-symptomatic" [ask destination [ set bed-capacity (bed-capacity + 1)  set in-treatment (in-treatment - 1)]]
  ]
  if patch-here != myhome [
    set destination myhome
    set walker? true set shape "person"
    set occupancy "free"]
end

;;;;;;;;;;; QUEUING-MODEL: here are all the functions related to the queuing model! ;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; SETUP FUNCTIONS ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;

; A part of this was already integrated in the code from Bogel


  ; %% SETUP-FOODPOINTS: self-explanatory %% ;
  ; ===================================================== ;
to setup-foodpoint
  create-fooddistros 1
  [ setxy 88 55
    set color pink
    set shape "truck"
    set size 4
    set walkable? "no"                           ; for the spatial constraints (not being used)
    set physical-waiting-list []                 ; initializing lists
    set serving-waiting-list []                  ; ""
    set opening-time 9                           ; hour at which the food distribution starts
    set heading 250                              ; for the in-cone procedures later on
    set closing-time opening-time + hours-open   ; assumption: the number of hours a food point is open can be change but it will always open at the same time


    ; % Implementation of policies (very MSc thesis related: potentially not interesting for future use)
    ; depending on the policy implemented, the service-time will change
    ; service-time is the number of ticks (minutes) it takes for each person to get served at the food point
    if policy-implemented = "policy 0 (baseline)" [set service-time 4]     ; baseline: 20% of the population attends it (head of households)
    if policy-implemented = "policy 1" [set service-time 10]               ; policy 1: 2% of the population attends it (representatives of large groups)
    if policy-implemented = "policy 2" [set service-time 7]                ; policy 2: 4% of the population attends it (representatives of medium groups)
    if policy-implemented = "policy 3" [set service-time 6]                ; policy 3: 7% of the population attends it (representatives of small groups)
    ;if policy-implemented = "policy 4" [set service-time 1]                ; not used in this model



    ; % Supportive placement of competitive people (complementary to what is done in the setup function - there we decided which agents are placed in each area, here we decide the spatial constraints)
    ; the frontal zone (for agents with place from to 1 to 3 - see setup)
    ask patches in-cone 5 60 with [distance one-of fooddistros > 3]
      [ ;set pcolor red
        set queuing-zone "queuing_frontal"]
    ; the medium positions
    ask patches in-cone 10 90 with [distance one-of fooddistros < 10 and distance one-of fooddistros > 4]
      [ ;set pcolor pink
        set queuing-zone "queuing_medium"]
    ; the far positions
    ask patches in-cone 20 90 with [distance one-of fooddistros < 20 and distance one-of fooddistros > 10 and pycor > 49 and pycor < 59]
      [ ;set pcolor yellow
        set queuing-zone "queuing_far"]

  ]
end


  ; %% DETERMINE-ATTITUDE: this function is called when setting up the refugees. It sets up refugee's attitude according to their initial tendency-to-competitiveness value AND the threshold to become competitive %%
  ; called by: setup-refugees
  ; ======================================================= ;
to determine-attitude
  ask tents with [natural-tendency <= threshold-competitive] [           ; if their natural-tendency is equal or less than the threshold, they are cooperative
    set attitude "cooperative"]
  ask tents with [natural-tendency > threshold-competitive] [            ; if their natural-tendency is more than the threshold, they are competitive
    set attitude "competitive"
    ;output-print who
  ];output-print "test" ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; GENERAL FUNCTIONS ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


  ; GO-GET-FOOD-QUEUINGMODEL: this is the function responsible to determine how agents that have the task of getting food behave depending on their attitude
  ; This is divided into two parts: joining the waiting lists and physical movements during queuing %%
  ; called by: move-around
  ; calls on: just-walk-fast, update-competitiveness-length, got-influenced, line-up-cooperative, line-competitive and line-new-competitive
  ; =================================================;
to go-get-food-queuingmodel

  if current-task = one-of fooddistros [


  ; % 1) Joining the waiting lists

  ; % getting closer: first, set destination as the beginning of the queue and head there
  ; (to guarantee it only sends the right ones, we have 3 conditions in the IF statement: not member - means that they are just starting the process and haven't been added to a list yet; time-remaining != 0 - means that they weren't just served; attitude != new-competitive - because at the beginning of the queuing process no one can be new competitive yet (people are cooperative or competitive by nature))
  let starting-patch one-of patches with [start-queue = "yes"]       ; save location of the beginning of the queue
  if (not member? self [serving-waiting-list] of current-task) and (time-remaining-service != 0 ) and (attitude != "new-competitive") [set color yellow set destinationx ([pxcor] of starting-patch) set destinationy ([pycor] of starting-patch) facexy destinationx destinationy just-walk-fast]

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
         ask tents with [(current-task = one-of fooddistros) and (member? self [serving-waiting-list] of current-task)][
            ;set number-in-serving-queue ([position myself serving-waiting-list] of current-task)                            ; update the attribute with position of each individual in the serving-waiting-list
            set time-remaining-service [service-time] of current-task]                                                      ; so not necessary anymore because of the + 1 above but let's keep it jic



         ; % b) updating tendency-to-competitiveness - if there are people cutting the line within the agent's visibility, update their tendency to competitiveness
         ask tents with [current-task = one-of fooddistros and member? self [physical-waiting-list] of current-task and attitude = "cooperative" and (abs(xcor - destinationx) <= patchespertick and abs(ycor - destinationy) <= patchespertick)]  ; ask the cooperative refugees who are both in the waiting list but also already in their correct place
           [ let cutting-queues-people tents with [current-task = one-of fooddistros and member? self [serving-waiting-list] of current-task and attitude = "competitive"] in-cone radius-visibility 60                                            ; count the amount of people cutting the line around them
             if count cutting-queues-people > 0                                                                                                                                                                                                       ; if that is more than 0 (so if they can see someone cutting the line)
             [ ;set color yellow
               set list-influencing [self] of tents with [current-task = one-of fooddistros and member? self [serving-waiting-list] of current-task and attitude = "competitive"] in-cone radius-visibility 60                                     ; add the person(s) cutting the line to the "list-influencing" attribute of the cooperative person seeing it
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
      [;set color white                                                                          ; to make it easier to debug
       set time-spent-food time-spent-food + 1                                                  ; track the time spent in the process of getting food
       ;line-competitive-old                                                                    ; call function to "line-up" the competitive way
       line-competitive]                                                                        ; new version of this function

  ; % FOR NEW-COMPETITIVE
  if (member? self [serving-waiting-list] of current-task) and (attitude = "new-competitive")   ; tbh they are always already in the list, most important thing here is the check of the attitude
      [set time-spent-food time-spent-food + 1                                                  ; track the time spent in the process of getting food
       line-new-competitive]                                                                    ; call function to "line up" in the new competitive way

  ]

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
  let how-long length [physical-waiting-list] of current-task                                                                           ; store the length of the physical waiting list of the task they are busy with in a temporary variable

  ; % calculate impact depending on length
  if how-long >= 0 and how-long < (acceptable-length * 0.33) [set impact-on-me 0]                                                       ; if the queue length is between 0 and 1/3 of the aceptable length, no impact (reasonable length so people don't get mad about it)
  if how-long >= (acceptable-length * 0.33) and how-long < acceptable-length [set impact-on-me how-long * impact-long-queues * 0.05 ]   ; if the queue length is between 1/3 of the acceptable length and the acceptable length, the impact is equal to the length times the impact of long queues * 0.05 (to scale it down because of the queue size)
  if how-long >= acceptable-length [set impact-on-me impact-long-queues]                                                                ; if the queue length is more than the acceptable length, add the full impact of long queues

  ; % update value
  set tendency-after-queuing (natural-tendency + impact-on-me)                                                                          ; update tendency-after-queuing as the natural-tendency they are born with plus the impact just calculated

  ; % check if went over threshold
  if tendency-after-queuing > threshold-competitive [got-influenced]                                                   ; if the value is now higher than the threshold, update both attitude and behaviour (got-influenced)


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

  ask tents with [current-task = one-of fooddistros and member? self [physical-waiting-list] of current-task and attitude = "cooperative" and (abs(xcor - destinationx) <= patchespertick and abs(ycor - destinationy) <= patchespertick) and [position myself serving-waiting-list] of current-task  != 0] ; ask cooperative agents who are in their spot in the line
    [ set currently-influencing [self] of tents with [current-task = one-of fooddistros and member? self [serving-waiting-list] of current-task and (attitude = "competitive" or attitude = "new competitive")] in-cone radius-visibility 60                                                                ; add people cutting the line within their vision to the list ; ASSUMPTION: they only see in front of them
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
  ; calls on: just-walk
  ; ===================================================== ;
to line-up-cooperative

  ; % if they are first in line
  ask tents with [(current-task = one-of fooddistros) and (member? self [physical-waiting-list] of current-task) and (attitude = "cooperative")][
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
    ifelse (self = [item 0 physical-waiting-list] of current-task) [set destinationx ([xcor] of current-task) - startingpointx set destinationy ([ycor] of current-task) - startingpointy] [set destinationx (before-me-x - (social-distancing / patch-length)) set destinationy before-me-y]

    ; % If they are not at their destination yet, walk forward. Once they are at their destination, start tracking time in queue
    ifelse (abs(xcor - destinationx) > patchespertick or abs(ycor - destinationy) > patchespertick)[facexy destinationx destinationy just-walk][if start-tracking-time = 0 [set tracking-time-in-queue 1 set start-tracking-time 1]]] ; start-tracking-time is a supportive boolean variable to guarantee that this count only starts once and only counts after having initialized it

end



  ; %% LINE-COMPETITIVE: after having integrated the competitive people in the serving-waiting-list, this function places them physically - this physical position is dependent on their position in the list %%
  ; called by: go-get-food
  ; calls on: just-walk
  ; ===================================================== ;
to line-competitive
; ASSUMPTION: competitive people do not follow social distancing

  ; % if they are the number one in the serving queue, they go to the starting point of the queue (this is the same for everyone, regardless of their attitude)
  if self = [item 0 serving-waiting-list] of current-task [

    set destinationx ([xcor] of current-task - startingpointx)  ; get coordinates of the start of the queue (x)
    set destinationy ([ycor] of current-task) - startingpointy  ; get coordinates of the start of the queue (y)

    ; If they are not at their destination yet, walk forward. Once they are at their destination, start tracking time in queue
    ifelse (abs(xcor - destinationx) > patchespertick or abs(ycor - destinationy) > patchespertick)[facexy destinationx destinationy just-walk][if start-tracking-time = 0 [set tracking-time-in-queue 1 set start-tracking-time 1]]]

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
    ifelse (abs(xcor - destinationx) > patchespertick or abs(ycor - destinationy) > patchespertick)[facexy destinationx destinationy just-walk][if start-tracking-time = 0 [set tracking-time-in-queue 1 set start-tracking-time 1]]]

end


  ; %% LINE-NEW-COMPETITIVE: function to place the new competitive (initially cooperative agents who changed attitude). The placement of these agents is connected to the placement of the person in front of them in the serving waiting list %%
  ; called by: go-get-food
  ; calls on: just-walk
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
  ifelse (abs(xcor - destinationx) > patchespertick or abs(ycor - destinationy) > patchespertick)[facexy destinationx destinationy just-walk][if start-tracking-time = 0 [set tracking-time-in-queue 1 set start-tracking-time 1]]


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

    let my-attitude-my-timeinqueue list attitude tracking-time-in-queue set attitude-and-timeinqueue lput my-attitude-my-timeinqueue attitude-and-timeinqueue


    set max_queuingtime max (list max_queuingtime tracking-time-in-queue)
    set min_queuingtime min (list min_queuingtime tracking-time-in-queue)

    ; % (1) if the agent served is COOPERATIVE it is necessary to update both lists (as the agent is member of both) and update attributes
    if attitude = "cooperative" and [physical-waiting-list] of current-task != [] [                          ; make sure that physical list is not empty otherwise it will give an error
      set total_cooperative_served total_cooperative_served + 1                                              ; update number of cooperative agents that has been served
      ask current-task [set physical-waiting-list remove myself physical-waiting-list]                       ; remove self from the physical waiting list (as self was just served)
      update-physical-queue                                                                                  ; update the physical waiting list so that everyone moves forward
      ask current-task [set serving-waiting-list remove myself serving-waiting-list]                         ; remove self from the serving waiting list (as self was just served)
      set timeSpentFood_cooperative_output_list lput time-spent-food timeSpentFood_cooperative_output_list   ; track time depending on their attitude
      set trackingTimeInQueue_cooperative_output_list lput tracking-time-in-queue trackingTimeInQueue_cooperative_output_list  ; same but with the perfected tracked time
      set trackingTimeInQueue_cooperative_output ( sum trackingTimeInQueue_cooperative_output_list / total_cooperative_served) ; variable that keeps track of the current average time in queue per attitude
      ; post GL queuing
      set max_queuing_time_cooperative max (list max_queuing_time_cooperative tracking-time-in-queue)
      set min_queuing_time_cooperative min (list min_queuing_time_cooperative tracking-time-in-queue)
      set comb_maxmin_queuingtime_cooperative replace-item 0 comb_maxmin_queuingtime_cooperative max_queuing_time_cooperative
      set comb_maxmin_queuingtime_cooperative replace-item 1 comb_maxmin_queuingtime_cooperative trackingTimeInQueue_cooperative_output
      set comb_maxmin_queuingtime_cooperative replace-item 2 comb_maxmin_queuingtime_cooperative min_queuing_time_cooperative
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
      set destination [myhome] of self                  ; guarantee that they head home after getting food
      set occupancy "busy"
      set color pink                                    ; to help debugging


      ; reset attitude: update attitude to their natural one and related attributes ; ASSUMPTION: even though someone might be influenced into cutting in line, their natural attitude is not changed
      if natural-tendency <= threshold-competitive [set attitude "cooperative"]
      if natural-tendency > threshold-competitive [set attitude "competitive"]
      set tendency-to-competitiveness natural-tendency
      set tendency-after-queuing natural-tendency

    ]

    ; % (2) if the agent served is COMPETITIVE it is only necessary to update the serving list (as it was never part of the physical and the position of cooperative people won't change) and update attributes
    if attitude = "competitive" [
      set total_competitive_served total_competitive_served + 1                                             ; update number of competitive agents that has been served
      ask current-task [set serving-waiting-list remove myself serving-waiting-list]                        ; remove self from the serving waiting list (as self was just served)
      set timeSpentFood_competitive_output_list lput time-spent-food timeSpentFood_competitive_output_list  ; track time depending on their attitude
      set trackingTimeInQueue_competitive_output_list lput tracking-time-in-queue trackingTimeInQueue_competitive_output_list ; same but with the perfected tracked time
      set trackingTimeInQueue_competitive_output ( sum trackingTimeInQueue_competitive_output_list / total_competitive_served) ; variable that keeps track of the current average time in queue per attitude
      ; post GL queuing
      set max_queuing_time_competitive max (list max_queuing_time_competitive tracking-time-in-queue)
      set min_queuing_time_competitive min (list min_queuing_time_competitive tracking-time-in-queue)
      set comb_maxmin_queuingtime_competitive replace-item 0 comb_maxmin_queuingtime_competitive max_queuing_time_competitive
      set comb_maxmin_queuingtime_competitive replace-item 1 comb_maxmin_queuingtime_competitive trackingTimeInQueue_competitive_output
      set comb_maxmin_queuingtime_competitive replace-item 2 comb_maxmin_queuingtime_competitive min_queuing_time_competitive
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
      set destination [myhome] of self                  ; guarantee that they head home after getting food
      set occupancy "busy"
      set color violet                                  ; to help debugging
    ]


    ;; (3) if the agent served is NEW COMPETITIVE, it is only necessary to update the serving list and update attributes
    if attitude = "new-competitive" [
      set total_newcompetitive_served total_newcompetitive_served + 1                                              ; update number of newcompetitive agents that has been served
      ask current-task [set serving-waiting-list remove myself serving-waiting-list]                               ; remove self from the serving waiting list (as self was just served)
      set timeSpentFood_newcompetitive_output_list lput time-spent-food timeSpentFood_newcompetitive_output_list   ; track time depending on their attitude
      set trackingTimeInQueue_newcompetitive_output_list lput tracking-time-in-queue trackingTimeInQueue_newcompetitive_output_list ; same but with the perfected tracked time
      set trackingTimeInQueue_newcompetitive_output ( sum trackingTimeInQueue_newcompetitive_output_list / total_newcompetitive_served) ; variable that keeps track of the current average time in queue per attitude
      ; post GL queuing
      set max_queuing_time_newcompetitive max (list max_queuing_time_newcompetitive tracking-time-in-queue)
      set min_queuing_time_newcompetitive min (list min_queuing_time_newcompetitive tracking-time-in-queue)
      set comb_maxmin_queuingtime_newcompetitive replace-item 0 comb_maxmin_queuingtime_newcompetitive max_queuing_time_newcompetitive
      set comb_maxmin_queuingtime_newcompetitive replace-item 1 comb_maxmin_queuingtime_newcompetitive trackingTimeInQueue_newcompetitive_output
      set comb_maxmin_queuingtime_newcompetitive replace-item 2 comb_maxmin_queuingtime_newcompetitive min_queuing_time_newcompetitive
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
      set destination [myhome] of self                  ; guarantee that they head home after getting food
      set occupancy "busy"
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
  ; calls on: just-walk
  ; ===================================================== ;
to update-physical-queue
  ask tents with [(current-task = one-of fooddistros) and (member? self [physical-waiting-list] of current-task) and (attitude = "cooperative")][   ; ask everyone in the physical-waiting-list
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
    ifelse (self = [item 0 physical-waiting-list] of current-task) [set destinationx ([xcor] of current-task) - startingpointx set destinationy ([ycor] of current-task) - startingpointy] [set destinationx (before-me-x - (social-distancing / patch-length)) set destinationy before-me-y]

    ; % If they are not at their destination yet, walk forward
    if (abs(xcor - destinationx) > patchespertick or abs(ycor - destinationy) > patchespertick)[facexy destinationx destinationy just-walk]
  ]
end





  ; %% UPDATE-SERVING-QUEUE: everytime after having removed or added a member to the serving-waiting-list, everyone in the serving line updates their "number-in-serving-queue" attribute. On top of this, competitive people also adjust their positions %%
  ; called by: go-get-food, got-influenced and refugee-served
  ; calls on: just-walk
  ; ===================================================== ;
to update-serving-queue

  ; % update attributes
  ask tents with [(current-task = one-of fooddistros) and (member? self [serving-waiting-list] of current-task)] [        ; ask all the members of the serving list
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
    if (abs(xcor - destinationx) > patchespertick or abs(ycor - destinationy) > patchespertick)[facexy destinationx destinationy just-walk]]

end

;;;;;;;;;;; WALKING FUNCTIONS ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to just-walk
  let mydestiny patch destinationx destinationy
  if (abs(xcor - destinationx) > patchespertick or abs(ycor - destinationy) > patchespertick)[facexy destinationx destinationy forward patchespertick]
end


to just-walk-fast
  let mydestiny patch destinationx destinationy
  if (abs(xcor - destinationx) > patchespertick * 2 or abs(ycor - destinationy) > patchespertick * 2)[facexy destinationx destinationy forward patchespertick * 2]
end

;;;;;;;;;;; DEFAULT VALUES ;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; this function is used to go back to original values
to default-values


  ;; parameters from Bogel
  set transmission-probability 5
  set mask-effect 50
  set compliance 100
  set plotsize-shelters "12,5 m2"
  set factor-asymptomatic 1.0
  set poor-conditions? True
  set social-distancing 1.5
  set mobility "free"
  set mask-usage "no"
  set food-delivery-day 8
  set block-size "120 shelters"
  set household-size "5 - 10% elderly"

  ; QUEUING-MODEL
  set hours-open 8
  set distribution-pick-up "normal"
  set poisson-mean 3
  set threshold-competitive 50          ; tendency to competitiveness threshold to turn competitive
  set radius-visibility 4               ; the visibility of agents (used to influence some agents when they see people cutting the line around them)
  set impact-seeing-cutting 4           ; impact of seeing a person cutting the line (adds up to tendency-to-competitiveness)
  set impact-long-queues 5              ; impact of long queues (adds up to tendency-to-competitiveness)
  set acceptable-length 70              ; maximum length of queue that people still accept (from this length on, people add the "impact-long-queues" value to their competititveness)
  set impact-length? True


end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 27.5.2021 -- I've been using one-of to see if agents are going to the food distribution. Thankfully there is only one but this needs to be changed to member? agent agentset if more fooddistros are to be implemented. Same thing with covid facility
@#$#@#$#@
GRAPHICS-WINDOW
627
10
1272
446
-1
-1
7.0
1
10
1
1
1
0
0
0
1
0
90
0
60
0
0
1
ticks
30.0

BUTTON
45
94
108
127
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

MONITOR
112
324
162
369
Hour
Hour
0
1
11

BUTTON
111
129
174
162
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
34
129
109
162
go once
go
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
10
471
102
516
mobility
mobility
"free" "quarantined" "isolation" "no-elderly"
0

BUTTON
111
97
185
130
NIL
clear-all
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
66
371
176
416
number of people
numpopulation
17
1
11

MONITOR
65
324
115
369
NIL
Day
17
1
11

MONITOR
160
324
210
369
NIL
Minute
17
1
11

BUTTON
23
14
106
47
NIL
initiate-corona
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
3
324
60
369
NIL
day?
17
1
11

SWITCH
15
288
187
321
poor-conditions?
poor-conditions?
0
1
-1000

CHOOSER
14
196
106
241
plotsize-shelters
plotsize-shelters
"12,5 m2" "25 m2" "50 m2" "100 m2"
0

CHOOSER
109
196
201
241
block-size
block-size
"60 shelters" "120 shelters" "test-mode: few shelters"
1

CHOOSER
14
241
106
286
household-size
household-size
7 "5 - 10% elderly" "5 - 20% elderly"
1

BUTTON
22
63
200
96
Create COVID-19 treatment facility
create-COVID-facility
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
11
597
151
630
compliance
compliance
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
11
634
151
667
factor-asymptomatic
factor-asymptomatic
0.5
2
1.0
0.5
1
NIL
HORIZONTAL

TEXTBOX
6
668
218
738
When adapting the asymptomatic factor, the percentage of asymptomatic people gets adapted across all age groups.\n
11
0.0
1

SLIDER
14
163
215
196
transmission-probability
transmission-probability
0
100
5.0
1
1
%
HORIZONTAL

CHOOSER
108
469
210
514
social-distancing
social-distancing
0.5 1 1.5
2

CHOOSER
11
519
103
564
mask-usage
mask-usage
"yes" "no"
1

SLIDER
106
520
207
553
mask-effect
mask-effect
0
100
50.0
1
1
%
HORIZONTAL

TEXTBOX
9
566
218
608
Infection chance decreases when infector is wearing a mask (not infectee).
11
0.0
1

SLIDER
9
427
128
460
food-delivery-day
food-delivery-day
1
27
8.0
1
1
NIL
HORIZONTAL

CHOOSER
267
234
405
279
distribution-pick-up
distribution-pick-up
"normal" "poisson"
0

CHOOSER
268
57
416
102
policy-implemented
policy-implemented
"policy 0 (baseline)" "policy 1" "policy 2" "policy 3"
0

SWITCH
269
121
378
154
time-slot?
time-slot?
1
1
-1000

TEXTBOX
268
10
463
48
Queuing model parameters
15
85.0
1

TEXTBOX
270
36
420
54
1. policies
13
0.0
1

TEXTBOX
272
104
422
122
policy 4
11
0.0
1

TEXTBOX
269
162
419
180
2. parameters
13
0.0
1

CHOOSER
267
185
405
230
hours-open
hours-open
4 5 6 7 8
4

SLIDER
267
287
439
320
poisson-mean
poisson-mean
0.2
(hours-open * 0.5 ) + 1
3.0
0.2
1
NIL
HORIZONTAL

MONITOR
268
328
405
373
nb attending distribution
count representatives
17
1
11

SLIDER
449
233
621
266
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
441
190
622
223
percentage-competitive
percentage-competitive
0
100
10.0
1
1
NIL
HORIZONTAL

SLIDER
450
297
622
330
radius-visibility
radius-visibility
0
6
4.0
1
1
NIL
HORIZONTAL

SLIDER
451
335
623
368
impact-seeing-cutting
impact-seeing-cutting
0
20
4.0
1
1
NIL
HORIZONTAL

SLIDER
450
407
622
440
acceptable-length
acceptable-length
0
500
70.0
1
1
NIL
HORIZONTAL

SLIDER
450
370
622
403
impact-long-queues
impact-long-queues
0
20
5.0
1
1
NIL
HORIZONTAL

TEXTBOX
453
278
603
296
structural uncertainties
11
0.0
1

TEXTBOX
442
167
592
185
contextual uncertainties
11
0.0
1

SWITCH
321
399
442
432
impact-length?
impact-length?
0
1
-1000

BUTTON
496
110
607
143
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

CHOOSER
108
14
249
59
initial-corona-number
initial-corona-number
1 5 10 15 20
0

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

bread
false
0
Polygon -16777216 true false 140 145 170 250 245 190 234 122 247 107 260 79 260 55 245 40 215 32 185 40 155 31 122 41 108 53 28 118 110 115 140 130
Polygon -7500403 true true 135 151 165 256 240 196 225 121 241 105 255 76 255 61 240 46 210 38 180 46 150 37 120 46 105 61 47 108 105 121 135 136
Polygon -1 true false 60 181 45 256 165 256 150 181 165 166 180 136 180 121 165 106 135 98 105 106 75 97 46 107 29 118 30 136 45 166 60 181
Polygon -16777216 false false 45 255 165 255 150 180 165 165 180 135 180 120 165 105 135 97 105 105 76 96 46 106 29 118 30 135 45 165 60 180
Line -16777216 false 165 255 239 195

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

campsite
false
0
Polygon -7500403 true true 150 11 30 221 270 221
Polygon -16777216 true false 151 90 92 221 212 221
Line -7500403 true 150 30 150 225

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

drop
false
0
Circle -7500403 true true 73 133 152
Polygon -7500403 true true 219 181 205 152 185 120 174 95 163 64 156 37 149 7 147 166
Polygon -7500403 true true 79 182 95 152 115 120 126 95 137 64 144 37 150 6 154 165

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

healthcare
false
8
Circle -1 true false -2 -2 304
Rectangle -2674135 true false 120 0 180 300
Rectangle -2674135 true false -30 120 300 180

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

person doctor
false
0
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -13345367 true false 135 90 150 105 135 135 150 150 165 135 150 105 165 90
Polygon -7500403 true true 105 90 60 195 90 210 135 105
Polygon -7500403 true true 195 90 240 195 210 210 165 105
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -1 true false 105 90 60 195 90 210 114 156 120 195 90 270 210 270 180 195 186 155 210 210 240 195 195 90 165 90 150 150 135 90
Line -16777216 false 150 148 150 270
Line -16777216 false 196 90 151 149
Line -16777216 false 104 90 149 149
Circle -1 true false 180 0 30
Line -16777216 false 180 15 120 15
Line -16777216 false 150 195 165 195
Line -16777216 false 150 240 165 240
Line -16777216 false 150 150 165 150

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
Circle -1 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -1 true false 90 90 120
Circle -7500403 true true 120 120 60

toilet
false
0
Circle -7500403 true true 75 45 30
Polygon -7500403 true true 75 75 75 135 60 195 60 225 75 225 90 165 105 225 120 225 120 195 105 135 105 75
Polygon -7500403 true true 105 75 135 120 135 135 90 90
Polygon -7500403 true true 75 75 45 120 45 135 90 90
Circle -7500403 true true 195 45 30
Polygon -7500403 true true 195 75 195 135 195 165 180 225 195 225 210 165 225 225 240 225 225 165 225 135 225 75
Polygon -7500403 true true 225 75 255 120 255 135 210 90
Polygon -7500403 true true 195 75 165 120 165 135 210 90
Polygon -7500403 true true 195 90 165 195 255 195 225 90
Rectangle -7500403 false true 15 30 285 240

toilet2
false
0
Rectangle -1 true false 0 0 345 300
Polygon -7500403 true true 255 60 300 165 285 165 255 105 255 180 285 300 255 300 225 195 195 300 180 300 165 300 195 180 195 105 165 165 150 165 195 60 255 60
Polygon -7500403 true true 45 60 0 165 15 165 45 105 45 180 15 300 45 300 75 195 105 300 120 300 135 300 105 180 105 105 135 165 150 165 105 60 45 60
Circle -7500403 true true 192 -4 67
Circle -7500403 true true 41 -4 67
Polygon -7500403 true true 195 105 165 240 285 240 255 105

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

wc
false
0
Rectangle -7500403 false true 0 0 285 270
Line -7500403 true 15 45 60 255
Line -7500403 true 60 255 90 120
Line -7500403 true 90 120 120 255
Line -7500403 true 120 255 180 45
Line -7500403 true 270 255 240 255
Line -7500403 true 210 240 195 210
Line -7500403 true 195 210 180 165
Line -7500403 true 180 135 180 165
Line -7500403 true 240 255 210 240
Line -7500403 true 270 45 240 45
Line -7500403 true 240 45 210 60
Line -7500403 true 210 60 195 90
Line -7500403 true 195 90 180 135

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
  <experiment name="Ex0_BaselineAllScenarios" repetitions="10" runMetricsEveryStep="true">
    <setup>default-values
setup
initiate-corona
create-COVID-facility</setup>
    <go>go</go>
    <final>output-write infection-locations-coordinates
output-write infection-locations-activity
output-write attitude-infectee
output-write infection-locations-activity-previous
output-write attitude-infector
output-write attitude-and-timeinqueue
output-write comb_maxmin_queuingtime_cooperative
output-write comb_maxmin_queuingtime_competitive
output-write comb_maxmin_queuingtime_newcompetitive
export-output (word "Ex0_Policy_" policy-implemented "_scenario_" percentage-competitive "_run_" behaviorspace-run-number)</final>
    <timeLimit steps="90000"/>
    <metric>ticks</metric>
    <metric>Day</metric>
    <metric>Hour</metric>
    <metric>Minute</metric>
    <metric>count tents</metric>
    <metric>count tents with [(my-age = "elderly") and (infected? = true)]</metric>
    <metric>count tents with [(my-age = "child") and (infected? = true)]</metric>
    <metric>count tents with [(my-age = "adult") and (infected? = true)]</metric>
    <metric>cum-dead</metric>
    <metric>cum-recovered</metric>
    <metric>trackingTimeInQueue_average_output</metric>
    <metric>trackingTimeInQueue_cooperative_output</metric>
    <metric>trackingTimeInQueue_competitive_output</metric>
    <metric>trackingTimeInQueue_newcompetitive_output</metric>
    <metric>total_served</metric>
    <metric>numberCompetitiveJoining_output</metric>
    <metric>numberNewCompetitive_output</metric>
    <metric>nbr-infectious-competitive</metric>
    <metric>nbr-infectious-cooperative</metric>
    <metric>infections-provoked-cooperative-average</metric>
    <metric>infections-provoked-cooperative-total</metric>
    <metric>infections-provoked-competitive-average</metric>
    <metric>infections-provoked-competitive-total</metric>
    <metric>number_acting_competitive</metric>
    <metric>attitude-and-infections</metric>
    <enumeratedValueSet variable="initial-corona-number">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="policy-implemented">
      <value value="&quot;policy 0 (baseline)&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-slot?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percentage-competitive">
      <value value="0"/>
      <value value="10"/>
      <value value="20"/>
      <value value="30"/>
      <value value="40"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Ex1_AllPoliciesCompetitive0" repetitions="10" runMetricsEveryStep="true">
    <setup>default-values
setup
initiate-corona
create-COVID-facility</setup>
    <go>go</go>
    <final>output-write infection-locations-coordinates
output-write infection-locations-activity
output-write attitude-infectee
output-write infection-locations-activity-previous
output-write attitude-infector
output-write attitude-and-timeinqueue
output-write comb_maxmin_queuingtime_cooperative
output-write comb_maxmin_queuingtime_competitive
output-write comb_maxmin_queuingtime_newcompetitive
export-output (word "Ex1_Policy_" policy-implemented "_scenario_" percentage-competitive "_run_" behaviorspace-run-number)</final>
    <timeLimit steps="90000"/>
    <metric>ticks</metric>
    <metric>Day</metric>
    <metric>Hour</metric>
    <metric>Minute</metric>
    <metric>count tents</metric>
    <metric>count tents with [(my-age = "elderly") and (infected? = true)]</metric>
    <metric>count tents with [(my-age = "child") and (infected? = true)]</metric>
    <metric>count tents with [(my-age = "adult") and (infected? = true)]</metric>
    <metric>cum-dead</metric>
    <metric>cum-recovered</metric>
    <metric>trackingTimeInQueue_average_output</metric>
    <metric>trackingTimeInQueue_cooperative_output</metric>
    <metric>trackingTimeInQueue_competitive_output</metric>
    <metric>trackingTimeInQueue_newcompetitive_output</metric>
    <metric>total_served</metric>
    <metric>numberCompetitiveJoining_output</metric>
    <metric>numberNewCompetitive_output</metric>
    <metric>nbr-infectious-competitive</metric>
    <metric>nbr-infectious-cooperative</metric>
    <metric>infections-provoked-cooperative-average</metric>
    <metric>infections-provoked-cooperative-total</metric>
    <metric>infections-provoked-competitive-average</metric>
    <metric>infections-provoked-competitive-total</metric>
    <metric>number_acting_competitive</metric>
    <metric>attitude-and-infections</metric>
    <enumeratedValueSet variable="initial-corona-number">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="policy-implemented">
      <value value="&quot;policy 0 (baseline)&quot;"/>
      <value value="&quot;policy 1&quot;"/>
      <value value="&quot;policy 2&quot;"/>
      <value value="&quot;policy 3&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-slot?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percentage-competitive">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Ex2_AllPoliciesCompetitive10" repetitions="10" runMetricsEveryStep="true">
    <setup>default-values
setup
initiate-corona
create-COVID-facility</setup>
    <go>go</go>
    <final>output-write infection-locations-coordinates
output-write infection-locations-activity
output-write attitude-infectee
output-write infection-locations-activity-previous
output-write attitude-infector
output-write attitude-and-timeinqueue
output-write comb_maxmin_queuingtime_cooperative
output-write comb_maxmin_queuingtime_competitive
output-write comb_maxmin_queuingtime_newcompetitive
export-output (word "Ex2_Policy_" policy-implemented "_scenario_" percentage-competitive "_run_" behaviorspace-run-number)</final>
    <timeLimit steps="90000"/>
    <metric>ticks</metric>
    <metric>Day</metric>
    <metric>Hour</metric>
    <metric>Minute</metric>
    <metric>count tents</metric>
    <metric>count tents with [(my-age = "elderly") and (infected? = true)]</metric>
    <metric>count tents with [(my-age = "child") and (infected? = true)]</metric>
    <metric>count tents with [(my-age = "adult") and (infected? = true)]</metric>
    <metric>cum-dead</metric>
    <metric>cum-recovered</metric>
    <metric>trackingTimeInQueue_average_output</metric>
    <metric>trackingTimeInQueue_cooperative_output</metric>
    <metric>trackingTimeInQueue_competitive_output</metric>
    <metric>trackingTimeInQueue_newcompetitive_output</metric>
    <metric>total_served</metric>
    <metric>numberCompetitiveJoining_output</metric>
    <metric>numberNewCompetitive_output</metric>
    <metric>nbr-infectious-competitive</metric>
    <metric>nbr-infectious-cooperative</metric>
    <metric>infections-provoked-cooperative-average</metric>
    <metric>infections-provoked-cooperative-total</metric>
    <metric>infections-provoked-competitive-average</metric>
    <metric>infections-provoked-competitive-total</metric>
    <metric>number_acting_competitive</metric>
    <metric>attitude-and-infections</metric>
    <enumeratedValueSet variable="initial-corona-number">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="policy-implemented">
      <value value="&quot;policy 0 (baseline)&quot;"/>
      <value value="&quot;policy 1&quot;"/>
      <value value="&quot;policy 2&quot;"/>
      <value value="&quot;policy 3&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-slot?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percentage-competitive">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Ex3_AllPoliciesCompetitive20" repetitions="10" runMetricsEveryStep="true">
    <setup>default-values
setup
initiate-corona
create-COVID-facility</setup>
    <go>go</go>
    <final>output-write infection-locations-coordinates
output-write infection-locations-activity
output-write attitude-infectee
output-write infection-locations-activity-previous
output-write attitude-infector
output-write attitude-and-timeinqueue
output-write comb_maxmin_queuingtime_cooperative
output-write comb_maxmin_queuingtime_competitive
output-write comb_maxmin_queuingtime_newcompetitive
export-output (word "Ex3_Policy_" policy-implemented "_scenario_" percentage-competitive "_run_" behaviorspace-run-number)</final>
    <timeLimit steps="90000"/>
    <metric>ticks</metric>
    <metric>Day</metric>
    <metric>Hour</metric>
    <metric>Minute</metric>
    <metric>count tents</metric>
    <metric>count tents with [(my-age = "elderly") and (infected? = true)]</metric>
    <metric>count tents with [(my-age = "child") and (infected? = true)]</metric>
    <metric>count tents with [(my-age = "adult") and (infected? = true)]</metric>
    <metric>cum-dead</metric>
    <metric>cum-recovered</metric>
    <metric>trackingTimeInQueue_average_output</metric>
    <metric>trackingTimeInQueue_cooperative_output</metric>
    <metric>trackingTimeInQueue_competitive_output</metric>
    <metric>trackingTimeInQueue_newcompetitive_output</metric>
    <metric>total_served</metric>
    <metric>numberCompetitiveJoining_output</metric>
    <metric>numberNewCompetitive_output</metric>
    <metric>nbr-infectious-competitive</metric>
    <metric>nbr-infectious-cooperative</metric>
    <metric>infections-provoked-cooperative-average</metric>
    <metric>infections-provoked-cooperative-total</metric>
    <metric>infections-provoked-competitive-average</metric>
    <metric>infections-provoked-competitive-total</metric>
    <metric>number_acting_competitive</metric>
    <metric>attitude-and-infections</metric>
    <enumeratedValueSet variable="initial-corona-number">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="policy-implemented">
      <value value="&quot;policy 0 (baseline)&quot;"/>
      <value value="&quot;policy 1&quot;"/>
      <value value="&quot;policy 2&quot;"/>
      <value value="&quot;policy 3&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-slot?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percentage-competitive">
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Ex4_AllPoliciesCompetitive30" repetitions="10" runMetricsEveryStep="true">
    <setup>default-values
setup
initiate-corona
create-COVID-facility</setup>
    <go>go</go>
    <final>output-write infection-locations-coordinates
output-write infection-locations-activity
output-write attitude-infectee
output-write infection-locations-activity-previous
output-write attitude-infector
output-write attitude-and-timeinqueue
output-write comb_maxmin_queuingtime_cooperative
output-write comb_maxmin_queuingtime_competitive
output-write comb_maxmin_queuingtime_newcompetitive
export-output (word "Ex4_Policy_" policy-implemented "_scenario_" percentage-competitive "_run_" behaviorspace-run-number)</final>
    <timeLimit steps="90000"/>
    <metric>ticks</metric>
    <metric>Day</metric>
    <metric>Hour</metric>
    <metric>Minute</metric>
    <metric>count tents</metric>
    <metric>count tents with [(my-age = "elderly") and (infected? = true)]</metric>
    <metric>count tents with [(my-age = "child") and (infected? = true)]</metric>
    <metric>count tents with [(my-age = "adult") and (infected? = true)]</metric>
    <metric>cum-dead</metric>
    <metric>cum-recovered</metric>
    <metric>trackingTimeInQueue_average_output</metric>
    <metric>trackingTimeInQueue_cooperative_output</metric>
    <metric>trackingTimeInQueue_competitive_output</metric>
    <metric>trackingTimeInQueue_newcompetitive_output</metric>
    <metric>total_served</metric>
    <metric>numberCompetitiveJoining_output</metric>
    <metric>numberNewCompetitive_output</metric>
    <metric>nbr-infectious-competitive</metric>
    <metric>nbr-infectious-cooperative</metric>
    <metric>infections-provoked-cooperative-average</metric>
    <metric>infections-provoked-cooperative-total</metric>
    <metric>infections-provoked-competitive-average</metric>
    <metric>infections-provoked-competitive-total</metric>
    <metric>number_acting_competitive</metric>
    <metric>attitude-and-infections</metric>
    <enumeratedValueSet variable="initial-corona-number">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="policy-implemented">
      <value value="&quot;policy 0 (baseline)&quot;"/>
      <value value="&quot;policy 1&quot;"/>
      <value value="&quot;policy 2&quot;"/>
      <value value="&quot;policy 3&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-slot?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percentage-competitive">
      <value value="30"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Ex5_AllPoliciesCompetitive40" repetitions="10" runMetricsEveryStep="true">
    <setup>default-values
setup
initiate-corona
create-COVID-facility</setup>
    <go>go</go>
    <final>output-write infection-locations-coordinates
output-write infection-locations-activity
output-write attitude-infectee
output-write infection-locations-activity-previous
output-write attitude-infector
output-write attitude-and-timeinqueue
output-write comb_maxmin_queuingtime_cooperative
output-write comb_maxmin_queuingtime_competitive
output-write comb_maxmin_queuingtime_newcompetitive
export-output (word "Ex5_Policy_" policy-implemented "_scenario_" percentage-competitive "_run_" behaviorspace-run-number)</final>
    <timeLimit steps="90000"/>
    <metric>ticks</metric>
    <metric>Day</metric>
    <metric>Hour</metric>
    <metric>Minute</metric>
    <metric>count tents</metric>
    <metric>count tents with [(my-age = "elderly") and (infected? = true)]</metric>
    <metric>count tents with [(my-age = "child") and (infected? = true)]</metric>
    <metric>count tents with [(my-age = "adult") and (infected? = true)]</metric>
    <metric>cum-dead</metric>
    <metric>cum-recovered</metric>
    <metric>trackingTimeInQueue_average_output</metric>
    <metric>trackingTimeInQueue_cooperative_output</metric>
    <metric>trackingTimeInQueue_competitive_output</metric>
    <metric>trackingTimeInQueue_newcompetitive_output</metric>
    <metric>total_served</metric>
    <metric>numberCompetitiveJoining_output</metric>
    <metric>numberNewCompetitive_output</metric>
    <metric>nbr-infectious-competitive</metric>
    <metric>nbr-infectious-cooperative</metric>
    <metric>infections-provoked-cooperative-average</metric>
    <metric>infections-provoked-cooperative-total</metric>
    <metric>infections-provoked-competitive-average</metric>
    <metric>infections-provoked-competitive-total</metric>
    <metric>number_acting_competitive</metric>
    <metric>attitude-and-infections</metric>
    <enumeratedValueSet variable="initial-corona-number">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="policy-implemented">
      <value value="&quot;policy 0 (baseline)&quot;"/>
      <value value="&quot;policy 1&quot;"/>
      <value value="&quot;policy 2&quot;"/>
      <value value="&quot;policy 3&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-slot?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percentage-competitive">
      <value value="40"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Ex6_TimeslotBaselineP1_AllScenarios" repetitions="10" runMetricsEveryStep="true">
    <setup>default-values
setup
initiate-corona
create-COVID-facility</setup>
    <go>go</go>
    <final>output-write infection-locations-coordinates
output-write infection-locations-activity
output-write attitude-infectee
output-write infection-locations-activity-previous
output-write attitude-infector
output-write attitude-and-timeinqueue
output-write comb_maxmin_queuingtime_cooperative
output-write comb_maxmin_queuingtime_competitive
output-write comb_maxmin_queuingtime_newcompetitive
export-output (word "Ex6_Policy_" policy-implemented "_timeslot_" time-slot? "_scenario_" percentage-competitive "_run_" behaviorspace-run-number)</final>
    <timeLimit steps="90000"/>
    <metric>ticks</metric>
    <metric>Day</metric>
    <metric>Hour</metric>
    <metric>Minute</metric>
    <metric>count tents</metric>
    <metric>count tents with [(my-age = "elderly") and (infected? = true)]</metric>
    <metric>count tents with [(my-age = "child") and (infected? = true)]</metric>
    <metric>count tents with [(my-age = "adult") and (infected? = true)]</metric>
    <metric>cum-dead</metric>
    <metric>cum-recovered</metric>
    <metric>trackingTimeInQueue_average_output</metric>
    <metric>trackingTimeInQueue_cooperative_output</metric>
    <metric>trackingTimeInQueue_competitive_output</metric>
    <metric>trackingTimeInQueue_newcompetitive_output</metric>
    <metric>total_served</metric>
    <metric>numberCompetitiveJoining_output</metric>
    <metric>numberNewCompetitive_output</metric>
    <metric>nbr-infectious</metric>
    <metric>nbr-infectious-competitive</metric>
    <metric>nbr-infectious-cooperative</metric>
    <metric>infections-provoked-cooperative-average</metric>
    <metric>infections-provoked-cooperative-total</metric>
    <metric>infections-provoked-competitive-average</metric>
    <metric>infections-provoked-competitive-total</metric>
    <metric>number_acting_competitive</metric>
    <metric>attitude-and-infections</metric>
    <metric>number_dailyinfections_perlocation</metric>
    <metric>daily_inf_fooddistro</metric>
    <metric>daily_inf_waterpoint</metric>
    <metric>daily_inf_shelter</metric>
    <metric>daily_inf_latrine</metric>
    <metric>daily_inf_hcfac</metric>
    <enumeratedValueSet variable="initial-corona-number">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="policy-implemented">
      <value value="&quot;policy 0 (baseline)&quot;"/>
      <value value="&quot;policy 1&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-slot?">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percentage-competitive">
      <value value="0"/>
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="desperatetest" repetitions="2" runMetricsEveryStep="true">
    <setup>default-values
setup
initiate-corona
create-COVID-facility</setup>
    <go>go</go>
    <final>output-write infection-locations-coordinates
output-write infection-locations-activity
output-write attitude-infectee
output-write infection-locations-activity-previous
output-write attitude-infector
output-write attitude-and-timeinqueue
output-write comb_maxmin_queuingtime_cooperative
output-write comb_maxmin_queuingtime_competitive
output-write comb_maxmin_queuingtime_newcompetitive
export-output (word "Desperatetest_run_" behaviorspace-run-number)</final>
    <timeLimit steps="10000"/>
    <metric>ticks</metric>
    <metric>Day</metric>
    <metric>Hour</metric>
    <metric>Minute</metric>
    <metric>count tents</metric>
    <metric>count tents with [(my-age = "elderly") and (infected? = true)]</metric>
    <metric>count tents with [(my-age = "child") and (infected? = true)]</metric>
    <metric>count tents with [(my-age = "adult") and (infected? = true)]</metric>
    <metric>cum-dead</metric>
    <metric>cum-recovered</metric>
    <metric>trackingTimeInQueue_average_output</metric>
    <metric>trackingTimeInQueue_cooperative_output</metric>
    <metric>trackingTimeInQueue_competitive_output</metric>
    <metric>trackingTimeInQueue_newcompetitive_output</metric>
    <metric>total_served</metric>
    <metric>numberCompetitiveJoining_output</metric>
    <metric>numberNewCompetitive_output</metric>
    <metric>nbr-infectious</metric>
    <metric>nbr-infectious-competitive</metric>
    <metric>nbr-infectious-cooperative</metric>
    <metric>infections-provoked-cooperative-average</metric>
    <metric>infections-provoked-cooperative-total</metric>
    <metric>infections-provoked-competitive-average</metric>
    <metric>infections-provoked-competitive-total</metric>
    <metric>number_acting_competitive</metric>
    <metric>attitude-and-infections</metric>
    <enumeratedValueSet variable="initial-corona-number">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="policy-implemented">
      <value value="&quot;policy 0 (baseline)&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-slot?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percentage-competitive">
      <value value="10"/>
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
