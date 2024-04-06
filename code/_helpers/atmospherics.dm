/obj/proc/analyze_gases(obj/A, mob/user, mode)
	user.visible_message(span_notice("\The [user] has used \an [src] on \the [A]."))
	A.add_fingerprint(user)

	var/air_contents = A.return_air()
	if(!air_contents)
		to_chat(user, span_warning("Your [src] flashes a red light as it fails to analyze \the [A]."))
		return 0

	var/list/result = atmosanalyzer_scan(A, air_contents, mode)
	print_atmos_analysis(user, result)
	return 1

/proc/print_atmos_analysis(user, list/result)
	to_chat(user, span_notice("[result]"))
