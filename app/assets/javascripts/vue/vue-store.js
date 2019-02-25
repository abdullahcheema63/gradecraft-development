//= require vue

Vue.use(Vuex)

const store = new Vuex.Store({
  state: {
    user: {
      firstName: "Erik",
      lastName: "Barroso",
      email: "ebarr@gmail.com",
      admin: true,
      courseMembership: [{
        name: "GradeCraft101",
        role: "Instructor",
        url: "",
        gradingStatus: {
          url: "",
          ungraded: 25,
          ready: 2,
          resubmissions: 10
        },
        assignments: [{
          name: "Assignment 1",
          dueDate: "2019-07-12T00:00:00",
          planned: true,
          submitted: false},
          {
          name: "Assignment 2",
          dueDate: "2019-07-17T00:00:00",
          planned: false,
          submitted: false}],
        term: {
          name: "Fall 2018",
          start: "2019-07-01T00:00:00",
          end: "2019-09-01T00:00:00"
        },
        licensed: true
      }]
    }},
})
