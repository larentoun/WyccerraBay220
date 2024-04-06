/mob/living/carbon/process_resist()

	//drop && roll
	if(on_fire && !buckled)
		fire_stacks -= 1.2
		Weaken(3)
		spin(32,2)
		visible_message(
			span_danger("[src] rolls on the floor, trying to put themselves out!"),
			span_notice("You stop, drop, and roll!")
			)
		sleep(30)
		if(fire_stacks <= 0)
			visible_message(
				span_danger("[src] has successfully extinguished themselves!"),
				span_notice("You extinguish yourself.")
				)
			ExtinguishMob()
		return TRUE

	if(..())
		return TRUE

	if(handcuffed)
		spawn() escape_handcuffs()

/mob/living/carbon/proc/escape_handcuffs()

	//This line represent a significant buff to grabs...
	// We don't have to check the click cooldown because /mob/living/verb/resist() has done it for us, we can simply set the delay
	setClickCooldown(100)

	if(can_break_cuffs()) //Don't want to do a lot of logic gating here.
		break_handcuffs()
		return

	var/obj/item/handcuffs/HC = handcuffed

	//A default in case you are somehow handcuffed with something that does not have a breakouttime defined.
	var/breakout_time = HC.breakout_time ? HC.breakout_time : 120 SECONDS

	var/mob/living/carbon/human/H = src
	if(istype(H) && H.gloves && istype(H.gloves,/obj/item/clothing/gloves/rig))
		breakout_time /= 2

	if(psi && psi.can_use())
		var/psi_mod = (1 - (psi.get_rank(PSI_PSYCHOKINESIS)*0.2))
		breakout_time = max(5, breakout_time * psi_mod)

	visible_message(
		span_danger("\The [src] attempts to remove \the [HC]!"),
		span_warning("You attempt to remove \the [HC] (This will take around [breakout_time/(1 SECOND)] second\s and you need to stand still)."), range = 2
		)

	var/stages = 4
	for(var/i = 1 to stages)

		if(do_after(src, breakout_time*(1/stages), do_flags = DO_DEFAULT | DO_USER_UNIQUE_ACT, incapacitation_flags = INCAPACITATION_DEFAULT & ~INCAPACITATION_RESTRAINED))
			if(!handcuffed || buckled)
				return
			to_chat(src, span_warning("You try to slip free of \the [handcuffed] ([i*100/stages]% done)."))
		else
			if(!handcuffed || buckled)
				return
			to_chat(src, span_warning("You stop trying to slip free of \the [handcuffed]."))
			return
		if(!handcuffed || buckled)
			return
	if (handcuffed.damage_health(handcuffed.get_max_health() / 2))
		visible_message(
			span_danger("\The [src] manages to remove \the [handcuffed], breaking them!"),
			span_notice("You successfully remove \the [handcuffed], breaking them!"), range = 2
			)
		QDEL_NULL(handcuffed)
		if(buckled && buckled.buckle_require_restraints)
			buckled.unbuckle_mob()
		update_inv_handcuffed()
		return
	visible_message(
		span_warning("\The [src] manages to remove \the [handcuffed]!"),
		span_notice("You successfully remove \the [handcuffed]!"), range = 2
		)
	drop_from_inventory(handcuffed)
	return

/mob/living/proc/can_break_cuffs()
	. = (psi && psi.can_use() && psi.get_rank(PSI_PSYCHOKINESIS) >= 5)

/mob/living/carbon/can_break_cuffs()
	. = ..() || (MUTATION_FERAL in mutations)

/mob/living/carbon/proc/break_handcuffs()
	visible_message(
		span_danger("[src] is trying to break \the [handcuffed]!"),
		span_warning("You attempt to break your [handcuffed.name]. (This will take around 5 seconds and you need to stand still)")
		)

	if (!do_after(src, 5 SECONDS, do_flags = DO_DEFAULT | DO_USER_UNIQUE_ACT, incapacitation_flags = INCAPACITATION_DEFAULT & ~INCAPACITATION_RESTRAINED))
		return
	if (!handcuffed || buckled)
		return

	visible_message(
		span_danger("[src] manages to break \the [handcuffed]!"),
		span_warning("You successfully break your [handcuffed.name].")
		)

	qdel(handcuffed)
	handcuffed = null
	if (buckled && buckled.buckle_require_restraints)
		buckled.unbuckle_mob()
	update_inv_handcuffed()

/mob/living/carbon/human/can_break_cuffs()
	. = ..() || species.can_shred(src,1)

/mob/living/carbon/escape_buckle()
	var/unbuckle_time
	if(src.handcuffed && istype(src.buckled, /obj/energy_net))
		var/obj/energy_net/N = src.buckled
		N.escape_net(src) //super snowflake but is literally used NOWHERE ELSE.-Luke
		return

	if(!buckled) return
	if(!restrained())
		..()
	else
		setClickCooldown(100)
		unbuckle_time = 2 MINUTES
		if(psi && psi.can_use())
			unbuckle_time = max(0, unbuckle_time - ((25 SECONDS) * psi.get_rank(PSI_PSYCHOKINESIS)))

		visible_message(
			span_danger("[src] attempts to unbuckle themself!"),
			span_warning("You attempt to unbuckle yourself. (This will take around [unbuckle_time / (1 SECOND)] second\s and you need to stand still)"), range = 2
			)

	if(unbuckle_time && buckled)
		var/stages = 2
		for(var/i = 1 to stages)
			if(!unbuckle_time || do_after(usr, unbuckle_time*(1/stages), do_flags = DO_DEFAULT | DO_USER_UNIQUE_ACT, incapacitation_flags = INCAPACITATION_DISABLED))
				if(!buckled)
					return
				to_chat(src, span_warning("You try to unbuckle yourself ([i*100/stages]% done)."))
			else
				if(!buckled)
					return
				to_chat(src, span_warning("You stop trying to unbuckle yourself."))
				return
		to_chat(src, span_notice("You successfully unbuckle yourself."))
		buckled.user_unbuckle_mob(src)
		return
