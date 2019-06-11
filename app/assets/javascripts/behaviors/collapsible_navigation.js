var NavigationSectionTitles = Array.prototype.slice.call(document.querySelectorAll(".collapsible_navigation_toggle"));
var ShowOnLoad = [NavigationSectionTitles[0], 
                  NavigationSectionTitles[0+NavigationSectionTitles.length/2]];

var Uncollapsed = [0, 0 + NavigationSectionTitles.length/2];

var SavedState = localStorage.getItem("uncollapsed");
var SavedLength = localStorage.getItem("sidebarnav_length")

if(SavedState == null || !SavedLength || parseInt(SavedLength) != NavigationSectionTitles.length){
    localStorage.setItem("uncollapsed", Uncollapsed.join());
    localStorage.setItem("sidebarnav_length", NavigationSectionTitles.length);
}
else{
    Uncollapsed = SavedState.split(',').map(function(_Index) {
        return parseInt(_Index);
    });
}

function ApplyCollapsedStates(){
    var Index = 0;

    NavigationSectionTitles.forEach(function(_Title){
        if(Uncollapsed.includes(Index)){
            _Title.parentElement.children[1].classList.remove("hidden") 
            _Title.children[0].children[0].classList.remove("collapsible__indicator_collapsed")
        }
        else{
            _Title.parentElement.children[1].classList.add("hidden")
            _Title.children[0].children[0].classList.add("collapsible__indicator_collapsed")
        }
        ++Index;
    });
}

ApplyCollapsedStates();

NavigationSectionTitles.forEach(function(_Title){
    _Title.addEventListener("click", function(){
        var Index = NavigationSectionTitles.indexOf(_Title);
        var NextIndex = (Index + NavigationSectionTitles.length/2) % NavigationSectionTitles.length;

        if(Uncollapsed.includes(Index)){
            Uncollapsed.splice(Uncollapsed.indexOf(Index), 1);
            Uncollapsed.splice(Uncollapsed.indexOf(NextIndex), 1);
        }
        else{
            Uncollapsed.push(Index);
            Uncollapsed.push(NextIndex);
        }

        localStorage.setItem("uncollapsed", Uncollapsed.join());

        ApplyCollapsedStates();
    });
})