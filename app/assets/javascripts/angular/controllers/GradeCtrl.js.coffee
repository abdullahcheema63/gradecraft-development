@gradecraft.controller 'GradeCtrl', ['$timeout', '$rootScope', '$scope', 'GradePrototype', 'AssignmentScoreLevelPrototype', '$window', '$http', 'BadgePrototype', ($timeout, $rootScope, $scope, GradePrototype, AssignmentScoreLevelPrototype, $window, $http, BadgePrototype) -> 

  $scope.init = (grade, assignmentScoreLevels, badges)->
    $scope.header = "waffles" 
    gradeParams = grade["grade"]
    $scope.grade = new GradePrototype(gradeParams, $http)

    gradeId = gradeParams.id
    $scope.gradeId = gradeId
    $scope.rawScoreUpdating = false
    $scope.hasChanges = false
    $scope.gradeStatuses = ["In Progress", "Graded", "Released"]
    
    $scope.badges = []
    $scope.badgesEarned = []
    $scope.addBadges = (badges)->
      angular.forEach(badges, (badge, index)->
        badgePrototype = new BadgePrototype(badge, $scope.gradeId)
        $scope.badges.push badgePrototype
      )

    $scope.assignmentScoreLevels = []
    $scope.addAssignmentScoreLevels = (assignmentScoreLevels)->
      angular.forEach(assignmentScoreLevels, (scoreLevel, index)->
        scoreLevelPrototype = new AssignmentScoreLevelPrototype(scoreLevel, $scope)
        $scope.assignmentScoreLevels.push scoreLevelPrototype
      )

    $scope.badgesAvailable = ()->
      earnedBadgeCount = 0
      angular.forEach($scope.badges, (badge)->
        earnedBadgeCount += 1 if badge.earnedBadge
      )
      earnedBadgeCount != $scope.badges.length

    $scope.badgesAwarded = ()->
      earnedBadgeCount = 0
      angular.forEach($scope.badges, (badge)->
        earnedBadgeCount += 1 if badge.earnedBadge
      )
      earnedBadgeCount != 0

    unless assignmentScoreLevels.length == undefined
      $scope.addAssignmentScoreLevels(assignmentScoreLevels)

    unless badges.length == undefined
      $scope.addBadges(badges)

    $scope.addRemainingEarnedBadges = (event)->
      event.preventDefault()
      event.stopPropagation()

      unearnedBadges = {}
      unearnedBadgesPostParams = []
      angular.forEach($scope.badges, (badge)->
        if badge.unearned()
          badge.setCreating()
          unearnedBadges[badge.id] = badge
          unearnedBadgesPostParams.push $scope.earnManyBadgesPostParams(badge)
      )

      $http.post("/grade/#{$scope.grade.id}/earn_student_badges", {earned_badges: unearnedBadgesPostParams}).success(
        (data, status)->
          angular.forEach(data["grades"], (earnedBadge)->
            badge = unearnedBadges[earnedBadge.badge_id]
            badge.earnBadge(earnedBadge)
            badge.timeoutCreate()
          )
          availableBadges = document.getElementsByClassName("grade-badge available")
          `$timeout(function() { angular.element(availableBadges).addClass("hide-after-fade")}, 1000)`
          awardedBadges = document.getElementsByClassName("grade-badge awarded")
          `$timeout(function() { angular.element(awardedBadges).removeClass("hide-after-fade")}, 1000)`
      )
      .error((err)->
        alert("delete failed!")
        return false
      )

    $scope.removeAllEarnedBadges = (event)->
      event.preventDefault()
      event.stopPropagation()
      angular.element(event.currentTarget).addClass("ng-hide")

      $http.delete("/grade/#{$scope.grade.id}/earned_badges").success(
        (data, status)->
          angular.forEach($scope.badges, (badge) ->
            badge.handleDestroyAll()
          )
          availableBadges = document.getElementsByClassName("grade-badge available")
          `$timeout(function() { angular.element(availableBadges).removeClass("hide-after-fade")}, 1000)`
          awardedBadges = document.getElementsByClassName("grade-badge awarded")
          `$timeout(function() { angular.element(awardedBadges).addClass("hide-after-fade")}, 1000)`
      )
      .error((err)->
        console.log "delete failed"
        return false
      )

    $scope.earnBadgeForStudent = (badge)->
      unless badge.creating
        badge.setCreating()
        $http.post("/grades/earn_student_badge", $scope.earnedBadgePostParams(badge)).success(
          (data, status)->
            badge.earnBadge(data["earned_badge"])
            badge.timeoutCreate()
        )
        .error((err)->
          badge.timeoutCreate()
          console.log "create failed"
          return false
        )
 
    $scope.earnedBadgePostParams = (badge)->
      earned_badge:
        student_id: $scope.grade.student_id
        badge_id: badge.id,
        grade_id: $scope.grade.id,
        assignment_id: $scope.grade.assignment_id
        score: badge.point_total

    $scope.earnManyBadgesPostParams = (badge)->
      student_id: $scope.grade.student_id
      badge_id: badge.id,
      grade_id: $scope.grade.id,
      assignment_id: $scope.grade.assignment_id
      score: badge.point_total


    $scope.froalaOptions = {
      inlineMode: false,
      minHeight: 100,
      buttons: [ "bold", "italic", "underline", "strikeThrough", "subscript", "superscript", "fontFamily", "fontSize", "color", "formatBlock", "blockStyle", "inlineStyle", "align", "insertOrderedList", "insertUnorderedList", "outdent", "indent", "selectAll", "createLink", "insertVideo", "table", "undo", "redo", "html", "save", "insertHorizontalRule", "removeFormat" ],

      #Set the save URL.
      saveURL: '/grades/' + gradeId + '/async_update',

      #HTTP request type.
      saveRequestType: 'PUT',

      # Additional save params.
      saveParams: {"save_type": "feedback"}
    }
]
