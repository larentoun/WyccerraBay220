/mob/living/silicon/ai/examine(mob/user)
	. = ..()
	if (stat == DEAD)
		. += "[span_deadsay("It appears to be powered-down.")]"
	else
		if (getBruteLoss())
			if (getBruteLoss() < 30)
				. += span_warning("It looks slightly dented.")
			else
				. += span_warning("<B>It looks severely dented!</B>")
		if (getFireLoss())
			if (getFireLoss() < 30)
				. += span_warning("It looks slightly charred.")
			else
				. += span_warning("<B>Its casing is melted and heat-warped!</B>")
		if (!has_power())
			if (getOxyLoss() > 175)
				. += span_warning("<B>It seems to be running on backup power. Its display is blinking a \"BACKUP POWER CRITICAL\" warning.</B>")
			else if(getOxyLoss() > 100)
				. += span_warning("<B>It seems to be running on backup power. Its display is blinking a \"BACKUP POWER LOW\" warning.</B>")
			else
				. += span_warning("It seems to be running on backup power.")

		if (stat == UNCONSCIOUS)
			. += span_warning("It is non-responsive and displaying the text: \"RUNTIME: Sensory Overload, stack 26/3\".")
	if(hardware && (hardware.owner == src))
		. += span_notice("Hardware:")
		. += span_notice(hardware.get_examine_desc())
	user.showLaws(src)

/mob/proc/showLaws(mob/living/silicon/S)
	return

/mob/observer/ghost/showLaws(mob/living/silicon/S)
	if(antagHUD || isadmin(src))
		S.laws.show_laws(src)
