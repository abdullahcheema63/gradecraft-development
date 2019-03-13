<template>
  <div>
    <div class="content_block">
      <h2>Current Courses</h2>
      <div class="course_box" v-if="currentCourses">
        <courseCard v-for="course in currentCourses" :course="course" status="published"></courseCard>
      </div>
      <div class="course_box" v-else>
        <div class="course_card empty">
          <p><em>You don't have any published, active courses!</em></p>
        </div>
      </div>
    </div>

    <div class="content_block">
      <h2>Unpublished Courses</h2>
      <div class="course_box" v-if="unpublishedCourses">
        <courseCard v-for= "course in unpublishedCourses" :course="course" status="unpublished"></courseCard>
      </div>
      <div class="course_box" v-else>
        <div class="course_card empty">
          <p><em>You don't have any unpublished courses</em></p>
        </div>
      </div>
    </div>

    <div class="content_box" v-if="pastCourses">
      <h2>Past Courses</h2>
      <guideMessage>
        <p>
          These are all your
          <em>published,</em>
          inactive courses. You can request to copy them if you like how you’ve set them up in the past—just use the “request a copy” feature in the section below!
        </p>
      </guideMessage>
      <div class="filter_box">
        <div v-for="year in courseTermYear">
          <input :id="year"type="checkbox" v-model="termYear" :value="year"/>
          <label :for="year">{{year}}</label>
        </div>
      </div>
      <div class="filter_box">
        <div v-for="term in courseTermName">
          <input :id="term" type="checkbox" v-model="termName" :value="term"/>
          <label :for="term">{{term}}</label>
        </div>
      </div>
      <div class="course_box">
        <courseCard v-for="course in filteredPastCourses" :course="course" status="past"></courseCard>
      </div>
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
  data() {
    return {
      termYear: [],
      termName: []
    }
  },
  computed: {
    currentCourses(){
      return this.$store.getters.currentCourseMembership;
    },
    pastCourses(){
      return this.$store.getters.pastCourseMembership;
    },
    filteredPastCourses(){
      var allPastCourses = this.pastCourses;
      return allPastCourses.filter( course => {
          if (!(this.termYear.includes(course.term.year)) && this.termYear.length) {return false}
          if (!(this.termName.includes(course.term.name)) && this.termName.length) {return false}
          return true
      })
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
