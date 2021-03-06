@gradecraft.factory "GradingStatusService", ["GradeCraftAPI", "$http", (GradeCraftAPI, $http) ->

  resubmittedSubmissions = []
  ungradedSubmissions = []
  inProgressGrades = []
  readyForReleaseGrades = []

  getUngradedSubmissions = (studentId=null) ->
    $http.get("/api/grading_status/submissions/ungraded", { params: {studentId:studentId } }).then(
      (response) ->
        GradeCraftAPI.loadMany(ungradedSubmissions, response.data)
        GradeCraftAPI.logResponse(response.data)
      , (response) ->
        GradeCraftAPI.logResponse(response.data)
    )

  getResubmittedSubmissions = () ->
    $http.get("/api/grading_status/submissions/resubmitted").then(
      (response) ->
        GradeCraftAPI.loadMany(resubmittedSubmissions, response.data)
        GradeCraftAPI.logResponse(response.data)
      , (response) ->
        GradeCraftAPI.logResponse(response.data)
    )

  getInProgressGrades = (clear=false) ->
    inProgressGrades.length = 0 if clear is true
    $http.get("/api/grading_status/grades/in_progress").then(
      (response) ->
        GradeCraftAPI.loadMany(inProgressGrades, response.data)
        GradeCraftAPI.logResponse(response.data)
      , (response) ->
        GradeCraftAPI.logResponse(response.data)
    )

  getReadyForReleaseGrades = (clear=false) ->
    readyForReleaseGrades.length = 0 if clear is true
    $http.get("/api/grading_status/grades/ready_for_release").then(
      (response) ->
        GradeCraftAPI.loadMany(readyForReleaseGrades, response.data)
        GradeCraftAPI.logResponse(response.data)
      , (response) ->
        GradeCraftAPI.logResponse(response.data)
    )

  {
    resubmittedSubmissions: resubmittedSubmissions
    ungradedSubmissions: ungradedSubmissions
    readyForReleaseGrades: readyForReleaseGrades
    inProgressGrades: inProgressGrades
    getUngradedSubmissions: getUngradedSubmissions
    getResubmittedSubmissions: getResubmittedSubmissions
    getInProgressGrades: getInProgressGrades
    getReadyForReleaseGrades: getReadyForReleaseGrades
  }
]
