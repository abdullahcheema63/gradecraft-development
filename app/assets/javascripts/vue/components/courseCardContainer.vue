<template>
  <div>
    <h2>Current Courses</h2>
    <div class="course_box">
      <courseCard v-for="course in currentCourses" :course="course" status="published"></courseCard>
    </div>

    <h2>Unpublished Courses</h2>
    <div class="course_box">
      <courseCard v-for= "course in unpublishedCourses" :course="course" status="unpublished"></courseCard>
    </div>

    <guideMessage>
      <p>
        These are all your
        <em>published,</em>
        inactive courses. You can request to copy them if you like how you’ve set them up in the past—just use the “request a copy” feature in the section below!
      </p>
    </guideMessage>

    <h2>Past Courses</h2>
    <div class="course_box">
      <courseCard v-for="course in pastCourses" :course="course" status="past"></courseCard>
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
    guideMessage: () => VComponents.get('vue/components/guideMessage'),
  },
  computed: {
    currentCourses(){
      return this.$store.getters.currentCourseMembership;
    },
    pastCourses(){
      return this.$store.getters.pastCourseMembership;
    },
    unpublishedCourses(){
      return this.$store.getters.unpublishedCourseMembership;
    },
    courseTermYear(){
      return this.pastCourses.map(courseMembership => courseMembership.term.year)
    },
    courseTermName(){
      return this.pastCourses.map(courseMembership => courseMembership.term.name)
    },
  }
}
`</script>
