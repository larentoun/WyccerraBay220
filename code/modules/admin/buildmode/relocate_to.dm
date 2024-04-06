/datum/build_mode/relocate_to
	name = "Relocate To"
	icon_state = "buildmode9"
	var/atom/movable/to_relocate

/datum/build_mode/relocate_to/Destroy()
	ClearRelocator()
	. = ..()

/datum/build_mode/relocate_to/Help()
	to_chat(user, span_notice("***********************************************************"))
	to_chat(user, span_notice("Left Click on Movable Atom = Select object to be relocated"))
	to_chat(user, span_notice("Right Click on Turf        = Destination to be relocated to"))
	to_chat(user, span_notice("***********************************************************"))

/datum/build_mode/relocate_to/OnClick(atom/A, params)
	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, LEFT_CLICK))
		if(istype(A, /atom/movable))
			SetRelocator(A)
	else if(LAZYACCESS(modifiers, RIGHT_CLICK))
		if(to_relocate)
			var/destination_turf = get_turf(A)
			if(destination_turf)
				to_relocate.forceMove(destination_turf)
				Log("Relocated '[log_info_line(to_relocate)]' to '[log_info_line(destination_turf)]'")
			else
				to_chat(user, span_warning("Unable to locate destination turf."))
		else
			to_chat(user, span_warning("You have nothing selected to relocate."))

/datum/build_mode/relocate_to/proc/SetRelocator(new_relocator)
	if(to_relocate == new_relocator)
		return
	ClearRelocator()

	to_relocate = new_relocator
	GLOB.destroyed_event.register(to_relocate, src, TYPE_PROC_REF(/datum/build_mode/relocate_to, ClearRelocator))
	to_chat(user, span_notice("Will now be relocating \the [to_relocate]."))

/datum/build_mode/relocate_to/proc/ClearRelocator(feedback)
	if(!to_relocate)
		return

	GLOB.destroyed_event.unregister(to_relocate, src, TYPE_PROC_REF(/datum/build_mode/relocate_to, ClearRelocator))
	to_relocate = null
	if(feedback)
		Warn("The selected relocation object was deleted.")
