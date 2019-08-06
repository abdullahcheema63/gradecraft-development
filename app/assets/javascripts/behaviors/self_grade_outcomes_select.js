//Selectively disables the "Submit" button for student logged assignments, if the
//assignment has outcome levels and no outcome level is selected.

var SelfGradeOutcomesSelect = document.querySelector("select");
var SelfGradeOutcomesButton = document.querySelector(".self_grade_outcomes_button");

if(SelfGradeOutcomesSelect && SelfGradeOutcomesSelect){
    SelfGradeOutcomesSelect.addEventListener("change", function(){
        if(SelfGradeOutcomesSelect.selectedIndex == 0)
            SelfGradeOutcomesButton.disabled = true;

        else
            SelfGradeOutcomesButton.disabled = false;
    });
}