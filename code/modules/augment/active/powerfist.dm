/obj/item/powerfist
	icon_state = "powerfist"
	item_state = "powerfist"
	name = "pneumatic powerfist"
	icon = 'icons/obj/augment.dmi'
	desc = "A strong, pneumatic powerfist. Packs quite the punch with other utility uses."
	base_parry_chance = 12
	force = 5
	attack_cooldown = 1.5 * DEFAULT_WEAPON_COOLDOWN
	hitsound = 'sound/effects/bamf.ogg'
	attack_verb = list("smashed", "bludgeoned", "hammered", "battered")

	var/obj/item/tank/tank
	var/pressure_setting
	var/list/possible_pressure_amounts = list(10, 20, 30, 50)


/obj/item/powerfist/Initialize()
	. = ..()
	if (ispath(tank))
		tank = new tank (src)
	if (!pressure_setting)
		pressure_setting = possible_pressure_amounts[1]
	update_force()


/obj/item/organ/internal/augment/active/item/powerfist
	name = "pneumatic power gauntlet"
	desc = "An armoured powered gauntlet for the arm. Your very own pneumatic doom machine."
	action_button_name = "Deploy powerfist"
	icon_state = "powerfist"
	deploy_sound = 'sound/machines/suitstorage_cycledoor.ogg'
	retract_sound = 'sound/machines/suitstorage_cycledoor.ogg'
	augment_slots = AUGMENT_ARM
	item = /obj/item/powerfist
	augment_flags = AUGMENT_MECHANICAL | AUGMENT_SCANNABLE


/obj/item/powerfist/attackby(obj/item/item, mob/user)
	if (!istype(item, /obj/item/tank))
		return
	var/obj/item/tank/other = item
	if (other.tank_size > TANK_SIZE_SMALL)
		to_chat(user, span_warning("\The [other] is too big. Find a smaller tank."))
		return
	if (tank)
		to_chat(user, span_warning("\The [src] already has \a [tank] installed."))
		return
	user.visible_message(
		span_italics("\The [user] starts connecting \a [item] to \his [src]."),
		span_italics("You start connecting \the [item] to \the [src]."),
		range = 5
	)
	if (!do_after(user, 3 SECONDS, item, DO_PUBLIC_UNIQUE))
		return
	if (!user.unEquip(item, src))
		return
	user.visible_message(
		span_italics("\The [user] finishes connecting \a [item] to \his [src]."),
		span_notice("You finish connecting \the [item] to \the [src]."),
		range = 5
	)
	playsound(user, 'sound/effects/refill.ogg', 50, 1, -6)
	tank = item
	update_force()
	update_icon()


/obj/item/powerfist/proc/update_force()
	var/pressure = tank?.air_contents?.return_pressure()
	if (pressure > 210)
		force = (pressure * pressure_setting * 0.01) * (tank.volume / 425)
	else
		force = 5


/obj/item/powerfist/verb/set_pressure_verb()
	set name = "Set Powerfist Pressure"
	set desc = "Set the powerfist's tank output pressure."
	set category = "Object"
	set src in range(0)
	set_pressure()


/obj/item/powerfist/proc/set_pressure()
	var/N = input("Percentage of tank used per hit:", "[src]") as null | anything in possible_pressure_amounts
	if (isnull(N))
		return
	pressure_setting = N
	to_chat(usr, span_notice("You dial \the [src]'s pressure valve to [pressure_setting]%."))
	update_force()


/obj/item/powerfist/attack_self(mob/living/carbon/human/user)
	set_pressure()


/obj/item/powerfist/attack_hand(mob/living/user)
	if (!tank)
		to_chat(user, span_warning("There's no tank in \the [src]."))
		return
	user.visible_message(
		span_italics("\The [user] starts disconnecting \a [tank] from \his [src]."),
		span_italics("You start disconnecting \the [tank] from \the [src]."),
		range = 5
	)
	if (!do_after(user, 3 SECONDS, src, DO_PUBLIC_UNIQUE))
		return
	user.visible_message(
		span_italics("\The [user] finishes disconnecting \a [tank] from \his [src]."),
		span_notice("You finish disconnecting \the [tank] from \the [src]."),
		range = 5
	)
	user.put_in_hands(tank)
	playsound(loc, 'sound/effects/spray3.ogg', 50)
	tank = null
	update_icon()
	update_force()


/obj/item/powerfist/on_update_icon()
	..()
	if (tank)
		AddOverlays(image(icon, "powerfist_tank"))
	else
		CutOverlays("powerfist_tank")


