//= require vue

Vue.use(Vuex)

const dataItem = function(item, response, options){
    // attach JSON API type to attributes ("badges", "assignments", etc.)
    if (response == null) { response = {}; }
    if (options == null) { options = {"include":[]}; }
    item.attributes.type = item.type;

    // attach associated models from included list within
    _.each(options.include, function(included){
      let predicate, relationships;
      if (!response.included || !item.relationships || !item.relationships[included]) { return; }

      if (Array.isArray(item.relationships[included].data)) {
        const related = {
          ids: _.pluck(item.relationships[included].data, "id"),
          types: _.pluck(item.relationships[included].data, "type")
        };
        predicate = item => Array.from(related.ids).includes(item.id) && Array.from(related.types).includes(item.type);
        relationships = _.filter(response.included, predicate);
        if (relationships != null) { return item.attributes[included] = _.pluck(relationships, "attributes"); }
      } else {
        predicate = {
          id: item.relationships[included].data.id,
          type: item.relationships[included].data.type
        };
        const relationship = _.find(response.included, predicate);
        if (relationship != null) { return item.attributes[included] = relationship.attributes; }
      }
    });
    return item.attributes;
  };

const loadMany = function(modelArray, response, options, filter) {
    if (options == null) { options = {"include":[]}; }
    if (filter == null) { filter = ()=> true; }
    return _(response.data)
      .map(item => dataItem(item, response, options))
      .filter(filter)
      .each(item => modelArray.push(item))
      .value();
  };

const apiResponseToData = (responseJson) =>
  loadMany(responseJson.data, responseJson, { include: ["courses", "assignments", "course_memberships", "staff", "payments", "licenses", "license_types"] });

const apiResponseToDataDataItem = (responseJson) =>
  dataItem(responseJson.data, responseJson, { include: ["courses", "payments"] });

