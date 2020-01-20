<template>
  <div class="content_block bg-green_mint_2">
    <h2>My Current Courses</h2>
    <p>
      Select courses you want to pay for and choose payment methods. When the course is done, come back here to turn off the payments.
    </p>

    <div v-if="userSubscription.failed_last_payment && userSubscription.within_grace_period" class="inline_alert_msg">
      <p> There was a problem with your monthly auto-payment. You can remove courses, but you can’t add new ones until you fix the problem. </p>
    </div>
    <div v-else class="inline_alert_msg">
      <p>Because your last monthly auto-payment failed and you are outside the grace period, we removed your subscribed courses and unpublished those that were published. Once you fix the issue with your card, you can re-subscribe and re-publish any courses.</p>
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
          <tr v-for="c of userCourses" :key="c.id">
            <td v-if="c.subscribed && !subscribedByUser(c.id)" class="form_options alt-2">
              <input type="checkbox" :id="c.id" checked="checked" disabled="disabled" />
              <label :for="c.id"> Subscribed by other user </label>
            </td>
            <td v-else-if="c.subscribed" class="form_options alt-2">
              <input type="checkbox" :id="c.id" :value="c" v-model="currentSubscribedCourses"/>
              <label :for="c.id">&nbsp; </label>
            </td>
            <td v-else-if="userSubscription.abandoned_last_payment && removedAfterGracePeriod(c.id)" class="form_options alt-2">
              <input type="checkbox" :id="c.id" :value="c" v-model="newSubscribingCourses" />
              <label :for="c.id"><em class="pink_text">Removed</em></label>
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
    lastPayment(){
      return this.$store.state.lastPayment
    },
    removedCourseIds(){
      return this.lastPayment.courses.map(course => course.id)
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
      if( this.subscribedCourseIds.indexOf(courseId) === -1 ) {
        return false;
      } else {
      return true;
      }
    },
    removedAfterGracePeriod(courseId){
      if( this.removedCourseIds.indexOf(courseId) === -1 ){
        return false
      }else{
        return true
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
