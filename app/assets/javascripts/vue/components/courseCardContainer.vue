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

    <div class="content_block" v-if="pastCourses">
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

    <div class="content_block bg-green_mint">
      <h2>Add a New Course</h2>
      <p>With your ____ account, you can explore all GradeCraft has to offer and
        create licensed courses. Licensed courses have the ability to:</p>
      <ul>
        <li>Integrate with other tools (like Canvas or Moodle)</li>
        <li>Import or add other users (such as assistants and students)</li>
      </ul>
      <p>
        Your license allows you <b>2 licensed courses,</b> active until May 14, 2019.
      </p>
      <buttonModal>
        <template slot="button-text">Add a course</template>
        <template slot="heading">Add a course</template>
        <template slot="content">
          <h2>How do you want to add your course?</h2>
          <div class="accordion">
            <h3><span></span>Create a new Course</h3>
            <div>
              <h4>Course Essentials</h4>
            </div>
          </div>
        </template>
      </buttonModal>
      <h3>Copy an existing course</h3>
      <p>If you like your setup from a previous course and would like to
        duplicate it instead of starting from scratch, we can also
        help you copy an existing course:
      </p>
      <buttonModal>
        <template slot="button-text">Request a copy</template>
        <template slot="heading">Copy a past course</template>
        <template slot="content">
          <div>
            <h2>Request a copy of an existing course</h2>
            <p>Which existing course would you like to copy?</p>
            <form>
              <div class="form_options" v-for="course in pastCourses">
                <input type="radio"/>
                <label :for="course">{{course.name}}, {{course.term.name}} {{course.term.year}}</label>
              </div>
              <br>
              <p>
                <b>Please note that your copy will be a trial course by default.</b>
                You will need to add more licensed courses to your account in order to convert it to a licensed course.
              </p>
              <p>Are there any additional notes you would like us to know?</p>
              <div class='form_elem'>
                <textarea></textarea>
                <label>Additional notes</label>
              </div>
              <p>You will receive an email confirmation of your request after submitting, and a GradeCraft support staff member will reach out to you within 24 hours, Monday&ndash;Friday, 9am&ndash;5pm EST.</p>
              <button class='action'>Submit request</button>
              <button class='secondary close'>Cancel</button>
            </form>
          </div>
        </template>
      </buttonModal>
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
    buttonModal: () => VComponents.get('vue/components/buttonModal'),
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