const store = new Vuex.Store({
  state: {
    allUsers: [],
    allCourses: [],
    allInstructors: [],
    userLicense: null,
    user: {
      id: null,
      firstName: "",
      lastName: "",
      email: "",
      admin: null,
      showGuide: null,
      hasPaid: null,
      hasSeenCourseOnboarding: null,
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
      }]
    }},
    actions: {
      getCourseMemberships: async function({ commit }){
        //console.log("dispatched getCourseMemberships")
        const resp = await fetch("api/courses");
        if (resp.status === 404){
          console.log(resp.status);
        }
        else if (!resp.ok){
          throw resp;
        }
        const json = await resp.json();
        const final = apiResponseToData(json);
        //console.log(final);
        if (store.state.user.admin === "true"){
          commit('addAdminCourses', final);
        }
        else {
          commit('addCourses', final);
        }
      },
      getAllUsers: async function({ commit }){
        //console.log("getAllUsers action dispatched")
        const resp = await fetch("api/users");
        if (resp.status === 404){
          console.log(resp.status);
        }
        else if (!resp.ok){
          throw resp;
        }
        const json = await resp.json();
        //console.log(json);
        const final = apiResponseToData(json);
        //console.log(final);
        commit('addAllUsers', final)
      },
      getAllInstructors: async function({ commit }){
        //console.log("getAllInstructors action dispatched")
        const resp = await fetch("api/users/instructors");
        if (resp.status === 404){
          console.log(resp.status);
        }
        else if (!resp.ok){
          throw resp;
        }
        const json = await resp.json();
        //console.log(json);
        const final = apiResponseToData(json);
        //console.log(final);
        commit('addAllInstructors', final)
      },
      getUserLicense: async function({ commit }){
        console.log("getAllLicenses action dispatched")
        const resp = await fetch("/api/licenses");
        if (resp.status === 404){
          console.log(resp.status);
        }
        else if (!resp.ok){
          throw resp;
        }
        const json = await resp.json();
        console.log("json: and json.data (response.data) from vue store");
        console.log(json);
        const final = apiResponseToDataDataItem(json);
        console.log(final);
        commit('addUserLicense', final)
      },
      newLicensePayment: async function({ commit }, payment){
        const resp = await fetch("/api/licenses", {
          method: 'POST',
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: JSON.stringify(payment),
        });
        const body = await resp.json();
        if (!resp.ok) {
          this.errors = (Array.isArray(body.errors) || typeof body.errors !== "object")
            ? body.errors
            : Object.entries(body.errors); //Need polyfill
          console.error("resp not ok!");
          console.error(this);
          console.error(resp);
          console.error(body);
          return;
        }
        license = apiResponseToDataDataItem(body)
        commit('updateUserLicense', license)
      },
      updateLicensePayment: async function({ commit }, payment){
        const resp = await fetch("/api/licenses", {
          method: 'PATCH',
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: JSON.stringify(payment),
        });
        const body = await resp.json();
        if (!resp.ok) {
          this.errors = (Array.isArray(body.errors) || typeof body.errors !== "object")
            ? body.errors
            : Object.entries(body.errors); //Need polyfill
          console.error("resp not ok!");
          console.error(this);
          console.error(resp);
          console.error(body);
          return;
        }

        license = apiResponseToDataDataItem(body)
        commit('updateUserLicense', license)
      },
      updateCourseLicense: async function({ commit }, courseIds){
        const resp = await fetch("/api/licenses/edit", {
          method: "PUT",
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json",
          },
          body: JSON.stringify({ courses: courseIds }),
        });
        const body = await resp.json();
        if (!resp.ok) {
          this.errors = (Array.isArray(body.errors) || typeof body.errors !== "object")
            ? body.errors
            : Object.entries(body.errors); //Need polyfill
          console.error("resp not ok!");
          console.error(this);
          console.error(resp);
          console.error(body);
          return;
        }
        const license = apiResponseToDataDataItem(body)
        commit('updateUserLicense', license)
      },
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
      },
      setCurrentUser({ commit }, user){
        commit('setCurrentUser', user)
      }
    },
    mutations: {
      addCourses (state, courses){
        state.user.courseMembership = courses.map(course => {
          return {
            id: course.id,
            name: course.name,
            number: course.course_number,
            role: course.role,
            instructor: "Cait Holman",
            url: course.change_course_path,
            gradingStatus: {
              url: course.grading_status_path,
              ungraded: course.ungraded,
              ready: course.ready_for_release,
              resubmissions: course.resubmissions
            },
            eventCount: course.events_this_week,
            announcementCount: course.unread_announcements,
            assignments: course.assignments.map(assignment => ({
              name: assignment.name,
              dueDate: assignment.due_at,
              planned: assignment.planned,
              submitted: assignment.submitted,
              graded: assignment.graded,
            })),
            term: {
              name: course.semester,
              year: course.year,
              start: "2019-01-01T00:00:00",
              end: "2019-09-01T00:00:00"
            },
            licensed: true,
            published: course.published };
        });
      },
      addAdminCourses(state, courses){
        //console.log("inside addAdminCourses mutation")
        state.allCourses = courses.map(course => {
          return {
            id: course.id,
            name: course.name,
            url: course.change_course_path,
            editURL: course.edit_course_path,
            copyURL: course.copy_courses_path,
            copyStudentsURL: course.copy_courses_with_students_path,
            finalGradesURL: course.final_grades_path,
            gradebookURL: course.gradebook_file_path,
            researchGradesURL: course.research_gradebook_path,
            submissionsURL: course.submissions_path,
            awardedBadgesURL: course.export_earned_badges_path,
            created: course.created_at,
            licensed: course.has_paid,
            active: course.active,
            published: course.published,
            term: course.semester,
            year: course.year,
            studentNumber: course.student_count,
            instructors: course.staff.map(staff => ({
              text: staff.name,
              url: staff.url
            }))
          }
        })
      },
      addAllUsers (state, users){
        //console.log("inside addAllUsers mutation")
        state.allUsers = users.map(user => {
          return {
            id: user.id,
            username: user.username,
            firstName: user.first_name,
            lastName: user.last_name,
            email: user.email,
            createdAt: user.created_at,
            url: user.user_url,
            courses: user.course_memberships.map(course => ({
              name: course.name,
              role: course.role,
              score: course.score,
              semester: course.semester,
              score: course.score,
              year: course.year,
              url: course.change_course_path,
            }))
          }
        })
      },
      addAllInstructors (state, instructors){
        //console.log("inside addAllInstructors mutation")
        state.allInstructors = instructors.map(instructor => {
          return {
            id: instructor.id,
            firstName: instructor.first_name,
            lastName: instructor.last_name,
            email: instructor.email,
            url: instructor.url,
            licenseExpires: instructor.license_expires,
            paymentMethod: instructor.payment_method,
            accountType: instructor.account_type,
            courses: instructor.course_memberships.map(course => ({
              id: course.id,
              name: course.course_name,
              studentCount: course.student_count,
              changeCoursePath: course.change_course_path,
              licensed: course.licensed
            }))
          }
        })
      },
      addUserLicense (state, licenseObj){
        state.userLicense = licenseObj
      },
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
      },
      setCurrentUser (state, user){
        state.user.id = user.id
        state.user.username = user.username
        state.user.firstName = user.firstName
        state.user.lastName = user.lastName
        state.user.email = user.email
        state.user.admin = user.admin
        state.user.showGuide = user.showGuide
        state.user.hasPaid = user.hasPaid
        state.user.account_url = user.account_url
      },
      updateUserLicense (state, license){
        state.userLicense = license;
      }
    },
    getters: {
      userName: state => {
        return state.user.firstName + ' ' + state.user.lastName
      },
      userAccountURL: state => {
        return state.user.account_url
      },
      userOnboardingStatus: state => {
        return state.user.hasSeenCourseOnboarding
      },
      userGuideStatus: state => {
        return state.user.showGuide;
      }
    }
})
