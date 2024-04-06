//
//Robotic Component Analyser, basically a health analyser for robots
//
/obj/item/device/robotanalyzer
	name = "robot analyzer"
	icon = 'icons/obj/tools/robot_analyzer.dmi'
	icon_state = "robotanalyzer"
	item_state = "analyzer"
	desc = "A hand-held scanner able to diagnose robotic injuries."
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BELT
	throwforce = 3
	w_class = ITEM_SIZE_SMALL
	throw_speed = 5
	throw_range = 10
	origin_tech = list(TECH_MAGNET = 2, TECH_BIO = 1, TECH_ENGINEERING = 2)
	matter = list(MATERIAL_STEEL = 250, MATERIAL_GLASS = 100, MATERIAL_PLASTIC = 75)
	var/mode = 1;

/proc/roboscan(mob/living/M, mob/living/user)
	if((MUTATION_CLUMSY in user.mutations) && prob(50))
		to_chat(user, text(span_warning("You try to analyze the floor's vitals!")))
		for(var/mob/O in viewers(M, null))
			O.show_message(text(span_warning("[user] has analyzed the floor's vitals!"), 1))
		user.show_message(text(span_notice("Analyzing Results for The floor:\n\t Overall Status: Healthy"), 1))
		user.show_message(text(span_notice("\t Damage Specifics: [0]-[0]-[0]-[0]"), 1))
		user.show_message(span_notice("Key: Suffocation/Toxin/Burns/Brute"), 1)
		user.show_message(span_notice("Body Temperature: ???"), 1)
		return

	var/scan_type
	if(istype(M, /mob/living/silicon/robot))
		scan_type = "robot"
	else if(istype(M, /mob/living/carbon/human))
		scan_type = "prosthetics"
	else if (istype(M, /mob/living/exosuit))
		scan_type = "exosuit"
	else
		to_chat(user, span_warning("You can't analyze non-robotic things!"))
		return

	user.visible_message(span_notice("\The [user] has analyzed [M]'s components."),span_notice("You have analyzed [M]'s components."))
	switch(scan_type)
		if("robot")
			var/BU = M.getFireLoss() > 50 	? 	"<b>[M.getFireLoss()]</b>" 		: M.getFireLoss()
			var/BR = M.getBruteLoss() > 50 	? 	"<b>[M.getBruteLoss()]</b>" 	: M.getBruteLoss()
			user.show_message(span_notice("Analyzing Results for [M]:\n\t Overall Status: [M.stat > 1 ? "fully disabled" : "[M.health - M.getHalLoss()]% functional"]"))
			user.show_message("\t Key: [SPAN_COLOR("#ffa500", "Electronics")]/[SPAN_COLOR("red", "Brute")]", 1)
			user.show_message("\t Damage Specifics: [SPAN_COLOR("#ffa500", BU)] - [SPAN_COLOR("red", BR)]")
			if(M.stat == DEAD)
				user.show_message(span_notice("Time of Failure: [time2text(worldtime2stationtime(M.timeofdeath))]"))
			var/mob/living/silicon/robot/H = M
			var/list/damaged = H.get_damaged_components(1,1,1)
			user.show_message(span_notice("Localized Damage:"),1)
			if(length(damaged)>0)
				for(var/datum/robot_component/org in damaged)
					var/message = "\t [capitalize(org.name)]: "
					message += (org.installed == -1) ? SPAN_COLOR("red", "<b>DESTROYED</b> ") : ""
					message += (org.electronics_damage > 0) ? SPAN_COLOR("#ffa500", org.electronics_damage) : "0"
					message += (org.brute_damage > 0) ? SPAN_COLOR("red", org.brute_damage) : "0"
					message += org.toggled ? "Toggled ON" : SPAN_COLOR("red", "Toggled OFF")
					message += org.powered ? "Power ON" : SPAN_COLOR("red", "Power OFF")
					user.show_message(span_notice(message), VISIBLE_MESSAGE)
			else
				user.show_message(span_notice("\t Components are OK."),1)
			if(H.emagged && prob(5))
				user.show_message(span_warning("\t ERROR: INTERNAL SYSTEMS COMPROMISED"),1)
			user.show_message(span_notice("Operating Temperature: [M.bodytemperature-T0C]&deg;C ([M.bodytemperature*1.8-459.67]&deg;F)"), 1)

		if("prosthetics")

			var/mob/living/carbon/human/H = M
			to_chat(user, span_notice("Analyzing Results for \the [H]:"))
			to_chat(user, "Key: [SPAN_COLOR("#ffa500", "Electronics")]/[SPAN_COLOR("red", "Brute")]")
			var/obj/item/organ/internal/cell/C = H.internal_organs_by_name[BP_CELL]
			if(C)
				to_chat(user, span_notice("Cell charge: [C.percent()] %"))
			else
				to_chat(user, span_notice("Cell charge: ERROR - Cell not present"))

			to_chat(user, "<hr>")

			to_chat(user, span_notice("Internal brain activity:"))
			var/obj/item/organ/internal/B = H.internal_organs_by_name[BP_BRAIN]
			if(B)
				to_chat(user, "[B.name]: [SPAN_COLOR("red", (B.status & ORGAN_DEAD) ? "NO ACTIVITY DETECTED - DAMAGED PAST POINT OF NO RETURN" : B.damage)]")
			else
				to_chat(user, SPAN_COLOR("red", "ERROR - Brain not present"))

			to_chat(user, "<hr>")

			to_chat(user, span_notice("External prosthetics:"))

			var/organ_found
			for(var/obj/item/organ/external/E in H.organs)
				if(!BP_IS_ROBOTIC(E))
					continue
				organ_found = 1
				to_chat(user, "[E.name]: [SPAN_COLOR("red", E.brute_dam)] [SPAN_COLOR("#ffa500", E.burn_dam)][SPAN_COLOR("red", (E.status & ORGAN_BROKEN) ? "- INTERNAL STRUCTURE FRACTURED" : "")]")
			if(!organ_found)
				to_chat(user, "No prosthetics located.")

			to_chat(user, "<hr>")

			to_chat(user, span_notice("Internal prosthetics:"))
			organ_found = null
			for(var/obj/item/organ/O in H.internal_organs)
				if(!BP_IS_ROBOTIC(O))
					continue
				organ_found = 1
				to_chat(user, "[O.name]: [SPAN_COLOR("red", "[(O.status & ORGAN_DEAD) ? "DESTROYED" : O.damage]")]")
			if(!organ_found)
				to_chat(user, "No prosthetics located.")

		if ("exosuit")
			var/mob/living/exosuit/mech = M
			to_chat(user, span_info("Diagnostic Report for \the [M]:"))
			for (var/obj/item/mech_component/component in list(mech.arms, mech.legs, mech.body, mech.head))
				if (component)
					component.return_diagnostics(user)

	playsound(user,'sound/effects/scanbeep.ogg', 30)
	return

/obj/item/device/robotanalyzer/use_before(mob/living/M, mob/living/user)
	. = FALSE
	if (!istype(M))
		return FALSE
	roboscan(M, user)
	add_fingerprint(user)
	return TRUE
