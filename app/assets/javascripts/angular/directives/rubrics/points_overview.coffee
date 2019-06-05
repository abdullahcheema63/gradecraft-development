# Hovering synopsis of the rubric points assigned

@gradecraft.directive 'rubricPointsOverview', ['RubricService', 'AssignmentService', (RubricService, AssignmentService) ->

  {
    templateUrl: 'rubrics/points_overview.html'
    link: (scope, el, attr) ->

      scope.noPoints = () ->
        AssignmentService.assignment().full_points == 0

      scope.fullPoints = () ->
        AssignmentService.assignment().full_points || RubricService.fullPoints()

      scope.pointsAssigned = () ->
        RubricService.pointsAssigned()

      scope.pointsRemaining = () ->
        AssignmentService.assignment().full_points && AssignmentService.assignment().full_points - RubricService.pointsAssigned()

      scope.pointsAreSatisfied = () ->
        AssignmentService.assignment().full_points && AssignmentService.assignment().full_points == RubricService.pointsAssigned()

      scope.pointsAreMissing = () ->
        AssignmentService.assignment().full_points && AssignmentService.assignment().full_points > RubricService.pointsAssigned()

      scope.pointsAreOver = () ->
        AssignmentService.assignment().full_points && AssignmentService.assignment().full_points < RubricService.pointsAssigned()
  }
]
