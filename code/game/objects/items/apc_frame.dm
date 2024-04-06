// APC HULL

/obj/item/frame/apc
	name = "\improper APC frame"
	desc = "Used for repairing or building APCs."
	icon = 'icons/obj/machines/apc_repair.dmi'
	icon_state = "apc_frame"
	obj_flags = OBJ_FLAG_CONDUCTIBLE

/obj/item/frame/apc/wrench_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(!tool.use_as_tool(src, user, volume = 50, do_flags = DO_REPAIR_CONSTRUCT))
		return
	new /obj/item/stack/material/steel(get_turf(src.loc), 2)
	qdel(src)

/obj/item/frame/apc/try_build(turf/on_wall)
	if (get_dist(on_wall,usr)>1)
		return
	var/ndir = get_dir(usr,on_wall)
	if (!(ndir in GLOB.cardinal))
		return
	var/turf/loc = get_turf(usr)
	var/area/A = loc.loc
	if (!istype(loc, /turf/simulated/floor))
		to_chat(usr, span_warning("APC cannot be placed on this spot."))
		return
	if (A.requires_power == 0 || istype(A, /area/space))
		to_chat(usr, span_warning("APC cannot be placed in this area."))
		return
	if (A.get_apc())
		to_chat(usr, span_warning("This area already has an APC."))
		return //only one APC per area
	for(var/obj/machinery/power/terminal/T in loc)
		if (T.master)
			to_chat(usr, span_warning("There is another network terminal here."))
			return
		else
			var/obj/item/stack/cable_coil/C = new /obj/item/stack/cable_coil(loc)
			C.amount = 10
			to_chat(usr, "You cut the cables and disassemble the unused power terminal.")
			qdel(T)
	new /obj/machinery/power/apc(loc, ndir, TRUE, 1)
	qdel(src)
