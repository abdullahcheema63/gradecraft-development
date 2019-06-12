@gradecraft.directive 'gradeEarnedBadgesSelect', ['GradeService', 'BadgeService', (GradeService, BadgeService) ->
  AwardedBadgesCtrl = [()->
    vm = this
    vm.BadgeService = BadgeService
    
    vm.badgeFeedback = null

    BadgeService.getBadges(vm.studentId)

    # Has the student currently earned this badge on this grade?
    vm.badgeIsEarnedForGrade = (badge)->
      BadgeService.studentEarnedBadgeForGrade(vm.studentId, badge.id, GradeService.grades[0].id)

    # Can the badge be awarded or unawarded for this grade?
    vm.badgeIsActionable = (badge)->
      !badge.is_locked &&
      (badge.available_for_student || vm.badgeIsEarnedForGrade(badge))

    # Can the badge be awarded for this grade?
    vm.badgeIsAwardable = (badge)->
      badge.available_for_student && !vm.badgeIsEarnedForGrade(badge)

    # For accessibility, each checkbox must have a label with a unique id
    vm.inputId = (badge)->
      badge.name.toLowerCase().replace(/[\W]/g,"-") + badge.id

    # ACTION: toggle the badge award on this grade.
    #  - award if unawarded
    #  - remove if currently awarded
    vm.awardBadge = (badge)->
      return if !vm.badgeIsActionable(badge)
      if earnedBadge = vm.badgeIsEarnedForGrade(badge)
        BadgeService.deleteEarnedBadge(earnedBadge)
        badge.available_for_student = true
      else
        BadgeService.createEarnedBadge(badge.id, vm.studentId, GradeService.grades[0].id, vm.badgeFeedback)

    vm.setBadgeFeedback = (feedback)->
      console.log(vm.badgeFeedback)
  ]

  {
    bindToController: true,
    controller: AwardedBadgesCtrl,
    controllerAs: 'vm',
    scope: {
      studentId: '@',
      badgeFeedbackInput: '@'
    },
    templateUrl: 'grades/earned_badges_select.html'
  }
]

