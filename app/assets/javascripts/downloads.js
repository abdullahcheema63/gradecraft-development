var StartDateInput = document.querySelector(".start_date_input");
var EndDateInput = document.querySelector(".end_date_input");
var DownloadLinks = Array.prototype.slice.call(document.querySelectorAll(".download_link"));

var FieldSelectionDropdowns = Array.prototype.slice.call(document.querySelectorAll(".select_field"));

function UpdateParameterInLink(_Link, _Key, _Value){
    var Link = new URL(_Link);
    var DownloadLinkParameters = new URLSearchParams(Link.search);
    DownloadLinkParameters.set(_Key, _Value);
    Link.search = DownloadLinkParameters.toString();
    return Link.toString();
}

var FinalGradesDropdowns = document.querySelectorAll(".for_final_grades")

FinalGradesDropdowns.forEach(function(_Dropdown){
    _Dropdown.addEventListener("change", function(){
        var FinalDropdownMobileLink = DownloadLinks[0];
        var FinalDropdownDesktopLink = DownloadLinks[DownloadLinks.length/2];
    
        FinalDropdownMobileLink.href = UpdateParameterInLink(FinalDropdownMobileLink.href, 
                                                             "field", 
                                                             _Dropdown.value);
    
        FinalDropdownDesktopLink.href = UpdateParameterInLink(FinalDropdownDesktopLink.href, 
                                                             "field", 
                                                             _Dropdown.value);
    
        console.log(_Dropdown);
    });
});

var AssignmentSubmissionsDropdowns = document.querySelectorAll(".for_assignment_submissions")

AssignmentSubmissionsDropdowns.forEach(function(_Dropdown){
    _Dropdown.addEventListener("change", function(){
        var FinalDropdownMobileLink = DownloadLinks[3];
        var FinalDropdownDesktopLink = DownloadLinks[3 + DownloadLinks.length/2];
    
        FinalDropdownMobileLink.href = UpdateParameterInLink(FinalDropdownMobileLink.href, 
                                                             "field", 
                                                             _Dropdown.value);
    
        FinalDropdownDesktopLink.href = UpdateParameterInLink(FinalDropdownDesktopLink.href, 
                                                             "field", 
                                                             _Dropdown.value);
    
        console.log(_Dropdown);
    });
});

/*
for(var i = 0; i < FieldSelectionDropdowns.length/2; ++i){
    var DropdownMobile = FieldSelectionDropdowns[i];
    var DropdownDesktop = FieldSelectionDropdowns[i + FieldSelectionDropdowns.length/2];
    
    FieldSelectionDropdowns[i].addEventListener("change", function(){
        var Link = new URL(DownloadLinks[i].href);
        var DownloadLinkParameters = new URLSearchParams(Link.search);
        DownloadLinkParameters.set("field", DropdownMobile.value);
        Link.search = DownloadLinkParameters.toString();
        console.log(DownloadLinks[i]);
        console.log(DownloadLinks[i + DownloadLinks.length/2]);
        DownloadLinks[i].href = Link.toString();
        DownloadLinks[i + DownloadLinks.length/2].href = Link.toString();
        console.log(i);
    });

    FieldSelectionDropdowns[i + FieldSelectionDropdowns.length/2].addEventListener("change", function(){
        var Link = new URL(DownloadLinks[i].href);
        var DownloadLinkParameters = new URLSearchParams(Link.search);
        DownloadLinkParameters.set("field", DropdownDesktop.value);
        Link.search = DownloadLinkParameters.toString();
        DownloadLinks[i].href = Link.toString();
        DownloadLinks[i + DownloadLinks.length/2].href = Link.toString()
        
        console.log(i);
    });
}

FieldSelectionDropdowns.forEach(function(_Dropdown){
    _Dropdown.addEventListener("change", function(){
        var Index = FieldSelectionDropdowns.indexOf(_Dropdown);
        var DownloadLink = DownloadLinks[Index];
        console.log(DownloadLink);
        DownloadLink.href = UpdateParameterInLink(DownloadLink.href, "field", _Dropdown.value);
    })
});*/

function ChangeDates() {
    console.log("Date parameter changes ");
    for (var i = 0; i < DownloadLinks.length; ++i) {
        var Link = new URL(DownloadLinks[i].href);
        var DownloadLinkParameters = new URLSearchParams(Link.search);
        if(StartDateInput.value.length) DownloadLinkParameters.set("start_date", StartDateInput.value);
        if(EndDateInput.value.length) DownloadLinkParameters.set("end_date", EndDateInput.value);
        Link.search = DownloadLinkParameters.toString();
        DownloadLinks[i].href = Link.toString();
    }
}

StartDateInput.addEventListener("change", ChangeDates);

EndDateInput.addEventListener("change", ChangeDates);
