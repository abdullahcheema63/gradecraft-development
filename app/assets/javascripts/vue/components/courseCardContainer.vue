<template>
  <div>
    <div v-for="course in currentCourses" >
      <courseCard class='course_box' :course="course"></courseCard>
    </div>
  </div>
</template>

<!-- have to set lang=coffee so rails-vue-loader can work -->
<!-- adding back ticks ` escapes coffeescript to js -->

<script lang='coffee'>`

module.exports = {
  name: 'course-card-container',
  components: {
    courseCard: VComponents['vue/components/courseCard']
  },
  computed: {
    currentCourses(){
      return this.$store.getters.currentCourseMembership;
    }
  }
}
`</script>
