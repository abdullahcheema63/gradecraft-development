<template>
  <div>
    <h2>Current Courses</h2>
    <div v-for="course in currentCourses" >
      <courseCard class='course_box' :course="course"></courseCard>
    </div>
    <h2>Past Courses</h2>
    <div v-for="course in pastCourses" >
      <pastCourse class='course_box' :course="course"></pastCourse>
    </div>
  </div>
</template>

<!-- have to set lang=coffee so rails-vue-loader can work -->
<!-- adding back ticks ` escapes coffeescript to js -->
<script lang='coffee'>`
module.exports = {
  name: 'course-card-container',
  components: {
    courseCard: () => VComponents.get('vue/components/courseCard'),
    pastCourse: () => VComponents.get('vue/components/pastCourse'),
  },
  computed: {
    currentCourses(){
      return this.$store.getters.currentCourseMembership;
    },
    pastCourses(){
      return this.$store.getters.pastCourseMembership;
    }
  }
}
`</script>
