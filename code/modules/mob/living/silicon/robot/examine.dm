/mob/living/silicon/robot/examine(mob/user, distance, is_adjacent)
	var/custom_infix = custom_name ? ", [modtype] [braintype]" : ""
	. = ..(user, distance, is_adjacent, infix = custom_infix)
	if (src.getBruteLoss())
		if (src.getBruteLoss() < 75)
			. += span_warning("It looks slightly dented.")
		else
			. += span_warning("<B>It looks severely dented!</B>")
	if (src.getFireLoss())
		if (src.getFireLoss() < 75)
			. += span_warning("It looks slightly charred.")
		else
			. += span_warning("<B>It looks severely burnt and heat-warped!</B>")

	if(opened)
		. += span_warning("Its cover is open and the power cell is [cell ? "installed" : "missing"].")
	else
		. += span_notice("Its cover is closed.")

	if(!has_power)
		. += span_warning("It appears to be running on backup power.")

	switch(src.stat)
		if(CONSCIOUS)
			if(!src.client)
				. += span_notice("It appears to be in stand-by mode.")
		if(UNCONSCIOUS)
			. += span_warning("It doesn't seem to be responding.")
		if(DEAD)
			. += SPAN_CLASS("deadsay", "It looks completely unsalvageable.")

	if(print_flavor_text())
		. += span_notice("[print_flavor_text()]")

	if (pose)
		if( findtext(pose,".",length(pose)) == 0 && findtext(pose,"!",length(pose)) == 0 && findtext(pose,"?",length(pose)) == 0 )
			pose = addtext(pose,".") //Makes sure all emotes end with a period.
		. += span_notice("It [pose]")
	user.showLaws(src)
	return
