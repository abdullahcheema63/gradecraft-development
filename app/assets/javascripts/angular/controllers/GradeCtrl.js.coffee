@gradecraft.controller 'GradeCtrl', ['$rootScope', '$scope', 'GradePrototype', '$window', '$http' , ($rootScope, $scope, GradePrototype, $window, $http) -> 


  $scope.init = (params)->
    $scope.header = "waffles" 
    gradeParams = params["grade"]
    $scope.grade = new GradePrototype(gradeParams)
    $scope.grade.addWatchers()
    gradeId = gradeParams.id

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

  GradePrototype = (attrs={})->
    grade = attrs
    this.id = grade["id"]
    this.status = grade["status"]
    this.raw_score = grade["raw_score"]
    this.feedback = grade["feedback"]

  GradePrototype.prototype = {
    snakes: ()->
      alert("snakes")

    update: ()->
      self = this
      $http.put("/grades/#{self.id}/async_update", self).success(
        (data,status)->
          self.resetChanges()
      )
      .error((err)->
      )

    addWatchers: ()->
      $scope.$watch('grade.feedback', (()->
        $scope.grade.update()
        ), true)

      $scope.$watch('grade.raw_score', (()->
        $scope.grade.update()
        ), true)

    debouncedUpdate: ()->
      debounce((->
        self = this
        $http.put("/grades/#{self.id}/async_update", self).success(
          (data,status)->
            self.resetChanges()
        )
        .error((err)->
        )
      ), 2000)

    unloadUpdate: ()->
      self = this
      $http.put("/grades/#{self.id}/async_update", self).success(
        (data,status)->
          self.resetChanges()
      )
      .error((err)->
      )

    params: ()->
      {
        id: self.id,
        status: self.status,
        raw_score: this.raw_score,
        feedback: this.feedback
      }

    resetChanges: ()->
      this.hasChanges = false
<<<<<<< HEAD
=======
  }

>>>>>>> implement watchers to manage updates in grade edit controller using angular-debounce, working around fcsa-number to override internal blur actions in directive
]
