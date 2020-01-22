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

const requestHeaders = {
  'Accept': 'application/json',
  'Content-Type': 'application/json',
  'X-CSRF-Token': csrftoken,
  'X-Requested-With': 'XMLHttpRequest',
}

const apiResponseToData = (responseJson) =>
  loadMany(responseJson.data, responseJson, { include: ["courses", "assignments", "course_memberships", "staff", "payments", "subscriptions", "billing_schemes"] });

const apiResponseToDataDataItem = (responseJson) =>
  dataItem(responseJson.data, responseJson, { include: ["courses", "payments", "user", "subscriptions", "payment_methods"] });

const store = new Vuex.Store({
  state: {
    courseDashboardURL: "/dashboard",
    overviewURL: "/overview",
    subscriptionsURL: "/subscriptions",
    errorAlertMessage: null,
    successAlertMessage: null,
    creditCardError: "",
    creditCardAddSuccess: null,
    allUsers: [],
    allCourses: [],
    newActivity: {
      courses: {},
      newInstructorsCount: 0,
      newSubscriptionsCount: 0,
      paidCoursesCount: 0
    },
    lastPayment: {
      courses: []
    },
    allInstructors: [],
    allInstitutions: [],
    allBillingSchemes: [],
    allSubscriptions: [],
    userSubscription: {
      payment_methods: {}
    },
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
      hasSeenOnboarding: null,
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
        var paidCoursesCount = json.paid_courses_count
        var newSubscriptionsCount = json.subscriptions_count
        const courses = apiResponseToData(json);
        console.log("final: (after apiResponseToData)", courses)
        commit('addNewActivity', {courses, newSubscriptionsCount, newInstructorsCount, paidCoursesCount});
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
        //console.log("Get all users" ,final);
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
        const resp = await fetch("/api/subscriptions");
        if (resp.status === 404){
          console.log("No subscription found")
        }
        else{
          const json = await resp.json();
          const final = apiResponseToDataDataItem(json);
          //console.log("user subscription", final);
          if (final.failed_last_payment || final.abandoned_last_payment) {
            store.dispatch("loadLastPayment")
          }
          commit('addUserSubscription', final)
        }
      },
      loadLastPayment: async function({ commit, state }){
        const resp = await fetch("/api/subscriptions/last_payment")
        if (resp.status === 404){
          console.log(resp.status);
        }
        else if (!resp.ok){
          throw resp;
        }
        const json = await resp.json();
        const final = apiResponseToDataDataItem(json);
        //console.log("final data after apiResponseToData:", final);
        commit('addLastPayment', final)

        if((final.failed === true) && !state.successAlertMessage){
          let message = "There was a problem with your monthly auto-payment: " + final.status
          commit('addErrorAlertMessage', message)
        }
      },
      addCardToSubscription: async function({ commit, state }, paymentMethod) {
        console.log("addCardToSubscription action dispatched")
        const resp = await fetch("/api/subscriptions/add_card", {
          method: 'POST',
          headers: requestHeaders,
          credentials: 'same-origin',
          body: JSON.stringify(paymentMethod),
        })
        if (!resp.ok){
          const help = await resp.json();
          console.log("errors?", help.errors)
          commit('addCreditCardError', help.errors)
        }
        else{
          store.dispatch("getUserSubscription");
          let message = "You’ve added a payment card."
          commit('addCreditCardSuccessMessage', message)
        }
      },
      editCardInfo: async function({ commit, state }, paymentMethodAndInfo) {
        console.log("editCardInfo action dispatched")
        const resp = await fetch("/api/subscriptions/edit_card", {
          method: 'POST',
          headers: requestHeaders,
          credentials: 'same-origin',
          body: JSON.stringify(paymentMethodAndInfo),
        })
        if (!resp.ok){
          const help = await resp.json();
          console.log("errors?", help.errors)
          commit('addCreditCardError', help.errors)
        }
        else{
          store.dispatch("getUserSubscription");
          let message = "You’ve updated your payment card."
          commit('addSuccessAlertMessage', message)
        }
      },
      removePaymentMethod: async function({ commit, state }, paymentMethodID){
        console.log("removePaymentMethod action dispatched")
        const resp = await fetch("/api/subscriptions/remove_card", {
          method: 'POST',
          headers: requestHeaders,
          credentials: 'same-origin',
          body: JSON.stringify(paymentMethodID),
        })
        if(!resp.ok){
          const help = await resp.json();
          commit('addErrorAlertMessage', help.errors)
        }
        else{
          store.dispatch("getUserSubscription");
          let message = "You’ve deleted your payment card"
          commit('addSuccessAlertMessage', message)
        }
        console.log("resp")
        console.log(resp)
      },
      makePaymentMethodDefault: async function({ commit }, paymentMethodID){
        const resp = await fetch("/api/subscriptions/make_payment_method_default", {
          method: 'POST',
          headers: requestHeaders,
          credentials: 'same-origin',
          body: JSON.stringify(paymentMethodID),
        })
        if(!resp.ok){
          console.log("errors from deleting card, response:", resp)
          let message = "Sorry, there was an error trying to change your primary payment card."
          commit('addErrorAlertMessage', message)
        }
        else{
          store.dispatch("getUserSubscription");
          let message = "You’ve changed your primary payment card."
          commit('addSuccessAlertMessage', message)
        }
      },
      getAllBillingSchemes: async function({ commit }){
        const resp = await fetch("/api/subscriptions/billing_scheme_tiers");
        if (resp.status === 404){
          console.log(resp.status);
        }
        else if (!resp.ok){
          throw resp;
        }
        const json = await resp.json();
        const final = apiResponseToData(json);
        //console.log(final);
        commit('addAllBillingSchemes', final)
      },
      addNewCourse: async function({commit, state}, course){
        const resp = await fetch("/api/courses", {
          method: 'POST',
          headers: requestHeaders,
          credentials: 'same-origin',
          body: JSON.stringify(course)
        })
        if(!resp.ok){
          let message = "There was an error creating your new course."
          commit('addErrorAlertMessage', message)
        }
        else{
          store.dispatch("getCourseMemberships");
          let message = "You’ve successfully created a new course!"
          commit('addSuccessAlertMessage', message)
        }
      },
      copyCourse: async function({commit, state}, course){
        const resp = await fetch("/api/courses/copy", {
          method: 'POST',
          headers: requestHeaders,
          credentials: 'same-origin',
          body: JSON.stringify(course)
        })
        if(!resp.ok){
          let message = "There was an error copying your course."
          commit('addErrorAlertMessage', message)
        }
        else{
          store.dispatch("getCourseMemberships");
          let message = "You’ve successfully copied your course!"
          commit('addSuccessAlertMessage', message)
        }
      },
      deleteCourse: async function({commit, state}, courseID ){
        var api = "/api/courses/" + courseID
        const resp = await fetch(api, {
          method: 'DELETE',
          headers: requestHeaders,
          credentials: 'same-origin',
          body: JSON.stringify(courseID)
        })
        if(!resp.ok){
          let message = "There was an error deleting your course."
          commit('addErrorAlertMessage', message)
        }
        else{
          store.dispatch("getCourseMemberships");
          let message = "You’ve successfully deleted your course!"
          commit('addSuccessAlertMessage', message)
        }
      },
      unpublishCourse: async function({ commit, state }, courseID){
        const resp = await fetch("/api/courses/unpublish", {
          method: 'POST',
          headers: requestHeaders,
          credentials: 'same-origin',
          body: JSON.stringify(courseID),
        }).then((response) => {
          if (!response.ok){
            store.dispatch("getCourseMemberships");
            let message = "There was a problem unpublishing your course"
            commit('addErrorAlertMessage', message)
          }
          else{
            store.dispatch("getCourseMemberships");
            let message = "You've successfully unpublished your course"
            commit('addSuccessAlertMessage', message)
          }
        })
      },
      publishCourse: async function({ commit, state }, courseID){
        const resp = await fetch("/api/courses/publish", {
          method: 'POST',
          headers: requestHeaders,
          credentials: 'same-origin',
          body: JSON.stringify(courseID),
        }).then((response) => {
          if (!response.ok){
            store.dispatch("getCourseMemberships");
            let message = "There was a problem publishing your course"
            commit('addErrorAlertMessage', message)
          }
          else{
            store.dispatch("getCourseMemberships");
            let message = "You've successfully published your course"
            commit('addSuccessAlertMessage', message)
          }
        })
      },
      archiveCourse: async function({ commit, state }, courseID){
        const resp = await fetch("/api/courses/archive", {
          method: 'POST',
          headers: requestHeaders,
          credentials: 'same-origin',
          body: JSON.stringify(courseID),
        })
        if(!resp.ok){
          let message = "There was an error archiving your course."
          commit('addErrorAlertMessage', message)
        }
        else{
          store.dispatch("getCourseMemberships");
          let message = "You’ve successfully archived your course!"
          commit('addSuccessAlertMessage', message)
        }
      },
      unarchiveCourse: async function({ commit, state }, courseID){
        const resp = await fetch("/api/courses/unarchive", {
          method: 'POST',
          headers: requestHeaders,
          credentials: 'same-origin',
          body: JSON.stringify(courseID),
        })
        if(!resp.ok){
          let message = "There was an error unarchiving a course."
          commit('addErrorAlertMessage', message)
        }
        else{
          store.dispatch("getCourseMemberships");
          let message = "You’ve successfully unarchived a course!"
          commit('addSuccessAlertMessage', message)
        }
      },
      createSubscription: async function({ commit }){
        const resp = await fetch("/api/subscriptions", {
          method: 'POST',
          headers: requestHeaders,
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
          headers: requestHeaders,
          credentials: 'same-origin',
          body: JSON.stringify(subscribingCourses),
        });
        const body = await resp.json();
        if (!resp.ok) {
          console.log("update subscription resp", resp)
          this.errors = (Array.isArray(body.errors) || typeof body.errors !== "object")
            ? body.errors
            : Object.entries(body.errors); //Need polyfill
          console.error("resp not ok!");
          console.error(this);
          console.error(resp);
          console.error(body);
          commit('addErrorAlertMessage', body.errors)
          return;
        }
        else {
          store.dispatch("getUserSubscription");
          store.dispatch("getCourseMemberships");
          console.log("inside subscription update body message: ", body.message)
          commit('addSuccessAlertMessage', body.message)
          commit('resetNewSubscribingCourses')
        }
      },
      retryFailedPayment: async function({ commit }, [paymentID, continuingCourses]){
        console.log("continueing courses: ", continuingCourses)
        const resp = await fetch("/api/subscriptions/retry", {
          method: 'POST',
          headers: requestHeaders,
          credentials: 'same-origin',
          body: JSON.stringify({paymentID: paymentID, courses: continuingCourses}),
        });
        const body = await resp.json();
        if (!resp.ok) {
          console.log("retry failed payment subscription resp", resp)
          this.errors = (Array.isArray(body.errors) || typeof body.errors !== "object")
            ? body.errors
            : Object.entries(body.errors); //Need polyfill
          console.error("resp not ok!");
          console.error(this);
          console.error(resp);
          console.error(body);
          commit('addErrorAlertMessage', body.errors)
          return;
        }
        else {
          store.dispatch("getUserSubscription");
          store.dispatch("getCourseMemberships");
          commit('addSuccessAlertMessage', body.message)
        }
      },
      seenOnboarding: async function({ commit }){
        const resp = await fetch("/api/users/seen_onboarding", {
          method: 'PUT',
          headers: requestHeaders,
          credentials: 'same-origin',
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
          store.state.user.hasSeenOnboarding = true
        }
      },
      toggleGuideControl({ commit }){
        commit('toggleGuide')
      },
      removeSuccessAlert({ commit}){
        commit('removeSuccessAlert')
      },
      removeErrorAlert({ commit}){
        commit('removeErrorAlert')
      },
      changeGuide: async function({ commit, state }){
        console.log("making api request to change persisted guide state")
        const resp = await fetch("/api/users/change_guide", {
          method: 'PUT',
          headers: requestHeaders,
          credentials: 'same-origin',
          body: JSON.stringify(state.user.showGuide)
        });
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
      addUserSubscriptionInfo({ commit }, subscriptionInfo){
        commit('addUserSubscriptionInfo', subscriptionInfo)
      },
      addErrorAlertMessage({commit}, message){
        commit('addErrorAlertMessage', message)
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
            published: course.published,
            termForAssignments: course.term_for_assignments,
            termForStudent: course.term_for_student,
            termForGSI: course.term_for_gsi,
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
      addNewActivity(state, { courses, newSubscriptionsCount, newInstructorsCount, paidCoursesCount}){
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
        state.newActivity.paidCoursesCount = paidCoursesCount
      },
      addAdminCourses(state, courses){
        //console.log("inside addAdminCourses mutation")
        console.log("course:", courses)
        state.allCourses = courses.map(course => {
          return {
            id: course.id,
            name: course.name,
            number: course.course_number,
            url: course.change_course_path,
            editURL: course.edit_course_path,
            copyStudentsURL: course.copy_courses_with_students_path,
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
            firstName: subscription.first_name,
            lastName: subscription.last_name,
            email: subscription.email,
            costPerMonth: subscription.cost_per_month,
            subscribedCourses: subscription.subscribed_courses,
            createdAt: subscription.created_at,
            updatedAt: subscription.updated_at,
            failedLastPayment: subscription.failed_last_payment,
            abandonedLastPayment: subscription.abandoned_last_payment,
            lastPaymentDate: subscription.last_payment_date,
            billing_scheme_id: subscription.billing_scheme_id,
            courses: [...subscription.courses],
            payments: {...subscription.payments},
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
            lastLoginAt: user.last_login_at,
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
              active: course.active
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
              published: course.published,
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
        state.userSubscription = subscriptionObj
        if(subscriptionObj.stripe_connection_error){
          state.errorAlertMessage = "Oops! There was an error connecting to Stripe"
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
        state.user.hasSeenOnboarding = user.has_seen_onboarding
        state.user.environment = user.environment
      },
      addLastPayment (state, lastPayment){
        state.lastPayment = lastPayment
      },
      addUserSubscriptionInfo (state, subscriptionInfo){
        console.log("inside addUserSubscriptionInfo", subscriptionInfo)
        state.user.subscription = {...subscriptionInfo}
      },
      addCreditCardError( state, message){
        state.creditCardError = message
      },
      addCreditCardSuccessMessage( state, message){
        state.creditCardAddSuccess = true
        console.log("message for card succes: ", message)
        state.errorAlertMessage = null
        state.successAlertMessage = message
      },
      addSuccessAlertMessage( state, message){
        state.errorAlertMessage = null
        state.successAlertMessage = message
      },
      resetNewSubscribingCourses(state){
        state.newSubscribingCourses = []
      },
      removeSuccessAlert(state){
        state.successAlertMessage = null
      },
      addErrorAlertMessage( state, message){
        state.successAlertMessage = null
        state.errorAlertMessage = message
      },
      removeErrorAlert(state){
        state.errorAlertMessage = null
      },
    },
    getters: {
      user: state => {
        return state.user
      },
      newActivity: state => {
        return state.newActivity
      },
      adminAllSubscriptions: state => {
        return state.allSubscriptions
      },
      allActiveCourses: state => {
        return state.allCourses.filter( course => course.active)
      },
      allArchivedCourses: state => {
        return state.allCourses.filter( course => !course.active)
      },
      removedSubscribedCourses: state => {
        return state.previouslySubscribedCourses.filter(course =>
          state.currentSubscribedCourses.indexOf(course) === -1)
      },
      hasSeenOnboarding: state => {
        return state.user.hasSeenOnboarding
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
      userActiveCourseMemberships: state => {
        return state.user.courseMembership.filter(course => course.active)
      },
    }
})
