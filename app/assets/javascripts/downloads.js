var StartDateInput = document.querySelector(".start_date_input");
var EndDateInput = document.querySelector(".end_date_input");

function ChangeDates(){
    console.log("Date parameter changes ");
    for(var i = 0; i < DownloadLinks.length; ++i){
        var Link = new URL(DownloadLinks[i].href);
        var DownloadLinkParameters = new URLSearchParams(Link.search);
        DownloadLinkParameters.set("start_date", StartDateInput.value);
        DownloadLinkParameters.set("end_date", EndDateInput.value);
        Link.search = DownloadLinkParameters.toString();
        DownloadLinks[i].href = Link.toString();
    }
}

StartDateInput.addEventListener("change", ChangeDates);

EndDateInput.addEventListener("change", ChangeDates);

var DownloadLinks = document.querySelectorAll(".download_link")