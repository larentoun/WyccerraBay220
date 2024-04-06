/obj/item/material/stick
	name = "stick"
	desc = "You feel the urge to poke someone with this."
	icon = 'icons/obj/weapons/melee_physical.dmi'
	icon_state = "stick"
	item_state = "stickmat"
	max_force = 10
	force_multiplier = 0.1
	thrown_force_multiplier = 0.1
	w_class = ITEM_SIZE_NORMAL
	default_material = MATERIAL_WOOD
	attack_verb = list("poked", "jabbed")


/obj/item/material/stick/attack_self(mob/user as mob)
	user.visible_message(span_warning("\The [user] snaps [src]."), span_warning("You snap [src]."))
	shatter(0)


/obj/item/material/stick/attackby(obj/item/W as obj, mob/user as mob)
	if(W.sharp && W.edge && !sharp)
		user.visible_message(span_warning("[user] sharpens [src] with [W]."), span_warning("You sharpen [src] using [W]."))
		sharp = TRUE
		SetName("sharpened " + name)
		update_force()
	return ..()


/obj/item/material/stick/use_after(mob/M, mob/user)
	if(istype(M) && user != M && user.a_intent == I_HELP)
		user.visible_message(span_notice("[user] pokes [M] with [src]."), span_notice("You poke [M] with [src]."))
		user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		user.do_attack_animation(M)
		return TRUE
