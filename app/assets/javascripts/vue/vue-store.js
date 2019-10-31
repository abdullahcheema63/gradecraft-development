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

const csrftoken = document.head.querySelector("[name='csrf-token']").attributes.content.value;

const apiResponseToData = (responseJson) =>
  loadMany(responseJson.data, responseJson, { include: ["courses", "assignments", "course_memberships", "staff", "payments", "subscriptions", "billing_schemes"] });

const apiResponseToDataDataItem = (responseJson) =>
  dataItem(responseJson.data, responseJson, { include: ["courses", "payments", "user", "subscriptions", "payment_methods"] });

const store = new Vuex.Store({
  state: {
    courseDashboardURL: "/dashboard",
    overviewURL: "/overview",
    subscriptionsURL: "/subscriptions",
    courseCopyError: "",
    courseCreationError: "",
    courseUnpublishError: "",
    coursePublishError: "",
    courseArchiveError: "",
    courseUnarchiveError: "",
    allUsers: [],
    allCourses: [],
    newActivity: {
      courses: {},
      newInstructorsCount: 0,
      newSubscriptionsCount: 0
    },
    allInstructors: [],
    allInstitutions: [],
    allBillingSchemes: [],
    allSubscriptions: [],
    userSubscription: {},
    newSubscribingCourses: [],
    currentSubscribedCourses: [],
    previouslySubscribedCourses: [],
    user: {
      id: null,
      environment: "",
      firstName: "",
      lastName: "",
      email: "",
      username: "",
      showGuide: null,
      accountURL: null,
      lastLogin: null,
      lastLogout: null,
      createdAt: null,
      subscription: {},
      courseMembership: [{
        id: null,
        name: "",
        number: "",
        role: "",
        instructor: "",
        url: "",
        gradingStatus: {
          url: "",
          ungraded: null,
          ready: null,
          resubmissions: null
        },
        eventCount: null,
        announcementCount: null,
        assignments: [{
          name: "",
          dueDate: "",
          planned: null,
          submitted: null,
          graded: null,
          url: ""
        }],
        term: {
          name: "",
          year: "",
          start: "",
          end: ""
        },
        subscribed: null,
        published: null,
        active: null
       }]
    }},
    actions: {
      getUser: async function({commit}, userId ){
        var api = "/api/users/" + userId
        const resp = await fetch(api);
        if (resp.status === 404){
          console.log(resp.status);
        }
        else if (!resp.ok){
          throw resp;
        }
        const json = await resp.json();
        const final = apiResponseToDataDataItem(json);
        commit('setCurrentUser', final)
      },
      getCourseMemberships: async function({ commit }){
        const resp = await fetch("api/courses");
        if (resp.status === 404){
          console.log(resp.status);
        }
        else if (!resp.ok){
          throw resp;
        }
        const json = await resp.json();
        const final = apiResponseToData(json);
        commit('addCourses', final);
      },
      getNewActivity: async function({ commit }){
        const resp = await fetch("/api/dashboard/admin_new_activity");
        if (resp.status === 404){
          console.log(resp.status);
        }
        else if (!resp.ok){
          throw resp;
        }
        const json = await resp.json();
        console.log("json: (before apiResponseToData)", json)
        var newInstructorsCount = json.instructors_count
        console.log("newInstructorsCount: ", newInstructorsCount)
        var newSubscriptionsCount = json.subscriptions_count
        console.log("newSubscriptionsCount: ", newSubscriptionsCount)
        const courses = apiResponseToData(json);
        console.log("final: (after apiResponseToData)", courses)
        commit('addNewActivity', {courses, newSubscriptionsCount, newInstructorsCount});
      },
      getAllCourses: async function({ commit }){
        const resp = await fetch("/api/courses");
        if (resp.status === 404){
          console.log(resp.status);
        }
        else if (!resp.ok){
          throw resp;
        }
        const json = await resp.json();
        const final = apiResponseToData(json);
        console.log(final);
        commit('addAdminCourses', final);
      },
      getAllUsers: async function({ commit }){
        //console.log("getAllUsers action dispatched")
        const resp = await fetch("/api/users");
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
        const resp = await fetch("/api/users/instructors");
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
      getAllSubscriptions: async function({ commit }){
        const resp = await fetch("/api/subscriptions/all_subscriptions");
        if (resp.status === 404){
          console.log(resp.status);
        }
        else if (!resp.ok){
          throw resp;
        }
        const json = await resp.json();
        console.log(json);
        const final = apiResponseToData(json);
        console.log(final);
        commit('addAllSubscriptions', final)
      },
      getAllInstitutions: async function({ commit }){
        const resp = await fetch("/api/institutions");
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
        commit('addAllInstitutions', final);
      },
      getUserSubscription: async function({ commit }){
        console.log("getUserSubscriptions action dispatched")
        const resp = await fetch("/api/subscriptions");
        if (resp.status === 404){
          console.log(resp.status);
          store.dispatch("createSubscription");
        }
        else if (!resp.ok){
          throw resp;
        }
        const json = await resp.json();
        console.log("json from user subscription", json);
        const final = apiResponseToDataDataItem(json);
        console.log(final);
        commit('addUserSubscription', final)
      },
      getUserPaymentMethods: async function({commit, state}){
        console.log("getUserPaymentMethods action dispatched")
        const resp = await fetch("/api/subscriptions/payment_methods");
        if (resp.status === 404){
          console.log(resp.status);
        }
        else if (!resp.ok){
          throw resp;
        }
        const json = await resp.json();
        console.log(json);
        const final = apiResponseToData(json);
        console.log(final);
        commit('addUserPaymentMethods', final)
      },
      addCardToSubscription: async function({ commit }, paymentMethod) {
        console.log("addCardToSubscription action dispatched")
        const resp = await fetch("/api/subscriptions/add_card", {
          method: 'POST',
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'X-CSRF-Token': csrftoken,
            'X-Requested-With': 'XMLHttpRequest',
          },
          credentials: 'same-origin',
          body: JSON.stringify(paymentMethod),
        }).then((response) => {
          console.log(response)
          window.location.replace(store.state.subscriptionsURL)
        })
        console.log("resp")
        console.log(resp)
      },
      removePaymentMethod: async function({ commit }, paymentMethodID){
        console.log("removePaymentMethod action dispatched")
        const resp = await fetch("/api/subscriptions/remove_card", {
          method: 'POST',
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'X-CSRF-Token': csrftoken,
            'X-Requested-With': 'XMLHttpRequest',
          },
          credentials: 'same-origin',
          body: JSON.stringify(paymentMethodID),
        }).then((response) => {
          console.log(response)
          window.location.replace(store.state.subscriptionsURL)
        })
        console.log("resp")
        console.log(resp)
      },
      makePaymentMethodDefault: async function({ commit }, paymentMethodID){
        const resp = await fetch("/api/subscriptions/make_payment_method_default", {
          method: 'POST',
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'X-CSRF-Token': csrftoken,
            'X-Requested-With': 'XMLHttpRequest',
          },
          credentials: 'same-origin',
          body: JSON.stringify(paymentMethodID),
        }).then((response) => {
          console.log(response)
          window.location.replace(store.state.subscriptionsURL)
        })
        console.log("resp")
        console.log(resp)
      },
      getAllBillingSchemes: async function({ commit }){
        console.log("getAllBillingSchemes action dispatched")
        const resp = await fetch("/api/subscriptions/billing_scheme_tiers");
        if (resp.status === 404){
          console.log(resp.status);
        }
        else if (!resp.ok){
          throw resp;
        }
        const json = await resp.json();
        console.log(json);
        const final = apiResponseToData(json);
        console.log(final);
        commit('addAllBillingSchemes', final)
      },
      addNewCourse: async function({commit}, course){
        const resp = await fetch("/api/courses", {
          method: 'POST',
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'X-CSRF-Token': csrftoken,
            'X-Requested-With': 'XMLHttpRequest',
          },
          credentials: 'same-origin',
          body: JSON.stringify(course)
        }).then((response) => {
          window.location.replace(store.state.overviewURL)
          console.log("inside add resp action" , response)
        })
        state.courseCreationError = resp
        console.log("inside addNewCourse action" , resp)
      },
      copyCourse: async function({commit, state}, courseID ){
        const resp = await fetch("/api/courses/copy", {
          method: 'POST',
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'X-CSRF-Token': csrftoken,
            'X-Requested-With': 'XMLHttpRequest',
          },
          credentials: 'same-origin',
          body: JSON.stringify(courseID)
        }).then((response) => {
          window.location.replace(store.state.overviewURL)
        })
        state.courseCopyError = resp
        console.log("inside copyCourse action", resp)
      },
      deleteCourse: async function({commit, state}, courseID ){
        var api = "/api/courses/" + courseID
        const resp = await fetch(api, {
          method: 'DELETE',
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'X-CSRF-Token': csrftoken,
            'X-Requested-With': 'XMLHttpRequest',
          },
          credentials: 'same-origin',
          body: JSON.stringify(courseID)
        }).then((response) => {
          window.location.replace(state.overviewURL)
        })
        console.log("inside deleteCourse action", resp)
      },
      unpublishCourse: async function({ commit, state }, courseID){
        const resp = await fetch("/api/courses/unpublish", {
          method: 'POST',
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'X-CSRF-Token': csrftoken,
            'X-Requested-With': 'XMLHttpRequest',
          },
          credentials: 'same-origin',
          body: JSON.stringify(courseID),
        }).then((response) => {
          window.location.replace(store.state.overviewURL)
        })
        state.courseUnpublishError = resp
        console.log("inside unpublishCourse action", resp)
      },
      publishCourse: async function({ commit, state }, courseID){
        const resp = await fetch("/api/courses/publish", {
          method: 'POST',
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'X-CSRF-Token': csrftoken,
            'X-Requested-With': 'XMLHttpRequest',
          },
          credentials: 'same-origin',
          body: JSON.stringify(courseID),
        }).then((response) => {
          window.location.replace(store.state.overviewURL)
        })
        state.coursePublishError = resp
        console.log("inside publishCourse action", resp)
      },
      archiveCourse: async function({ commit, state }, courseID){
        const resp = await fetch("/api/courses/archive", {
          method: 'POST',
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'X-CSRF-Token': csrftoken,
            'X-Requested-With': 'XMLHttpRequest',
          },
          credentials: 'same-origin',
          body: JSON.stringify(courseID),
        }).then((response) => {
          window.location.replace(store.state.overviewURL)
        })
        state.courseArchiveError = resp
        console.log("inside archiveCourse action", resp)
      },
      unarchiveCourse :async function({ commit, state }, courseID){
        const resp = await fetch("/api/courses/unarchive", {
          method: 'POST',
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'X-CSRF-Token': csrftoken,
            'X-Requested-With': 'XMLHttpRequest',
          },
          credentials: 'same-origin',
          body: JSON.stringify(courseID),
        }).then((response) => {
          window.location.replace(store.state.overviewURL)
        })
        state.courseUnarchiveError = resp
        console.log("inside unarchiveCourse action", resp)
      },
      createSubscription: async function({ commit }){
        const resp = await fetch("/api/subscriptions", {
          method: 'POST',
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'X-CSRF-Token': csrftoken,
            'X-Requested-With': 'XMLHttpRequest',
          },
          credentials: 'same-origin'
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
      },
      updateSubscription: async function({ commit }, subscribingCourses){
        const resp = await fetch("/api/subscriptions", {
          method: 'POST',
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'X-CSRF-Token': csrftoken,
            'X-Requested-With': 'XMLHttpRequest',
          },
          credentials: 'same-origin',
          body: JSON.stringify(subscribingCourses),
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
        else {
          window.location.replace(store.state.subscriptionsURL)
        }
      },
      toggleGuideControl({ commit }){
        console.log("toggled guide control action")
        commit('toggleGuide')
      },
      changeGuide({ commit }){
        console.log("make api request")
      },
      addUserSubscriptionInfo({ commit }, subscriptionInfo){
        commit('addUserSubscriptionInfo', subscriptionInfo)
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
            active: course.active,
            instructor: "Cait Holman",
            url: course.change_course_path,
            subscription: {...course.subscription},
            gradingStatus: {
              url: course.grading_status_path,
              ungraded: course.ungraded,
              ready: course.ready_for_release,
              resubmissions: course.resubmissions
            },
            eventCount: course.events_this_week,
            announcementCount: course.unread_announcements,
            assignments: {...course.assignments},
            term: {
              name: course.semester,
              year: course.year,
              start: course.start_date,
              end: course.end_date
            },
            subscribed: course.subscribed,
            published: course.published
           };
        });
        let subscribedCourses = state.user.courseMembership.filter(course => {
          if(course.subscribed) {
            return course.subscription.user_id === state.user.id
          }
          return false
        });
        state.currentSubscribedCourses = subscribedCourses
        state.previouslySubscribedCourses = subscribedCourses

      },
      addNewActivity(state, { courses, newSubscriptionsCount, newInstructorsCount}){
        state.newActivity.courses = courses.map(course => {
          return {
            id: course.id,
            name: course.name,
            url: course.change_course_path,
            editURL: course.edit_course_path,
            active: course.active,
            published: course.published,
            subscribed: course.subscribed,
            semester: course.semester,
            year: course.year,
            number: course.course_number,
            studentCount: course.student_count,
            created: course.formatted_created_at,
            instructors: {...course.staff}
          }
        })
        state.newActivity.newSubscriptionsCount = newSubscriptionsCount
        state.newActivity.newInstructorsCount = newInstructorsCount
      },
      addAdminCourses(state, courses){
        //console.log("inside addAdminCourses mutation")
        console.log("course:", courses)
        state.allCourses = courses.map(course => {
          return {
            id: course.id,
            name: course.name,
            url: course.change_course_path,
            editURL: course.edit_course_path,
            copyStudentsURL: course.copy_courses_with_students_path,
            finalGradesURL: course.final_grades_path,
            gradebookURL: course.gradebook_file_path,
            researchGradesURL: course.research_gradebook_path,
            submissionsURL: course.submissions_path,
            assignmentTypeSummaryURL: course.export_all_scores_assignment_types_path,
            earnedBadgesURL: course.export_earned_badges_path,
            badgeStructureURL: course.export_structure_badges_path,
            assignmentStructureURL: course.export_structure_assignments_path,
            gradeSchemeStructureURL: course.export_structure_grade_scheme_elements_path,
            created: course.created_at,
            subscribed: course.subscribed,
            active: course.active,
            published: course.published,
            term: course.semester,
            year: course.year,
            studentNumber: course.student_count,
            instructors: {...course.staff},
            subscription: {...course.subscription},
          }
        })
      },
      addAllSubscriptions (state, subscriptions){
        console.log("subscriptions:", subscriptions)
        state.allSubscriptions = subscriptions.map(subscription => {
          return {
            id: subscription.id,
            userID: subscription.user_id,
            renewalDate: subscription.renewal_date,
            createdAt: subscription.created_at,
            updatedAt: subscription.updated_at,
            billing_scheme_id: subscription.billing_scheme_id,
            payments: {...subscription.payments}
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
            subscription: "trial",
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
            createdAt: instructor.created_at,
            email: instructor.email,
            url: instructor.url,
            subscribed: instructor.subscribed,
            subscriptionExpires: instructor.subscription_expires,
            paymentMethod: instructor.payment_method,
            accountType: instructor.account_type,
            activeCoursesNumber: instructor.active_courses,
            courses: instructor.course_memberships.map(course => ({
              id: course.id,
              name: course.course_name,
              studentCount: course.student_count,
              changeCoursePath: course.change_course_path,
              subscribed: course.subscribed,
              active: course.active
            }))
          }
        })
      },
      addAllInstitutions (state, institutions){
        state.allInstitutions = institutions.map(institution => {
          return {
            id: institution.id,
            name: institution.name,
            editURL: institution.edit_url,
            hasSiteLicense: institution.has_site_license,
            institutionType: institution.institution_type
          }
        })
      },
      addAllBillingSchemes(state, billingSchemes){
        state.allBillingSchemes = billingSchemes
      },
      addUserSubscription (state, subscriptionObj){
        console.log("addUserSubscription", subscriptionObj)
        state.userSubscription = subscriptionObj
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
        state.user.firstName = user.first_name
        state.user.lastName = user.last_name
        state.user.email = user.email
        state.user.admin = user.admin
        state.user.showGuide = user.show_guide
        state.user.accountURL = user.account_url
        state.user.lastLogin = user.last_login
        state.user.lastLogout = user.last_logout
        state.user.createdAt = user.created_at
        state.user.showGuide = user.show_guide
        state.user.environment = user.environment
      },
      addUserPaymentMethods (state, paymentMethods){
        state.userSubscription.paymentMethods = paymentMethods;
      },
      addUserSubscriptionInfo (state, subscriptionInfo){
        state.user.subscription = {...subscriptionInfo}
      }
    },
    getters: {
      user: state => {
        return state.user
      },
      newActivity: state => {
        return state.newActivity
      },
      removedSubscribedCourses: state => {
        return state.previouslySubscribedCourses.filter(course =>
          state.currentSubscribedCourses.indexOf(course) === -1)
      },
      userOnboardingStatus: state => {
        return state.user.hasSeenCourseOnboarding
      },
      userSubscriptionInfo: state =>{
        if(state.user.subscription) return state.user.subscription
        return null
      },
      userGuideStatus: state => {
        return state.user.showGuide;
      },
      userCourseMemberships: state => {
        return state.user.courseMembership;
      },
    }
})
