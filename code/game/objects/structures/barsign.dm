/obj/structure/sign/double/barsign
	desc = "A jumbo-sized LED sign. This one seems to be showing its age."
	icon = 'icons/obj/structures/barsigns.dmi'
	icon_state = "on"
	appearance_flags = DEFAULT_APPEARANCE_FLAGS
	anchored = TRUE
	var/cult = 0

/obj/structure/sign/double/barsign/proc/get_valid_states(initial=1)
	. = ICON_STATES(icon)
	. -= "on"
	. -= "narsiebistro"
	. -= "empty"
	if(initial)
		. -= "Off"

/obj/structure/sign/double/barsign/examine(mob/user)
	. = ..()
	//TODO SS220: Move barsigns to singletons
	switch(icon_state)
		if("Off")
			. += span_notice("It appears to be switched off.")
		if("narsiebistro")
			. += span_notice("It shows a picture of a large black and red being. Spooky!")
		if("on", "empty")
			. += span_notice("The lights are on, but there's no picture.")
		if("Mess Hall - SEV Torch")
			. += span_notice("It appears to be a red haired monk wearing a cheese costume, swinging a hoop around their thighs, holding two torches, inviting you into the mess hall.")
		if("Information Action Ratio")
			. += span_notice("It's the place to go!")
		if("Three Starboard")
			. += span_notice("It says 'Three Starboard' alongside a crude rendition of the SEV Torch- who makes this stuff?")
		if("The Clowns Head")
			. += span_notice("A rather catching portrait of what you can only presume to be the idea of a madman... A Clown Queen...")
		if("The Cranky Goldfish")
			. += span_notice("A crank-powered fish! Why hadn't you thought of that...")
		if("The Cat Caller")
			. += span_notice("An adorable neon kitty to brighten up your day.")
		if("The Diplomatic Resolution")
			. += span_notice("Here's hoping they can talk it out over beer...")
		if("Dragons Hoard")
			. += span_notice("It says 'DRAGONS HOARD'. What cunning adventurer shall swipe the hoard for themselves?")
		if("Closed")
			. += span_notice("How unfortunate...")
		if("Free Drinks!")
			. += span_notice("Yippee!")
		if("We Are Open!")
			. += span_notice("Come on in!")
		if("The Meta Game")
			. += span_notice("Big Brain Plays.")
		if("Bless This Mess")
			. += span_notice("It fills you with a snuggly wuggly sense of warmth and comfort.")
		if("The Redshirt")
			. += span_notice("Mmm... Donuts...")
		if("The Singulo")
			. += span_notice("You spin me right 'round, baby right 'round.")
		else
			. += span_notice("It says '[icon_state]'")

/obj/structure/sign/double/barsign/New()
	..()
	icon_state = pick(get_valid_states())


/obj/structure/sign/double/barsign/use_tool(obj/item/tool, mob/user, list/click_params)
	// ID Card - Change barsign
	var/obj/item/card/id/id = tool.GetIdCard()
	if (istype(id))
		var/id_name = GET_ID_NAME(id, tool)
		if (!check_access(id))
			USE_FEEDBACK_ID_CARD_DENIED(src, id_name)
			return TRUE
		if (cult)
			USE_FEEDBACK_FAILURE("\The [src]'s display can't be changed.")
			return TRUE
		var/input = input(user, "What would you like to change the barsign to?") as null|anything in get_valid_states(FALSE)
		if (!input || input == icon_state || !user.use_sanity_check(src, tool))
			return TRUE
		icon_state = input
		user.visible_message(
			span_notice("\The [user] updates \the [src]'s display with \a [tool]."),
			span_notice("You update \the [src]'s display with [id_name].")
		)
		return TRUE

	return ..()
