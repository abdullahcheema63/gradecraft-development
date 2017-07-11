# edit form for one assignment
@gradecraft.directive 'assignmentEditForm', ['$q', 'AssignmentTypeService', 'AssignmentService', ($q, AssignmentTypeService, AssignmentService) ->
  AssignmentEditCtrl = [()->
    vmAssignmentEdit = this
    vmAssignmentEdit.loading = true

    vmAssignmentEdit.assignments = AssignmentService.assignments

    services(vmAssignmentEdit.assignmentId).then(()->
      vmAssignmentEdit.loading = false
    )
  ]

  services = (id)->
    promises = [
      AssignmentService.getAssignment(id),
      AssignmentTypeService.getAssignmentTypes(),
    ]
    return $q.all(promises)

  {
    bindToController: true,
    controller: AssignmentEditCtrl,
    controllerAs: 'vmAssignmentEdit',
    templateUrl: 'assignments/edit.html',
    scope: {
      assignmentId: "="
    }
  }
]
