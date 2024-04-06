/obj/structure/closet/coffin
	name = "coffin"
	desc = "It's a burial receptacle for the dearly departed."
	icon_state = "closed"
	icon = 'icons/obj/closets/coffin.dmi'
	setup = 0
	closet_appearance = null

	var/screwdriver_time_needed = 7.5 SECONDS

/obj/structure/closet/coffin/examine(mob/user, distance)
	. = ..()
	if(distance <= 1 && !opened)
		. += span_notice("The lid is [locked ? "tightly secured with screws." : "unsecured and can be opened."]")

/obj/structure/closet/coffin/can_open()
	. =  ..()
	if(locked)
		return FALSE


/obj/structure/closet/coffin/screwdriver_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	// Screwdriver - Toggle lock
	if(opened)
		balloon_alert(user, "нужно закрыть!")
		return
	user.visible_message(
		span_notice("[user] begins screwing [src]'s lid [locked ? "open" : "shut"] with [tool]."),
		span_notice("You begin screwing [src]'s lid [locked ? "open" : "shut"] with [tool].")
	)
	if(!tool.use_as_tool(src, user, screwdriver_time_needed, volume = 50, skill_path = SKILL_CONSTRUCTION, do_flags = DO_REPAIR_CONSTRUCT) || opened)
		return
	user.visible_message(
		span_notice("[user] screws [src]'s lid [locked ? "open" : "shut"] with [tool]."),
		span_notice("You screw [src]'s lid [locked ? "open" : "shut"] with [tool].")
	)
	locked = !locked

/obj/structure/closet/coffin/toggle(mob/user as mob)
	if(!(opened ? close() : open()))
		to_chat(user, span_notice("It won't budge!"))

/obj/structure/closet/coffin/req_breakout()
	. = ..()
	if(locked)
		return TRUE


/obj/structure/closet/coffin/break_open()
	locked = FALSE
	..()

/obj/structure/closet/coffin/wooden
	name = "coffin"
	desc = "It's a burial receptacle for the dearly departed."
	icon = 'icons/obj/closets/coffin_wood.dmi'
	setup = 0
	closet_appearance = null
