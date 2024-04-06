/mob/living/silicon/pai/examine(mob/user, distance, is_adjacent)
	. = ..(user, distance, is_adjacent, infix = ", personal AI")
	switch(stat)
		if(CONSCIOUS)
			if(!client)
				. += span_notice("It appears to be in stand-by mode.")
		if(UNCONSCIOUS)
			. += span_warning("It doesn't seem to be responding.")
		if(DEAD)
			. += span_deadsay("It looks completely unsalvageable.")

	if(print_flavor_text())
		. += span_notice("[print_flavor_text()]")

	if (pose)
		if( findtext(pose,".",length(pose)) == 0 && findtext(pose,"!",length(pose)) == 0 && findtext(pose,"?",length(pose)) == 0 )
			pose = addtext(pose,".") //Makes sure all emotes end with a period.
		. += span_notice("It is [pose]")
