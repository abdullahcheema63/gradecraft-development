var StartDateInputs = document.querySelectorAll(".start_date_input");
var EndDateInputs = document.querySelectorAll(".end_date_input");
var AssignmentSubmissionsDownloadLinks = document.querySelectorAll(".assignment_submissions_link");
var AssignmentSubmissionsDropdowns = document.querySelectorAll(".for_assignment_submissions")

function UpdateParameterInLink(_Link, _Key, _Value){
    var Link = new URL(_Link);
    var DownloadLinkParameters = new URLSearchParams(Link.search);
    DownloadLinkParameters.set(_Key, _Value);
    Link.search = DownloadLinkParameters.toString();
    return Link.toString();
}

AssignmentSubmissionsDropdowns.forEach(function(_Dropdown){
    _Dropdown.addEventListener("change", function(){
        AssignmentSubmissionsDownloadLinks.forEach(function(_Link){
            _Link.href = UpdateParameterInLink(_Link.href, "field", _Dropdown.value);
        });
    });
});

StartDateInputs.forEach(function(_Input){
    _Input.addEventListener("change", function(){
        AssignmentSubmissionsDownloadLinks.forEach(function(_Link){
            _Link.href = UpdateParameterInLink(_Link.href, "start_date", _Input.value);
        });
    });
});

EndDateInputs.forEach(function(_Input){
    _Input.addEventListener("change", function(){
        AssignmentSubmissionsDownloadLinks.forEach(function(_Link){
            _Link.href = UpdateParameterInLink(_Link.href, "end_date", _Input.value);
        });
    });
});
