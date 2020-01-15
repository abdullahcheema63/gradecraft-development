<template>
  <div class="content_block bg-green_mint_2">
    <h2>My Current Courses</h2>
    <p>
      Select courses you want to pay for and choose payment methods. When the course is done, come back here to turn off the payments.
    </p>

    <div v-if="userSubscription.failed_last_payment" class="inline_alert_msg">
      <p> There was a problem with your monthly auto-payment. You can remove courses, but you can’t add new ones until you fix the problem. </p>
    </div>

    <div class="table_container">
      <table class="form_options-present my_subscription">
        <thead>
          <tr>
            <th>Paid </th>
            <th>Course # </th>
            <th>Course Name </th>
            <th>Semester </th>
            <th>Published </th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td class="form_options alt-2">
              <input type="checkbox" id="course_select_3" checked="checked" disabled="disabled" />
              <label for="course_select_3">Madame Maxime </label>
            </td>
            <td>HSWW 456</td>
            <td>Hogwarts Fourth Years</td>
            <td>Fall 2020</td>
            <td> </td>
          </tr>
          <tr v-for="c of userCourses" :key="c.id">
            <td v-if="c.subscribed && !subscribedByUser(c.id)" class="form_options alt-2">
              <input type="checkbox" :id="c.id" checked="checked" disabled="disabled" />
              <label :for="c.id"> Subscribed by other user </label>
            </td>
            <td v-else-if="c.subscribed" class="form_options alt-2">
              <input type="checkbox" :id="c.id" :value="c" v-model="currentSubscribedCourses"/>
              <label :for="c.id">&nbsp; </label>
            </td>
            <td v-else-if="userSubscription.failed_last_payment" class="form_options alt-2">
              <input type="checkbox" :id="c.id" disabled="disabled" />
              <label :for="c.id">&nbsp;</label>
            </td>
            <td v-else class="form_options alt-2">
              <input type="checkbox" :id="c.id" :value="c" v-model="newSubscribingCourses"/>
              <label :for="c.id">&nbsp; </label>
            </td>

            <td>{{c.number}}</td>
            <td>{{c.name}}</td>
            <td>{{c.term.name}} {{c.term.year}}</td>
            <td><span v-if="c.published" class="checked">&nbsp;</span> </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script lang="coffee">
```

module.exports = {
  name: "subscriptions-course-selector",
  data() {
    return {

    }
  },
  computed: {
    userSubscription(){
      return this.$store.state.userSubscription
    },
    subscribedCourses(){
      return this.$store.state.userSubscription.courses
    },
    userCourses(){
      return this.$store.getters.userActiveCourseMemberships
    },
    subscribedCourseIds(){
      return this.$store.state.previouslySubscribedCourses.map(course => course.id)
    },
    currentSubscribedCourses: {
      get: function() {
        return this.$store.state.currentSubscribedCourses;
      },
      set: function (courseIds) {
        this.$store.state.currentSubscribedCourses = courseIds;
      }
    },
    newSubscribingCourses: {
      get: function() {
        return this.$store.state.newSubscribingCourses;
      },
      set: function (courseIds) {
        this.$store.state.newSubscribingCourses = courseIds;
      }
    }
  },
  methods: {
    subscribedByUser(courseId){
      if ( this.subscribedCourseIds.indexOf(courseId) === -1 ) {
        return false;
      } else {
      return true;
      }
    },
    isSubscribed(course) {
      return this.subscribedCourses
        && this.subscribedCourses.some(c => c.id === course.id);
    },
    updateCurrentSubscribedCourse(courseId) {
      console.log("Update Subscribed", courseID);
      (this.$store.state.newSubscribingCourses.includes(courseID)
      ? this.$store.state.newSubscribingCourses.remove(courseID)
      : this.$store.state.newSubscribingCourses.push(courseID));
    },
  },
}
```
</script>
