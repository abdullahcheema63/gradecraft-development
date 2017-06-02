# Main entry point for mass editing grade scheme elements for a course
# Renders the appropriate form
@gradecraft.directive 'gradeSchemeElementsMassEditForm',
['GradeSchemeElementsService', (GradeSchemeElementsService) ->
  GradeSchemeElementsCtrl = [() ->
    vm = this

    vm.loading = true
    vm.gradeSchemeElements = null

    # Add first element
    vm.addElement = () ->
      GradeSchemeElementsService.addElement()

    vm.deleteGradeSchemeElements = () ->
      if confirm "Are you sure you want to delete all grade scheme elements?"
        GradeSchemeElementsService.deleteGradeSchemeElements('/grade_scheme_elements/')

    # For manually triggering form validation by child directives
    vm.updateFormValidity = () ->
      _.each(vm.gradeSchemeElements, (element, index) ->
        if vm.gradeSchemeElementsForm["point_threshold_#{index}"]?
          vm.gradeSchemeElementsForm["point_threshold_#{index}"].$setValidity('validPointThreshold', !element.validationError?)
      )

    GradeSchemeElementsService.getGradeSchemeElements().then(() ->
      vm.loading = false
      vm.gradeSchemeElements = GradeSchemeElementsService.gradeSchemeElements
    )
  ]

  {
    bindToController: true
    controller: GradeSchemeElementsCtrl
    controllerAs: 'vm'
    restrict: 'EA'
    templateUrl: 'grade_scheme_elements/main.html'
  }
]
