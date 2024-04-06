#define WARDROBE_BLIND_MESSAGE(fool) "\The [src] flashes a light at \the [fool] as it states a message."

/obj/structure/undies_wardrobe
	name = "underwear wardrobe"
	desc = "Holds item of clothing you shouldn't be showing off in the hallways."
	icon = 'icons/obj/structures/undies_wardrobe.dmi'
	icon_state = "closed"
	density = TRUE
	anchored = TRUE
	obj_flags = OBJ_FLAG_ANCHORABLE
	var/static/list/amount_of_underwear_by_id_card


/obj/structure/undies_wardrobe/use_tool(obj/item/tool, mob/user, list/click_params)
	// Underwear - Return to wardrobe
	if (istype(tool, /obj/item/underwear))
		if (!user.unEquip(tool, src))
			FEEDBACK_UNEQUIP_FAILURE(user, tool)
			return TRUE
		user.visible_message(
			span_notice("\The [user] inserts \a [tool] into \the [src]."),
			span_notice("You insert \the [tool] into \the [src].")
		)
		qdel(tool)
		var/obj/item/card/id/id = user.GetIdCard()
		var/message
		if (id)
			message = "ID card detected. Your underwear quota for this shift has been increased, if applicable."
		else
			message = "No ID card detected. Thank you for your contribution."
		audible_message(message, WARDROBE_BLIND_MESSAGE(user))

		var/number_of_underwear = LAZYACCESS(amount_of_underwear_by_id_card, id) - 1
		if (number_of_underwear)
			LAZYSET(amount_of_underwear_by_id_card, id, number_of_underwear)
			GLOB.destroyed_event.register(id, src, TYPE_PROC_REF(/obj/structure/undies_wardrobe, remove_id_card))
		else
			remove_id_card(id)
		return TRUE

	return ..()


/obj/structure/undies_wardrobe/proc/remove_id_card(id_card)
	LAZYREMOVE(amount_of_underwear_by_id_card, id_card)
	GLOB.destroyed_event.unregister(id_card, src, TYPE_PROC_REF(/obj/structure/undies_wardrobe, remove_id_card))

/obj/structure/undies_wardrobe/attack_hand(mob/user)
	if(!human_who_can_use_underwear(user))
		to_chat(user, span_warning("Sadly there's nothing in here for you to wear."))
		return
	interact(user)

/obj/structure/undies_wardrobe/interact(mob/living/carbon/human/H)
	var/id = H.GetIdCard()

	var/list/dat = list()
	dat += "<b>Underwear</b><br><hr>"
	dat += "You may claim [id ? LAZYLEN(GLOB.underwear.categories) - LAZYACCESS(amount_of_underwear_by_id_card, id) : 0] more article\s this shift.<br><br>"
	dat += "<b>Available Categories</b><br><hr>"

	if(LAZYLEN(GLOB.underwear.categories))
		for(var/datum/category_group/underwear/UWC in GLOB.underwear.categories)
			dat += "[UWC.name] <a href='?src=\ref[src];select_underwear=[UWC.name]'>(Select)</a><br>"

	show_browser(H, dat.Join(), "window=wardrobe;size=400x250")

/obj/structure/undies_wardrobe/proc/human_who_can_use_underwear(mob/living/carbon/human/H)
	if(!istype(H) || !H.species || !(H.species.appearance_flags & SPECIES_APPEARANCE_HAS_UNDERWEAR))
		return FALSE
	return TRUE

/obj/structure/undies_wardrobe/CanUseTopic(user)
	if(!human_who_can_use_underwear(user))
		return STATUS_CLOSE

	return ..()

/obj/structure/undies_wardrobe/Topic(href, href_list, state)
	if(..())
		return TRUE

	var/mob/living/carbon/human/H = usr
	if(href_list["select_underwear"])
		var/datum/category_group/underwear/UWC = LAZYACCESS(GLOB.underwear.categories_by_name, href_list["select_underwear"])
		if(!UWC)
			return
		var/datum/category_item/underwear/UWI = input("Select your desired underwear:", "Choose underwear") as null|anything in exlude_none(UWC.items)
		if(!UWI)
			return

		var/list/metadata_list = list()
		for(var/tweak in UWI.tweaks)
			var/datum/gear_tweak/gt = tweak
			var/metadata = gt.get_metadata(H, title = "Adjust underwear")
			if(!metadata)
				return
			metadata_list["[gt]"] = metadata

		if(!CanInteract(H, state))
			return

		var/id = H.GetIdCard()
		if(!id)
			audible_message("No ID card detected. Unable to acquire your underwear quota for this shift.", WARDROBE_BLIND_MESSAGE(H))
			return

		var/current_quota = LAZYACCESS(amount_of_underwear_by_id_card, id)
		if(current_quota >= LAZYLEN(GLOB.underwear.categories))
			audible_message("You have already used up your underwear quota for this shift. Please return previously acquired items to increase it.", WARDROBE_BLIND_MESSAGE(H))
			return
		LAZYSET(amount_of_underwear_by_id_card, id, ++current_quota)

		var/obj/UW = UWI.create_underwear(H, metadata_list)
		UW.forceMove(loc)
		H.put_in_hands(UW)

		. = TRUE

	if(.)
		interact(H)

/obj/structure/undies_wardrobe/proc/exlude_none(list/L)
	. = L.Copy()
	for(var/e in .)
		var/datum/category_item/underwear/UWI = e
		if(!UWI.underwear_type)
			. -= UWI

#undef WARDROBE_BLIND_MESSAGE
