var NavigationSectionTitles = document.querySelectorAll(".collapsible_navigation_toggle")
var ShowOnLoad = [NavigationSectionTitles[0], 
                  NavigationSectionTitles[1], 
                  NavigationSectionTitles[5], 
                  NavigationSectionTitles[6]]

NavigationSectionTitles.forEach(function(_Title){
    if(ShowOnLoad.indexOf(_Title) == -1){
        _Title.children[0].children[0].classList.add("collapsible__indicator_collapsed");
        _Title.parentElement.children[1].classList.add("hidden") 
    }
    
    _Title.addEventListener("click", function(){
        if(_Title.parentElement.children[1].classList.contains("hidden")){
            _Title.parentElement.children[1].classList.remove("hidden") 
            _Title.children[0].children[0].classList.remove("collapsible__indicator_collapsed")
        }
        else{
            _Title.parentElement.children[1].classList.add("hidden")
            _Title.children[0].children[0].classList.add("collapsible__indicator_collapsed")
        }
    });
})