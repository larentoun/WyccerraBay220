/mob/living/carbon/human/verb/give(mob/living/target in view(1)-usr)
	set category = "IC"
	set name = "Give"

	if(incapacitated())
		return
	if(!istype(target) || target.incapacitated() || isnull(target.client))
		return

	var/obj/item/I = usr.get_active_hand()
	if(!I)
		I = usr.get_inactive_hand()
	if(!I)
		to_chat(usr, span_warning("You don't have anything in your hands to give to \the [target]."))
		return

	if(istype(I, /obj/item/grab))
		to_chat(usr, span_warning("You can't give someone a grab."))
		return

	usr.visible_message(span_notice("\The [usr] holds out \the [I] to \the [target]."), span_notice("You hold out \the [I] to \the [target], waiting for them to accept it."))

	if(alert(target,"[usr] wants to give you \a [I]. Will you accept it?",,"Yes","No") == "No")
		target.visible_message(span_notice("\The [usr] tried to hand \the [I] to \the [target], but \the [target] didn't want it."))
		return

	if(!I) return

	if(!Adjacent(target))
		to_chat(usr, span_warning("You need to stay in reaching distance while giving an object."))
		to_chat(target, span_warning("\The [usr] moved too far away."))
		return

	if (!usr.IsHolding(I))
		to_chat(usr, span_warning("You need to keep the item in your hands."))
		to_chat(target, span_warning("\The [usr] seems to have given up on passing \the [I] to you."))
		return

	if (!target.HasFreeHand())
		to_chat(target, span_warning("Your hands are full."))
		to_chat(usr, span_warning("Their hands are full."))
		return

	if(usr.unEquip(I))
		target.put_in_hands(I) // If this fails it will just end up on the floor, but that's fitting for things like dionaea.
		usr.visible_message(span_notice("\The [usr] handed \the [I] to \the [target]."), span_notice("You give \the [I] to \the [target]."))
