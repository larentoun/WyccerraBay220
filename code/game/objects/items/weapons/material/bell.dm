/obj/item/material/bell
	name = "bell"
	desc = "A bell to ring to get people's attention. Don't break it."
	icon = 'icons/obj/structures/bells.dmi'
	icon_state = "bell"
	max_force = 5
	force_multiplier = 0.8
	thrown_force_multiplier = 0.3
	hitsound = 'sound/items/oneding.ogg'
	default_material = MATERIAL_ALUMINIUM
	var/normal_sound = 'sound/items/oneding.ogg'
	var/angry_sound = 'sound/items/manydings.ogg'


/obj/item/material/bell/attack_hand(mob/living/user)
	if (user.a_intent == I_GRAB)
		return ..()
	else if (user.a_intent == I_HURT)
		user.visible_message(
			span_warning("\The [user] hammers on \a [src]."),
			span_warning("You hammer on \the [src]."),
			span_warning("You hear a bell sounding. A lot.")
		)
		playsound(src, angry_sound, 60)
	else
		user.visible_message(
			span_italics("\The [user] rings \a [src]."),
			span_italics("You ring \the [src]."),
			span_warning("You hear a bell sounding.")
		)
		playsound(src, normal_sound, 20)
	flick("bell_dingeth", src)


/obj/item/material/bell/glass
	default_material = MATERIAL_GLASS
	normal_sound = 'sound/items/tinkly_bell.ogg'
	angry_sound = 'sound/items/tinkly_bell_many.ogg'
