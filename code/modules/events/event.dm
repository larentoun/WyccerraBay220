/datum/event_meta
	var/name 		= ""
	var/enabled 	= 1	// Whether or not the event is available for random selection at all
	var/weight 		= 0 // The base weight of this event. A zero means it may never fire, but see get_weight()
	var/min_weight	= 0 // The minimum weight that this event will have. Only used if non-zero.
	var/max_weight	= 0 // The maximum weight that this event will have. Only use if non-zero.
	var/severity 	= 0 // The current severity of this event
	var/one_shot	= 0	// If true, then the event will not be re-added to the list of available events
	var/add_to_queue= 1	// If true, add back to the queue of events upon finishing.
	var/list/role_weights = list()
	var/datum/event/event_type

/datum/event_meta/New(event_severity, event_name, datum/event/type, event_weight, list/job_weights, is_one_shot = 0, min_event_weight = 0, max_event_weight = 0, add_to_queue = 1)
	name = event_name
	severity = event_severity
	event_type = type
	one_shot = is_one_shot
	weight = event_weight
	min_weight = min_event_weight
	max_weight = max_event_weight
	src.add_to_queue = add_to_queue
	if(job_weights)
		role_weights = job_weights

/datum/event_meta/proc/get_weight(list/active_with_role)
	if(!enabled)
		return 0

	var/job_weight = 0
	for(var/role in role_weights)
		if(role in active_with_role)
			job_weight += active_with_role[role] * role_weights[role]

	var/total_weight = weight + job_weight

	// Only min/max the weight if the values are non-zero
	if(min_weight && total_weight < min_weight) total_weight = min_weight
	if(max_weight && total_weight > max_weight) total_weight = max_weight

	return total_weight

/datum/event_meta/extended_penalty
	var/penalty = 100 // A simple penalty gives admins the ability to increase the weight to again be part of the random event selection

/datum/event_meta/extended_penalty/get_weight()
	return ..() - (istype(SSticker.mode, /datum/game_mode/extended) ? penalty : 0)

/datum/event_meta/no_overmap/get_weight() //these events have overmap equivalents, and shouldn't fire randomly if overmap is used
	return GLOB.using_map.use_overmap ? 0 : ..()

/datum/event	//NOTE: Times are measured in master controller ticks!
	var/startWhen		= 0	//When in the lifetime to call start().
	var/announceWhen	= 0	//When in the lifetime to call announce().
	var/endWhen			= 0	//When in the lifetime the event should end.

	var/severity		= 0 //Severity. Lower means less severe, higher means more severe. Does not have to be supported. Is set on New().
	var/activeFor		= 0	//How long the event has existed. You don't need to change this.
	var/isRunning		= 1 //If this event is currently running. You should not change this.
	var/startedAt		= 0 //When this event started.
	var/endedAt			= 0 //When this event ended.
	var/datum/event_meta/event_meta = null
	var/list/affecting_z
	var/has_skybox_image

/datum/event/nothing

//Called first before processing.
//Allows you to setup your event, such as randomly
//setting the startWhen and or announceWhen variables.
//Only called once.
/datum/event/proc/setup()
	return

//Called when the tick is equal to the startWhen variable.
//Allows you to start before announcing or vice versa.
//Only called once.
/datum/event/proc/start()
	if(has_skybox_image)
		SSskybox.rebuild_skyboxes(affecting_z)
	return

//Called when the tick is equal to the announceWhen variable.
//Allows you to announce before starting or vice versa.
//Only called once.
/datum/event/proc/announce()
	return

//Called on or after the tick counter is equal to startWhen.
//You can include code related to your event or add your own
//time stamped events.
//Called more than once.
/datum/event/proc/tick()
	return

//Called on or after the tick is equal or more than endWhen
//You can include code related to the event ending.
//Do not place spawn() in here, instead use tick() to check for
//the activeFor variable.
//For example: if(activeFor == myOwnVariable + 30) doStuff()
//Only called once.
/datum/event/proc/end()
	if(has_skybox_image)
		SSskybox.rebuild_skyboxes(affecting_z)
	return

//Returns the latest point of event processing.
/datum/event/proc/lastProcessAt()
	return max(startWhen, max(announceWhen, endWhen))

//Do not override this proc, instead use the appropiate procs.
//This proc will handle the calls to the appropiate procs.
/datum/event/proc/process()
	if(activeFor > startWhen && activeFor < endWhen)
		tick()

	if(activeFor == startWhen)
		isRunning = 1
		start()

	if(activeFor == announceWhen)
		announce()

	if(activeFor == endWhen)
		isRunning = 0
		end()

	// Everything is done, let's clean up.
	if(activeFor >= lastProcessAt())
		kill()

	activeFor++

//Called when start(), announce() and end() has all been called.
/datum/event/proc/kill(reroll = FALSE)
	// If this event was forcefully killed run end() for individual cleanup
	if(isRunning)
		isRunning = 0
		end()

	endedAt = world.time
	SSevent.event_complete(src)

//Called during building of skybox to get overlays
/datum/event/proc/get_skybox_image()

/datum/event/New(datum/event_meta/EM)
	// event needs to be responsible for this, as stuff like APLUs currently make their own events for curious reasons
	SSevent.register_event(src)

	event_meta = EM
	severity = clamp(event_meta.severity, EVENT_LEVEL_MUNDANE, EVENT_LEVEL_MAJOR)

	startedAt = world.time

	if(!affecting_z)
		affecting_z = GLOB.using_map.station_levels

	setup()
	..()

/datum/event/proc/location_name()
	if(!GLOB.using_map.use_overmap)
		return station_name()

	var/obj/overmap/visitable/O = map_sectors["[pick(affecting_z)]"]
	return O ? O.name : "Unknown Location"
