var StartDateInputs = document.querySelectorAll(".start_date_input");
var EndDateInputs = document.querySelectorAll(".end_date_input");
var AssignmentSubmissionsDownloadLinks = document.querySelectorAll(".assignment_submissions_link");
var AssignmentSubmissionsDropdowns = document.querySelectorAll(".for_assignment_submissions")

var SelectedStartDate = localStorage.getItem("start_date");
var SelectedEndDate = localStorage.getItem("end_date");
var SelectedField = localStorage.getItem("selected_field");

function UpdateParameterInLink(_Link, _Key, _Value){
    var Link = new URL(_Link);
    var DownloadLinkParameters = new URLSearchParams(Link.search);
    DownloadLinkParameters.set(_Key, _Value);
    Link.search = DownloadLinkParameters.toString();
    return Link.toString();
}

AssignmentSubmissionsDropdowns.forEach(function(_Dropdown){
    if(SelectedField != null){
        _Dropdown.value = SelectedField;
    }

    
    _Dropdown.addEventListener("change", function(){
        localStorage.setItem("selected_field", _Dropdown.value);
        AssignmentSubmissionsDownloadLinks.forEach(function(_Link){
            _Link.href = UpdateParameterInLink(_Link.href, "field", _Dropdown.value);
        });
    });
});

StartDateInputs.forEach(function(_Input){
    if(SelectedStartDate != null){
        _Input.value = SelectedStartDate;
    }

    var MinimumStartDate = Date.new(EndDateInputs[0].value);
    MinimumStartDate.setDate(MinimumStartDate.getDate() - 90);

    _Input.setAttribute("min", StartDate.toISOString().split("T")[0])

    _Input.addEventListener("change", function(){
        localStorage.setItem("start_date", _Input.value);
        AssignmentSubmissionsDownloadLinks.forEach(function(_Link){
            _Link.href = UpdateParameterInLink(_Link.href, "start_date", _Input.value);
        });
    });
});

EndDateInputs.forEach(function(_Input){
    if(SelectedEndDate != null){
        _Input.value = SelectedEndDate;
    }

    _Input.setAttribute("max", Date.today().toISOString().split("T")[0])

    _Input.addEventListener("change", function(){
        localStorage.setItem("end_date", _Input.value);
        AssignmentSubmissionsDownloadLinks.forEach(function(_Link){
            _Link.href = UpdateParameterInLink(_Link.href, "end_date", _Input.value);
        });
        var EndDate = _Input.value;

        StartDateInputs.forEach(function(_Input){

            var MinimumStartDate = new Date(EndDate);
            console.log(MinimumStartDate.toISOString().split("T")[0])
            MinimumStartDate.setDate(MinimumStartDate.getDate() - 90);
            _Input.setAttribute("min", MinimumStartDate.toISOString().split("T")[0])
        })
    });
});
