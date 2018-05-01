@gradecraft.factory "GradeReleaseService", ["GradeCraftAPI", "$http", (GradeCraftAPI, $http) ->

  gradeIds = []

  postReleaseGrades = (assignmentId) ->
    $http.put("/api/assignments/#{assignmentId}/grades/release", grade_ids: gradeIds).then(
      (response) ->
        GradeCraftAPI.logResponse(response)
      , (error) ->
        GradeCraftAPI.logResponse(error)
    )

  addGradeIds = (ids...) -> gradeIds.push(ids...)

  clearGradeIds = (ids...) -> if ids.length > 0 then _.pull(gradeIds, ids...) else gradeIds.length = 0

  hasSelectedGrades = () -> _.some(gradeIds)

  toggleGradeSelection = (gradeId) ->
    index = @gradeIds.indexOf(gradeId)
    if index > -1 then @gradeIds.splice(index, 1) else @gradeIds.push(gradeId)

  {
    gradeIds: gradeIds
    postReleaseGrades: postReleaseGrades
    addGradeIds: addGradeIds
    clearGradeIds: clearGradeIds
    hasSelectedGrades: hasSelectedGrades
    toggleGradeSelection: toggleGradeSelection
  }
]
