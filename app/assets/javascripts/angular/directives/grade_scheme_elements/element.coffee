# Renders a single grade scheme element in the grade scheme element mass edit form
# Note: This directive can exist only as a child of the gradeSchemeElementsMassEditForm
@gradecraft.directive 'gradeSchemeElement',
['GradeSchemeElementsService', 'DebounceQueue', '$timeout', (GradeSchemeElementsService, DebounceQueue, $timeout) ->
  {
    scope:
      gradeSchemeElement: '='
      index: '@'
    require: '^^gradeSchemeElementsMassEditForm'
    templateUrl: 'grade_scheme_elements/element.html'
    restrict: 'E'
    link: (scope, element, attrs, gseForm) ->
      _validateElements = () ->
        GradeSchemeElementsService.validateElements()
        gseForm.updateFormValidity()

      _clearAlert = () ->
        $timeout(() ->
          scope.status = null
        , 3000)

      _save = (scope, showAlert) ->
        scope.status = 'saving'
        GradeSchemeElementsService.postGradeSchemeElements(null, true, showAlert).then(() ->
          scope.status = 'saved'
        ).finally(() ->
          _clearAlert()
        )

      scope.status = undefined

      scope.addElement = () ->
        GradeSchemeElementsService.addElement(@gradeSchemeElement)

      scope.removeElement = () ->
        GradeSchemeElementsService.removeElement(@gradeSchemeElement)
        scope.persistChanges(true) if @gradeSchemeElement.id?

      scope.persistChanges = (isRemoval=false) ->
        _validateElements()
        return if gseForm.gradeSchemeElementsForm.$invalid

        DebounceQueue.addEvent(
          'gradeSchemeElement', 'saveChanges', _save, [scope, isRemoval], 1500
        )
  }
]
