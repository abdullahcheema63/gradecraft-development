# Controls and renders button for manually triggering the saving of text comment
# on a student submission
@gradecraft.directive 'saveDraftButton', ['StudentSubmissionService', (StudentSubmissionService) ->

  SaveDraftButtonCtrl = [() ->
    vm = this

    vm.queueDraftSubmissionSave = () ->
      StudentSubmissionService.queueDraftSubmissionSave(vm.assignmentId, true)
  ]

  {
    bindToController: true
    controller: SaveDraftButtonCtrl
    controllerAs: 'vm'
    restrict: 'C'
    scope: {
      assignmentId: '@'
    }
    templateUrl: 'student/submission/save_draft_button.html'
  }
]
