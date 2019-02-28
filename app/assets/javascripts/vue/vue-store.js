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
        eventCount: 7,
        announcementCount: 5,
        assignments: [{
          name: "Assignment 1",
          dueDate: "2019-07-12T00:00:00",
          planned: 12,
          submitted: 14,
          graded: 0,
          url: ""},
          {
          name: "Assignment 2",
          dueDate: "2019-07-17T00:00:00",
          planned: 5,
          submitted: 0,
          graded: 0,
          url: ""}],
        term: {
          name: "Fall 2018",
          start: "2019-01-01T00:00:00",
          end: "2019-09-01T00:00:00"
        },
        licensed: true,
        published: true
      }],
      courseMembership: [{
        name: "Basket Weaving",
        role: "GSI",
        url: "",
        gradingStatus: {
          url: "",
          ungraded: 19,
          ready: 5,
          resubmissions: 3
        },
        eventCount: 2,
        announcementCount: 8,
        assignments: [{
          name: "Weaving Theory 1",
          dueDate: "2019-07-12T00:00:00",
          planned: 25,
          submitted: 10,
          graded: 0,
          url: ""},
          {
          name: "Weaving Theory 2",
          dueDate: "2019-07-17T00:00:00",
          planned: 15,
          submitted: 0,
          graded: 0,
          url: ""}],
        term: {
          name: "Winter 2018",
          start: "2019-01-01T00:00:00",
          end: "2019-09-01T00:00:00"
        },
        licensed: true,
        published: true
      }]
    }},
    getters: {
      currentCourseMembership: state => {
        return state.user.courseMembership.filter( membership => {
            var today = new Date();
            var start = new Date(membership.term.start);
            var end = new Date(membership.term.end);

            if (today < start)
              {return false;}
            if (today > end)
              {return false;}

            return membership.published
        })
      }
    }

})
