/datum/build_mode/move_into
	name = "Move Into"
	icon_state = "buildmode7"

	var/atom/destination

/datum/build_mode/move_into/Destroy()
	ClearDestination()
	. = ..()

/datum/build_mode/move_into/Help()
	to_chat(user, span_notice("***********************************************************"))
	to_chat(user, span_notice("Left Click                  = Select destination"))
	to_chat(user, span_notice("Right Click on Movable Atom = Move target into destination"))
	to_chat(user, span_notice("***********************************************************"))

/datum/build_mode/move_into/OnClick(atom/movable/A, params)
	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, LEFT_CLICK))
		SetDestination(A)
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		if(!destination)
			to_chat(user, span_warning("No target destination."))
		else if(!ismovable(A))
			to_chat(user, span_warning("\The [A] must be of type /atom/movable."))
		else
			to_chat(user, span_notice("Moved \the [A] into \the [destination]."))
			Log("Moved '[log_info_line(A)]' into '[log_info_line(destination)]'.")
			A.forceMove(destination)

/datum/build_mode/move_into/proc/SetDestination(atom/A)
	if(A == destination)
		return
	ClearDestination()

	destination = A
	GLOB.destroyed_event.register(destination, src, TYPE_PROC_REF(/datum/build_mode/move_into, ClearDestination))
	to_chat(user, span_notice("Will now move targets into \the [destination]."))

/datum/build_mode/move_into/proc/ClearDestination(feedback)
	if(!destination)
		return

	GLOB.destroyed_event.unregister(destination, src, TYPE_PROC_REF(/datum/build_mode/move_into, ClearDestination))
	destination = null
	if(feedback)
		Warn("The selected destination was deleted.")
