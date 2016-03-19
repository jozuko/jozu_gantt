function delete_holiday(delete_link, hidden_id, confirm_message) {

    if( window.confirm(confirm_message) ) {
		var holiday_row = delete_link.parentNode.parentNode;
		if (holiday_row) {
			document.getElementById(hidden_id).value = "true";
			holiday_row.style.display = "none";
		}
    }
}

function add_holiday(kind_option_labels, kind_option_values) {

	var holidays = document.getElementById('settings_holidays');
	var holiday_row = holidays.insertRow(-1);

	var holiday_kind_cell        = holiday_row.insertCell(-1);
	var holiday_month_cell       = holiday_row.insertCell(-1);
	var holiday_day_or_week_cell = holiday_row.insertCell(-1);
	var holiday_year_from        = holiday_row.insertCell(-1);
	var holiday_year_to          = holiday_row.insertCell(-1);
	var holiday_description_cell = holiday_row.insertCell(-1);
	var holiday_delete           = holiday_row.insertCell(-1);

    var date = new Date();
    var array_index = date.getTime();

	var kind_options = '';
	for (var i = 0 ; i < kind_option_labels.length ; i++) {
	  if ( i == 0 ) {
	    kind_options += '<option selected="selected"';
	  }
	  else {
	    kind_options += '<option';
	  }
	  kind_options += ' value="' + kind_option_values[i] + '">';
	  kind_options += kind_option_labels[i];
	  kind_options += '</option>';
	}

	holiday_kind_cell.innerHTML = '<input type="hidden" value="" name="holidays[' + array_index + '][id]" id="holidays_' + array_index + '_id" />'
	                            + '<input type="hidden" value="false" name="holidays[' + array_index + '][_destroy]" id="holidays_' + array_index + '__destroy" />'
	                            + '<select name="holidays[' + array_index + '][kind]" id="holidays_' + array_index + '_kind">' + kind_options + '</select>';

    holiday_month_cell.innerHTML = '<select name="holidays[' + array_index + '][month]" id="holidays_' + array_index + '_month">'
                                 + '<option selected="selected" value="1">1</option><option value="2">2</option><option value="3">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option><option value="8">8</option><option value="9">9</option><option value="10">10</option><option value="11">11</option><option value="12">12</option>'
                                 + '</select>';

    holiday_day_or_week_cell.innerHTML = '<select name="holidays[' + array_index + '][day_or_week]" id="holidays_' + array_index + '_day_or_week">'
                                       + '<option selected="selected" value="1">1</option><option value="2">2</option><option value="3">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option><option value="8">8</option><option value="9">9</option><option value="10">10</option><option value="11">11</option><option value="12">12</option><option value="14">14</option><option value="15">15</option><option value="16">16</option><option value="17">17</option><option value="18">18</option><option value="19">19</option><option value="20">20</option><option value="21">21</option><option value="22">22</option><option value="24">24</option><option value="25">25</option><option value="26">26</option><option value="27">27</option><option value="28">28</option><option value="29">29</option><option value="30">30</option><option value="31">31</option>'
                                       + '</select>';

    holiday_year_from.innerHTML = '<input size="4" type="text" value="' + date.getFullYear() + '" name="holidays[' + array_index + '][year_from]" id="holidays_' + array_index + '_year_from" />';

    holiday_year_to.innerHTML = '<input size="4" type="text" value="9999" name="holidays[' + array_index + '][year_to]" id="holidays_' + array_index + '_year_to" />';

    holiday_description_cell.innerHTML = '<input type="text" value="" name="holidays[' + array_index + '][description]" id="holidays_' + array_index + '_description" />';

    holiday_delete.innerHTML = '<a href="#" onclick="delete_holiday(this, &quot;holidays_' + array_index + '__destroy&quot;, &quot;本当に削除しますか？&quot;); return false;" class="icon icon-del">削除</a>';
}

function add_corporate_holiday() {

	var holidays = document.getElementById('settings_corporate_holidays');
	var holiday_row = holidays.insertRow(-1);

	var holiday_month_cell       = holiday_row.insertCell(-1);
	var holiday_day_or_week_cell = holiday_row.insertCell(-1);
	var holiday_year_from        = holiday_row.insertCell(-1);
	var holiday_year_to          = holiday_row.insertCell(-1);
	var holiday_description_cell = holiday_row.insertCell(-1);
	var holiday_delete           = holiday_row.insertCell(-1);

    var date = new Date();
    var array_index = date.getTime();

	holiday_month_cell.innerHTML = '<input type="hidden" value="" name="holidays[' + array_index + '][id]" id="holidays_' + array_index + '_id" />'
	                             + '<input type="hidden" value="false" name="holidays[' + array_index + '][_destroy]" id="holidays_' + array_index + '__destroy" />'
	                             + '<input type="hidden" value="corporate" name="holidays[' + array_index + '][kind]" id="holidays_' + array_index + '_kind" />'
                                 + '<select name="holidays[' + array_index + '][month]" id="holidays_' + array_index + '_month">'
                                 + '<option selected="selected" value="1">1</option><option value="2">2</option><option value="3">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option><option value="8">8</option><option value="9">9</option><option value="10">10</option><option value="11">11</option><option value="12">12</option>'
                                 + '</select>';

    holiday_day_or_week_cell.innerHTML = '<select name="holidays[' + array_index + '][day_or_week]" id="holidays_' + array_index + '_day_or_week">'
                                       + '<option selected="selected" value="1">1</option><option value="2">2</option><option value="3">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option><option value="8">8</option><option value="9">9</option><option value="10">10</option><option value="11">11</option><option value="12">12</option><option value="14">14</option><option value="15">15</option><option value="16">16</option><option value="17">17</option><option value="18">18</option><option value="19">19</option><option value="20">20</option><option value="21">21</option><option value="22">22</option><option value="24">24</option><option value="25">25</option><option value="26">26</option><option value="27">27</option><option value="28">28</option><option value="29">29</option><option value="30">30</option><option value="31">31</option>'
                                       + '</select>';

    holiday_year_from.innerHTML = '<input size="4" type="text" value="' + date.getFullYear() + '" name="holidays[' + array_index + '][year_from]" id="holidays_' + array_index + '_year_from" />';

    holiday_year_to.innerHTML = '<input size="4" type="text" value="9999" name="holidays[' + array_index + '][year_to]" id="holidays_' + array_index + '_year_to" />';

    holiday_description_cell.innerHTML = '<input type="text" value="" name="holidays[' + array_index + '][description]" id="holidays_' + array_index + '_description" />';

    holiday_delete.innerHTML = '<a href="#" onclick="delete_holiday(this, &quot;holidays_' + array_index + '__destroy&quot;, &quot;本当に削除しますか？&quot;); return false;" class="icon icon-del">削除</a>';
}
