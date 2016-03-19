
function showColumnAssignTo() {
  var extra_colmn = document.getElementById('extra_column_assign_to');
  
  if (extra_colmn) {
    if ($("#show_extra_column_assign_to").prop('checked')) {
      extra_colmn.style.display = "";
    }
    else {
      extra_colmn.style.display = "none";
    }
  }
}

function showExtraColumn() {
  showColumnAssignTo();
}

