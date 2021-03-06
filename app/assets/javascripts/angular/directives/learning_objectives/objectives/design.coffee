# Main entry point for configuring the learning objectives and learning objective
# categories for the current course
@gradecraft.directive 'learningObjectivesObjectivesDesign', ['LearningObjectivesService', "AssignmentService", '$q', (LearningObjectivesService, AssignmentService, $q) ->
  LearningObjectivesObjectivesDesignCtrl = [() ->
    vm = this

    vm.loading = true
    vm.objectives = LearningObjectivesService.objectives
    vm.lastUpdated = LearningObjectivesService.lastUpdated
    vm.addObjective = LearningObjectivesService.addObjective

    vm.termFor = (term) -> LearningObjectivesService.termFor(term)
    vm.persistChanges = () -> LearningObjectivesService.runAllEvents(@indexRoute)

    vm.hasSavedObjectives = () ->
      return false if !_.some(@objectives())
      _.some(@objectives(), (o) -> o.id?)

    services(@objectiveId, @loadExisting).then(() -> vm.loading = false)

    LearningObjectivesService.addObjective(@categoryId) if !@objectiveId && !@loadExisting
  ]

  services = (objectiveId, loadExisting) ->
    promises = [
      LearningObjectivesService.getArticles("categories"),
      AssignmentService.getAssignments()
    ]
    promises.push(LearningObjectivesService.getObjective(objectiveId)) if objectiveId?
    promises.push(LearningObjectivesService.getArticles("objectives")) if loadExisting?
    $q.all(promises)

  {
    scope:
      loadExisting: '@'
      indexRoute: '@'
      categoryId: '='
      objectiveId: '@'
      objectivesAwardPoints: '='
    bindToController: true
    controller: LearningObjectivesObjectivesDesignCtrl
    controllerAs: 'loObjectivesDesignCtrl'
    templateUrl: 'learning_objectives/objectives/design.html'
  }
]
