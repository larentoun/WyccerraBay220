/datum/component/codex
	var/static/list/codex_entries
	var/selected_entry

/datum/component/codex/Initialize(datum/codex_entry/override_entry)
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE
	if(!length(codex_entries))
		for(var/thing as anything in SScodex.index_file)
			var/list/codex_entry = list()
			var/datum/codex_entry/entry = SScodex.index_file[thing]
			codex_entry["name"] = entry.display_name
			codex_entry["lore"] = entry.lore_text
			codex_entry["mechanics"] = entry.mechanics_text
			codex_entry["antag"] = entry.antag_text
			codex_entries += list(codex_entry)
	if(istype(override_entry))
		selected_entry = override_entry.display_name
	tgui_interact(parent)

/datum/component/codex/tgui_state(mob/user)
	return GLOB.interactive_state

/datum/component/codex/tgui_interact(mob/user, datum/tgui/ui, datum/tgui/parent_ui, custom_state)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Codex")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/component/codex/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	if(..())
		return TRUE
	. = TRUE
	switch(action)
		if("newEntry")
			selected_entry = params["newEntry"]

/datum/component/codex/tgui_static_data(mob/user)
	var/list/data = list()

	data["codexEntries"] = codex_entries

	return data

/datum/component/codex/tgui_data(mob/user, datum/tgui/ui, datum/tgui_state/state)
	var/list/data = list()

	data["isAntagonist"] = player_is_antag(user.mind) ? TRUE : FALSE
	data["selectedEntry"] = selected_entry ? selected_entry : null

	return data
