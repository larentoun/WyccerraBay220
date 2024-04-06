//microscope code itself
/obj/machinery/microscope
	name = "high powered electron microscope"
	desc = "A highly advanced microscope capable of zooming up to 3000x."
	icon = 'icons/obj/machines/forensics/microscope.dmi'
	icon_state = "microscope"
	anchored = TRUE
	density = TRUE

	var/obj/item/sample = null
	var/report_num = 0

/obj/machinery/microscope/Destroy()
	if(sample)
		sample.dropInto(loc)
	..()

/obj/machinery/microscope/use_tool(obj/item/W, mob/living/user, list/click_params)
	if(sample)
		to_chat(user, span_warning("There is already a slide in the microscope."))
		return ..()

	if (istype(W, /obj/item/evidencebag))
		var/obj/item/evidencebag/B = W
		if (B.stored_item)
			to_chat(user, span_notice("You insert \the [B.stored_item] from \the [B] into the microscope."))
			B.stored_item.forceMove(src)
			sample = B.stored_item
			B.empty()
		else
			to_chat(user, span_warning("\The [B] is empty!"))
		return TRUE

	if(!user.unEquip(W, src))
		return TRUE
	to_chat(user, span_notice("You insert \the [W] into the microscope."))
	sample = W
	update_icon()
	return TRUE

/obj/machinery/microscope/physical_attack_hand(mob/user)
	. = TRUE
	if(!sample)
		to_chat(user, span_warning("The microscope has no sample to examine."))
		return

	to_chat(user, span_notice("The microscope whirrs as you examine \the [sample]."))

	if(!user.do_skilled(2.5 SECONDS, SKILL_FORENSICS, src) || !sample)
		to_chat(user, span_notice("You stop examining \the [sample]."))
		return

	if(!user.skill_check(SKILL_FORENSICS, SKILL_TRAINED))
		to_chat(user, span_warning("You can't figure out what it means..."))
		return

	to_chat(user, span_notice("Printing findings now..."))
	var/obj/item/paper/report = new(get_turf(src))
	report.stamped = list(/obj/item/stamp)
	report.SetOverlays("paper_stamp-circle")
	report_num++

	var/list/evidence = list()
	var/scaned_object = sample.name
	if(istype(sample, /obj/item/forensics/swab))
		var/obj/item/forensics/swab/swab = sample
		evidence["gunshot_residue"] = swab.gunshot_residue_sample.Copy()
	else if(istype(sample, /obj/item/sample/fibers))
		var/obj/item/sample/fibers/fibers = sample
		scaned_object = fibers.object
		evidence["fibers"] = fibers.evidence.Copy()
	else if(istype(sample, /obj/item/sample/print))
		var/obj/item/sample/print/card = sample
		scaned_object = card.object ? card.object : card.name
		evidence["prints"] = card.evidence.Copy()
	else
		if(sample.fingerprints)
			evidence["prints"] = sample.fingerprints.Copy()
		if(sample.suit_fibers)
			evidence["fibers"] = sample.suit_fibers.Copy()
		if(sample.gunshot_residue)
			evidence["gunshot_residue"] = sample.gunshot_residue.Copy()

	report.SetName("Forensic report #[++report_num]: [sample.name]")
	report.info = "<b>Scanned item:</b><br>[scaned_object]<br><br>"
	if("gunshot_residue" in evidence)
		report.info += "<b>Gunpowder residue analysis report #[report_num]</b>: [scaned_object]<br>"
		if(LAZYLEN(evidence["gunshot_residue"]))
			report.info += "Residue from the following bullets detected:"
			for(var/residue in evidence["gunshot_residue"])
				report.info += "[span_notice("[residue]")]<br><br>"
		else
			report.info += "No gunpowder residue found."
	if("fibers" in evidence)
		if(LAZYLEN(evidence["fibers"]))
			report.info += "Molecular analysis on provided sample has determined the presence of unique fiber strings.<br><br>"
			for(var/fiber in evidence["fibers"])
				report.info += "[span_notice("Most likely match for fibers: [fiber]")]<br><br>"
		else
			report.info += "No fibers found."
	if("prints" in evidence)
		report.info += "<b>Fingerprint analysis report</b>: [scaned_object]<br>"
		if(LAZYLEN(evidence["prints"]))
			report.info += "Surface analysis has determined unique fingerprint strings:<br><br>"
			for(var/prints in evidence["prints"])
				report.info += span_notice("Fingerprint string: ")
				if(!is_complete_print(evidence["prints"][prints]))
					report.info += "INCOMPLETE PRINT"
				else
					report.info += "[prints]"
				report.info += "<br>"
		else
			report.info += "No information available."

	if(report)
		report.update_icon()
		if(report.info)
			to_chat(user, report.info)
	return

/obj/machinery/microscope/proc/remove_sample(mob/living/remover)
	if(!istype(remover) || remover.incapacitated() || !Adjacent(remover))
		return
	if(!sample)
		to_chat(remover, span_warning("\The [src] does not have a sample in it."))
		return
	to_chat(remover, span_notice("You remove \the [sample] from \the [src]."))
	remover.put_in_hands(sample)
	sample = null
	update_icon()

/obj/machinery/microscope/AltClick()
	remove_sample(usr)
	return TRUE

/obj/machinery/microscope/MouseDrop(atom/other)
	if(usr == other)
		remove_sample(usr)
	else
		return ..()

/obj/machinery/microscope/on_update_icon()
	ClearOverlays()
	if(panel_open)
		AddOverlays("[icon_state]_panel")
	if(is_powered())
		AddOverlays(emissive_appearance(icon, "[icon_state]_lights"))
		AddOverlays("[icon_state]_lights")
	if(sample)
		AddOverlays(emissive_appearance(icon, "[icon_state]_lights_working"))
		AddOverlays("[icon_state]_lights_working")
