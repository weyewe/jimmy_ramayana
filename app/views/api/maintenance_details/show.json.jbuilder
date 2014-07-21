
json.success true 
json.total @total
json.maintenance_details @objects do |object|
	json.id 								object.id  
	json.maintenance_id											object.maintenance_id
	json.maintenance_code										object.maintenance.code 
	
	
	json.component_id											object.component_id
	json.component_name									object.component.name
	
							   
	
	json.diagnosis						object.diagnosis
	json.diagnosis_case				object.diagnosis_case
	
	if object.diagnosis_case == DIAGNOSIS_CASE[:all_ok]
		json.diagnosis_case_text  "OK"
	elsif object.diagnosis_case == DIAGNOSIS_CASE[:require_fix]
		json.diagnosis_case_text  "Butuh Perbaikan"
	elsif object.diagnosis_case == DIAGNOSIS_CASE[:require_replacement]
		json.diagnosis_case_text "Butuh Penggantian"
	else
		json.diagnosis_case_text ""
	end
	
	json.solution						object.solution
	json.solution_case				object.solution_case
	
 
	
	
	if object.solution_case == SOLUTION_CASE[:pending]
		json.solution_case_text  "Belum Selesai"
	elsif object.solution_case == SOLUTION_CASE[:solved]
		json.solution_case_text  "Selesai"
	else
		json.solution_case_text ""
	end
	 
	json.is_replacement_required						object.is_replacement_required
	 
	 
	json.replacement_item_id											object.replacement_item_id
	
	if object.replacement_item_id.present?
		json.replacement_item_sku											object.replacement_item.sku
	else
		json.replacement_item_sku 				""
	end

end


