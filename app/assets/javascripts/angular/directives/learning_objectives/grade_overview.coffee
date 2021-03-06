@gradecraft.directive 'learningObjectivesGradeOverview', ['LearningObjectivesService', 'GradeService', '$q', '$sce',
(LearningObjectivesService, GradeService, $q, $sce) ->
  LearningObjectivesGradeOverviewCtrl = [() ->
    vm = this
    vm.loading = true
    vm.groupedObjectives = {}

    vm.termFor = (term) ->
      LearningObjectivesService.termFor(term)

    vm.levelsFor = (objective) ->
      LearningObjectivesService.levels(objective)

    vm.overallProgress = (objectiveId) ->
      LearningObjectivesService.overallProgress(objectiveId)

    vm.levelSelected = (objectiveId, levelId) ->
      outcome = vm.observedOutcomeFor(objectiveId)
      return false if !outcome?
      outcome.objective_level_id == levelId

    vm.observedOutcomeFor = (objectiveId) ->
      cumulativeOutcome = LearningObjectivesService.cumulativeOutcomeForStudent(objectiveId, @studentId)
      return null if !cumulativeOutcome?
      LearningObjectivesService.observedOutcomesFor(cumulativeOutcome.id, "Grade", @gradeId)

    vm.statusFor = (objectiveId) ->
      LearningObjectivesService.statusFor(objectiveId)

    vm.sanitize = (html) ->
      $sce.trustAsHtml(html)

    services(@assignmentId).then(() ->
      vm.loading = false
      vm.groupedObjectives = _.groupBy(LearningObjectivesService.objectives(), "category_name")
    )
  ]

  services = (assignmentId) ->
    promises = [
      LearningObjectivesService.getArticles("objectives", { assignment_id: assignmentId }),
      LearningObjectivesService.getOutcomesForAssignment(assignmentId)
    ]
    $q.all(promises)

  {
    scope:
      assignmentId: '@'
      gradeId: '@'
      studentId: '@'
    bindToController: true
    controller: LearningObjectivesGradeOverviewCtrl
    controllerAs: 'loGradeOverviewCtrl'
    templateUrl: 'learning_objectives/grade_overview.html'
  }
]
