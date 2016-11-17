@gradecraft.controller 'GradeCtrl', ['$scope', 'AssignmentScoreLevel', 'AssignmentService', 'GradeService', ($scope, AssignmentScoreLevel, AssignmentService, GradeService) ->

  $scope.grade = GradeService.grade
  $scope.assignment = AssignmentService.assignments[0]

  $scope.init = (initData, assignmentId, reciptientType, reciptientId)->
    AssignmentService.getAssignment(assignmentId)
    GradeService.getGrade($scope.assignment, reciptientType, reciptientId)

    # establish and populate all necessary collections for UI
    $scope.populateCollections(initData.assignment_score_levels)

  $scope.services = (assignmentId)->
    promises = []
    return $q.all(promises)

  $scope.toggleCustomValue = ()->
    GradeService.toggleCustomValue()
  $scope.enableCustomValue = ()->
    GradeService.enableCustomValue()
  $scope.enableScoreLevels = ()->
    GradeService.enableScoreLevels()
  $scope.justUpdated = ()->
    GradeService.justUpdated()
  $scope.timeSinceUpdate = ()->
    GradeService.timeSinceUpdate()
  $scope.updateGrade = ()->
    GradeService.updateGrade()

  # add initial score levels
  $scope.populateCollections = (assignmentScoreLevels)->
    $scope.assignmentScoreLevels = []

    unless assignmentScoreLevels.length == 0
      $scope.addAssignmentScoreLevels(assignmentScoreLevels)

  # add assignment score level objects if they exist
  $scope.addAssignmentScoreLevels = (assignmentScoreLevels)->
    angular.forEach(assignmentScoreLevels, (scoreLevel, index)->
      scoreLevelPrototype = new AssignmentScoreLevel(scoreLevel, $scope)
      $scope.assignmentScoreLevels.push scoreLevelPrototype
    )

  $scope.modelOptions = {
    updateOn: 'default blur',
    debounce: {
      default: 1800,
      blur: 0
    }
  }

  $scope.froalaOptions = {
    inlineMode: false,
    heightMin: 200,
    toolbarButtons: [
      'fullscreen', 'bold', 'italic', 'underline', 'strikeThrough',
      'fontFamily', 'fontSize', 'color', 'sep', 'blockStyle', 'emoticons',
      'insertTable', 'sep', 'formatBlock', 'align', 'insertOrderedList',
      'outdent', 'indent', 'insertHorizontalRule', 'insertLink', 'undo', 'redo',
      'clearFormatting', 'selectAll', 'html'
    ]
  }
]
