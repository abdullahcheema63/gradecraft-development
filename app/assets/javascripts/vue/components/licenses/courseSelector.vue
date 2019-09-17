<template>
  <div class="content_block bg-green_mint_2">
    <h2>My Current Courses</h2>
    <p>
      Select courses you want to pay for and choose payment methods. When the course is done, come back here to turn off the payments.
    </p>

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
            <td v-if="c.licensed" class="form_options alt-2">
              <input type="checkbox" :id="c.id" :value="c" v-model="currentSubscribedCourseIds"/>
              <label :for="c.id">&nbsp; </label>
            </td>
            <!-- SOPHIA to ERIK: another v-if is if someone else has paid, then you can adapt the disabled static option I have above -->
            <td v-else class="form_options alt-2">
              <input type="checkbox" :id="c.id" :value="c" v-model="newSubscribingCourseIds"/>
              <label :for="c.id">&nbsp; </label>
            </td>

            <td>{{c.number}}</td>
            <td>{{c.name}}</td>
            <td>{{c.semester}} {{c.year}}</td>
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
  name: "licenses-course-selector",
  data() {
    return {

    }
  },
  computed: {
    licensedCourses(){
      return this.$store.state.userLicense.courses
    },
    userCourses(){
      return this.$store.getters.userCourseMemberships
    },
    selectedSubscribedCourses() {
      return this.userCourses.filter(course =>
          course.licensed || this.newSubscribingCourseIds.includes(course.id)
        );
    },
    currentSubscribedCourseIds: {
      get: function() {
        return this.$store.state.currentSubscribedCourseIds;
      },
      set: function (courseIds) {
        this.$store.state.currentSubscribedCourseIds = courseIds;
      }
    },
    newSubscribingCourseIds: {
      get: function() {
        return this.$store.state.newSubscribingCourseIds;
      },
      set: function (courseIds) {
        this.$store.state.newSubscribingCourseIds = courseIds;
      }
    }
  },
  methods: {
    isLicensed(course) {
      return this.licensedCourses
        && this.licensedCourses.some(c => c.id === course.id);
    },
    updateCourses(courseIds) {
      this.$store.dispatch("updateCourseLicense", courseIds)
    },
    addCourse(course) {
      const newList = this.licensedCourses
        .map(c => c.id);
      newList.push(course.id);
      this.updateCourses(newList);
    },
    removeCourse(course) {
      const newList = this.licensedCourses
        .map(c => c.id)
        .filter(id => id !== course.id);
      this.updateCourses(newList);
    },
    updateCurrentSubscribedCourse(courseId) {
      console.log("Update Subscribed", courseID);
      (this.$store.state.newSubscribingCourseIds.includes(courseID)
      ? this.$store.state.newSubscribingCourseIds.remove(courseID)
      : this.$store.state.newSubscribingCourseIds.push(courseID));
    },
  },
}
```
</script>
