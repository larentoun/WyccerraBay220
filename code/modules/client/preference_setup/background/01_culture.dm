#define GET_ALLOWED_VALUES(write_to, check_key) \
	var/datum/species/S = all_species[pref.species]; \
	if(!S) { \
		write_to = list(); \
	} else if(S.force_cultural_info[check_key]) { \
		write_to = list(S.force_cultural_info[check_key] = TRUE); \
	} else { \
		write_to = list(); \
		for(var/cul in S.available_cultural_info[check_key]) { \
			write_to[cul] = TRUE; \
		} \
	}

/datum/preferences
	var/list/cultural_info = list()

/datum/category_item/player_setup_item/background/culture
	name = "Culture"
	sort_order = 1
	var/list/hidden
	var/list/expanded
	var/list/tokens = ALL_CULTURAL_TAGS

/datum/category_item/player_setup_item/background/culture/New()
	hidden = list()
	expanded = list()
	for(var/token in tokens)
		hidden[token] = TRUE
		expanded[token] = FALSE
	..()

/datum/category_item/player_setup_item/background/culture/sanitize_character()
	if(!islist(pref.cultural_info))
		pref.cultural_info = list()
	for(var/token in tokens)
		var/list/_cultures
		GET_ALLOWED_VALUES(_cultures, token)
		if(!LAZYLEN(_cultures))
			pref.cultural_info[token] = GLOB.using_map.default_cultural_info[token]
		else
			var/current_value = pref.cultural_info[token]
			if(!current_value|| !_cultures[current_value])
				pref.cultural_info[token] = _cultures[1]

/datum/category_item/player_setup_item/background/culture/load_character(datum/pref_record_reader/R)
	for(var/token in tokens)
		var/load_val
		load_val = R.read(token)
		pref.cultural_info[token] = load_val

/datum/category_item/player_setup_item/background/culture/save_character(datum/pref_record_writer/W)
	for(var/token in tokens)
		W.write(token, pref.cultural_info[token])

/datum/category_item/player_setup_item/background/culture/content()
	. = list()
	for(var/token in tokens)
		var/singleton/cultural_info/culture = SSculture.get_culture(pref.cultural_info[token])
		// [SIERRA-EDIT] - EXPANDED_CULTURE_DESCRIPTOR - Сокращение html-строки для нормальной работы переопределения get_description; перевод буков
		// var/title = "<a href='?src=\ref[src];expand_options_[token]=1'>[tokens[token]]</a><b>- </b>[pref.cultural_info[token]]" // SIERRA-EDIT - ORIGINAL
		// var/append_text = "<a href='?src=\ref[src];toggle_verbose_[token]=1'>[hidden[token] ? "Expand" : "Collapse"]</a>" // SIERRA-EDIT - ORIGINAL
		var/title = "<a href='?src=\ref[src];expand_options_[token]=1'>[tokens[token]]</a><b>- </b>"
		var/append_text = "<a href='?src=\ref[src];toggle_verbose_[token]=1'>[hidden[token] ? "Расширить" : "Скрыть"]</a>"
		// [SIERRA-EDIT]
		. += culture.get_description(title, append_text, verbose = !hidden[token])
		if (expanded[token])
			var/list/valid_values
			GET_ALLOWED_VALUES(valid_values, token)
			if (!hidden[token])
				. += "<br>"
			. += "<table width=100%><tr><td colspan=3>"
			for (var/V in valid_values)
				// this is yucky but we need to do it because, right now, the culture subsystem references singletons by their string names
				// html_encode() doesn't properly sanitize + symbols, otherwise we could just use that
				// instead, we manually rip out the plus symbol and then replace it on OnTopic
				var/sanitized_value = html_encode(replacetext(V, "+", "PLUS"))

				// [SIERRA-EDIT] - EXPANDED_CULTURE_DESCRIPTOR - Изменение схемы получения названия культуры, чтобы поддерживать возможность их перевода без переработки всей сабсистемы культур
				// if (pref.cultural_info[token] == V) // SIERRA-EDIT - ORIGINAL
				// 	. += "[span_linkon("[V]")] " // SIERRA-EDIT - ORIGINAL
				// else // SIERRA-EDIT - ORIGINAL
				// 	. += "<a href='?src=\ref[src];set_token_entry_[token]=[sanitized_value]'>[V]</a> " // SIERRA-EDIT - ORIGINAL
				var/singleton/cultural_info/VCulture = SSculture.get_culture(V)
				if(VCulture)
					if (pref.cultural_info[token] == V)
						. += "[span_linkon("[VCulture.get_nickname()]")] "
					else
						. += "<a href='?src=\ref[src];set_token_entry_[token]=[sanitized_value]'>[VCulture.get_nickname()]</a> "
				// [SIERRA-EDIT]
			. += "</table>"
		. += "<hr>"
	. = jointext(.,null)

/datum/category_item/player_setup_item/background/culture/OnTopic(href,list/href_list, mob/user)

	for(var/token in tokens)

		if(href_list["toggle_verbose_[token]"])
			hidden[token] = !hidden[token]
			return TOPIC_REFRESH

		if(href_list["expand_options_[token]"])
			expanded[token] = !expanded[token]
			return TOPIC_REFRESH

		var/new_token = href_list["set_token_entry_[token]"]
		if (!isnull(new_token))
			pref.cultural_info[token] = html_decode(replacetext(new_token, "PLUS", "+"))
			return TOPIC_REFRESH

	. = ..()

#undef GET_ALLOWED_VALUES
