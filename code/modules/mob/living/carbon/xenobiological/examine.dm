/mob/living/carbon/slime/examine(mob/user)
	. = ..()
	if (src.stat == DEAD)
		. += span_deadsay("It is limp and unresponsive.")
	else
		if (src.getBruteLoss())
			if (src.getBruteLoss() < 40)
				. += span_warning("It has some punctures in its flesh!")
			else
				. += span_warning("<B>It has severe punctures and tears in its flesh!</B>")

		switch(powerlevel)

			if(2 to 3)
				. += span_notice("It is flickering gently with a little electrical activity.")

			if(4 to 5)
				. += span_notice("It is glowing gently with moderate levels of electrical activity.")

			if(6 to 9)
				. += span_warning("It is glowing brightly with high levels of electrical activity.")

			if(10)
				. += span_warning("<B>It is radiating with massive levels of electrical activity!</B>")
