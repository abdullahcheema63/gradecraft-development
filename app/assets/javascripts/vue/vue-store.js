//= require vue

Vue.use(Vuex)

const store = new Vuex.Store({
  state: {
    user: {
      id: 1,
      firstName: "Erik",
      lastName: "Barroso",
      email: "ebarr@gmail.com",
      admin: true,
      showGuide: true,
      hasPaid: false,
      courseMembership: [{
        id: 1,
        name: "GradeCraft101",
        number: "GC101",
        role: "Instructor",
        instructor: "Cait Holman",
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
          name: "Fall",
          year: "2018",
          start: "2019-01-01T00:00:00",
          end: "2019-09-01T00:00:00"
        },
        licensed: true,
        published: true },
      {
        id: 2,
        name: "Basket Weaving",
        number: "BW101",
        role: "Instructor",
        instructor: "Steve Irwin",
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
          dueDate: "2018-07-12T00:00:00",
          planned: 25,
          submitted: 10,
          graded: 0,
          url: ""},
          {
          name: "Weaving Theory 2",
          dueDate: "2018-07-17T00:00:00",
          planned: 15,
          submitted: 0,
          graded: 0,
          url: ""}],
        term: {
          name: "Winter",
          year: "2018",
          start: "2018-01-01T00:00:00",
          end: "2018-09-01T00:00:00"
        },
        licensed: true,
        published: true },
      {
        id: 3,
        name: "Tai-Chi",
        number: "TC100",
        role: "Student",
        instructor: "Sensei Karla",
        url: "",
        gradingStatus: {
          url: "",
          ungraded: 0,
          ready: 0,
          resubmissions: 0
        },
        eventCount: 2,
        announcementCount: 8,
        assignments: [{
          name: "Rooting",
          dueDate: "",
          planned: 1,
          submitted: 0,
          graded: 0,
          url: ""},
          {
          name: "Balance",
          dueDate: "",
          planned: 0,
          submitted: 0,
          graded: 1,
          url: ""}],
        term: {
          name: "Winter",
          year: "2019",
          start: "2019-01-01T00:00:00",
          end: "2019-09-02T00:00:00"
        },
        licensed: true,
        published: true
      },
      {
        id: 4,
        name: "Broom Ball",
        number: "BB100",
        role: "Instructor",
        instructor: "Erik Barroso",
        url: "",
        gradingStatus: {},
        eventCount: 0,
        announcementCount: 0,
        assignments: [{}],
        term: {
          name: "Winter",
          year: "2019",
          start: "2019-01-01T00:00:00",
          end: "2019-09-02T00:00:00"
        },
        licensed: false,
        published: false
      },
      {
        id: 5,
        name: "Advanced Basket Weaving",
        number: "BW200",
        role: "Instructor",
        instructor: "Steve Irwin",
        url: "",
        gradingStatus: {},
        eventCount: 2,
        announcementCount: 8,
        assignments: [{}],
        term: {
          name: "Spring",
          year: "2016",
          start: "2016-01-01T00:00:00",
          end: "2016-09-01T00:00:00"
        },
        licensed: false,
        published: true
      },
    ]
    }},
    actions: {
      licenseCourse({ commit }, course_id){
        commit('updateLicense', {course_id: course_id, status: true})
      },
      unLicenseCourse({ commit }, course_id){
        commit('updateLicense', {course_id: course_id, status: false})
      },
      toggleGuideControl({ commit }){
        commit('toggleGuide')
      },
      addNewCourse({ commit }, course){
        commit('addNewCourse', {course: course})
      }
    },
    mutations: {
      updateLicense (state, {course_id, status}){
        var course_ids = state.user.courseMembership.map( course => course.id)
        var membershipIndex = course_ids.indexOf(course_id)
        if (membershipIndex >= 0){
          var course = state.user.courseMembership[membershipIndex]
          course.licensed = status
        }
      },
      toggleGuide (state){
        state.user.showGuide = !state.user.showGuide
      },
      addNewCourse (state, {course}){
        var newCourse = {...course}
        newCourse.term = {...course.term}
        newCourse.gradingStatus = {}
        newCourse.assignments = []
        newCourse.eventCount = ""
        newCourse.announcementCount = ""
        state.user.courseMembership.push(newCourse)
      }
    },
    getters: {
      userName: state => {
        return state.user.firstName + ' ' + state.user.lastName
      },
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
      },
      pastCourseMembership: state => {
        return state.user.courseMembership.filter( membership => {
          var today = new Date();
          var end = new Date(membership.term.end);

          if(today < end)
            {return false;}

          return membership.published
        })
      },
      unpublishedCourseMembership: state => {
        return state.user.courseMembership.filter( membership => {
          if(membership.published)
            {return false;}
          return membership
        })
      },
      unLicensedCourseMembership: state => {
        return state.user.courseMembership.filter( membership =>{
          if(membership.licensed)
            {return false;}
          return membership
        })
      },
      userGuideStatus: state => {
        return state.user.showGuide;
      },
      userHasPaid: state => {
        return state.user.hasPaid;
      }
    }
})