/obj/item/powerfist/examine(mob/living/user, distance)
	. = ..()
	if (distance > 2)
		return
	. += span_notice("The valve is dialed to [pressure_setting]%.")
	if (tank)
		. += span_notice("[tank] is fitted in [src]'s tank valve.")
		. += span_notice("The tank dial reads [tank.air_contents.return_pressure()] kPa.")
	else
		. += span_notice("Nothing is attached to the tank valve!")


/obj/item/powerfist/proc/gas_loss()
	if (tank?.air_contents)
		var/lost_gas = tank.air_contents.total_moles * pressure_setting * 0.01
		tank.remove_air(lost_gas)


/obj/item/powerfist/proc/no_pressure()
	if (tank && tank.air_contents?.return_pressure() < 210)
		playsound(usr, 'sound/machines/ekg_alert.ogg', 50)
		to_chat(usr, span_warning("\The pressure dial on \the [src] flashes a warning: it's out of gas!"))
		update_force()


/obj/item/powerfist/use_before(atom/target, mob/living/user, click_parameters)
	if (user.a_intent == I_HELP || !istype(target, /obj/machinery/door/airlock))
		return FALSE

	var/obj/machinery/door/airlock/A = target

	if (A.operating)
		return FALSE

	if (A.locked)
		to_chat(user, span_warning("The airlock's bolts prevent it from being forced."))
		return TRUE

	if (tank && tank.air_contents.return_pressure() > 210 && pressure_setting > 20)
		playsound(user, 'sound/effects/bamf.ogg', pressure_setting*2, 1) //louder the more pressure is used
		gas_loss()
		no_pressure()
		if (pressure_setting > 30) //tearing open airlocks
			if (A.welded)
				A.visible_message(span_danger("\The [user] forces the fingers of \the [src] in through the welded metal, beginning to pry \the [A] open!"))
				if (do_after(user, 13 SECONDS, A, DO_DEFAULT | DO_USER_UNIQUE_ACT | DO_PUBLIC_PROGRESS) && !A.locked)
					A.welded = FALSE
					A.update_icon()
					playsound(A, 'sound/effects/meteorimpact.ogg', 100, 1)
					playsound(A, 'sound/machines/airlock_creaking.ogg', 100, 1)
					A.visible_message(span_danger("\The [user] tears \the [A] open with \a [src]!"))
					addtimer(CALLBACK(A, TYPE_PROC_REF(/obj/machinery/door/airlock, open), TRUE), 0)
					A.set_broken(TRUE)
				return TRUE
			else
				A.visible_message(span_danger("\The [user] pries the fingers of \a [src] in, beginning to force \the [A]!"))
				if ((MACHINE_IS_BROKEN(A) || !A.is_powered() || do_after(user, 10 SECONDS, A, DO_DEFAULT | DO_USER_UNIQUE_ACT | DO_PUBLIC_PROGRESS)) && !(A.operating || A.welded || A.locked))
					playsound(A, 'sound/machines/airlock_creaking.ogg', 100, 1)
					if (A.density)
						addtimer(CALLBACK(A, TYPE_PROC_REF(/obj/machinery/door/airlock, open), TRUE), 0)
						if(!MACHINE_IS_BROKEN(A) && A.is_powered())
							A.set_broken(TRUE)
						A.visible_message(span_danger("\The [user] forces \the [A] open with \a [src]!"))
					else
						addtimer(CALLBACK(A, TYPE_PROC_REF(/obj/machinery/door/airlock, close), TRUE), 0)
						if (!MACHINE_IS_BROKEN(A) && A.is_powered())
							A.set_broken(TRUE)
						A.visible_message(span_danger("\The [user] forces \the [A] closed with \a [src]!"))
				return TRUE


/obj/item/powerfist/apply_hit_effect(atom/target, mob/living/user)
	if (tank)
		gas_loss()
		no_pressure()
		if (istype(target, /mob/living))
			if (pressure_setting == 50 && tank.air_contents.return_pressure() > 210)
				var/mob/living/A = target
				A.throw_at(get_edge_target_turf(user, user.dir), pressure_setting/10, pressure_setting/10) //penultimate/ultimate settings yeets people
				user.visible_message(
					span_danger("\The [user] batters \the [A] with \a [src], sending them flying!"),
					span_warning("You batter \the [A] with \the [src], sending them flying!")
				)
	return ..()

/obj/item/powerfist/prepared
	tank = /obj/item/tank/oxygen_emergency_extended

/obj/item/organ/internal/augment/active/item/powerfist/prepared
	item = /obj/item/powerfist/prepared
