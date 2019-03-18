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

          <accordionComponent>
            <template slot="heading">Create a new course</template>
            <template slot="content">
              <h4>Course Essentials</h4>
              <p>Let‘s start with some essential course info:</p>
              <div class="flex-2">
                <div class="form_elem">
                  <input type="text" id="course_number" required="required" placeholder="Your course number" />
                  <label for="course_number">Course #</label>
                </div>
                <div class="form_elem">
                  <input type="text" id="course_name" required="required" placeholder="Your course name" />
                  <label for="course_name">Course name</label>
                </div>
                <div class="form_elem">
                  <input type="text" id="course_start" placeholder="Course start date" />
                  <label for="course_start">Start date</label>
                </div>
                <div class="form_elem">
                  <input type="text" id="course_end" placeholder="Course end date" />
                  <label for="course_end">End date</label>
                </div>

                <div class="form_elem">
                  <select id="course_semester">
                    <option value="" selected="selected">
                      Semester
                    </option>
                    <option value="Fall">Fall</option>
                    <option value="Winter">Winter</option>
                    <option value="Spring">Spring</option>
                    <option value="Summer">Summer</option>
                  </select>
                  <label for="course_semester">Semester</label>
                </div>
                <div class="form_elem">
                  <select id="course_year">
                    <option value="" selected="selected">
                      Year
                    </option>
                    <option value="year_2020">2020</option>
                    <option value="year_2019">2019</option>
                    <option value="year_2018">2018</option>
                    <option value="year_2017">2017</option>
                  </select>
                  <label for="course_year">Year</label>
                </div>
              </div>

              <h4>Will This be a Trial Course or a Licensed Course?</h4>
              <div class="form_options">
                <input type="radio" id="trialCourse" name="courseType" />
                <label for="trialCourse">Trial Course</label>
              </div>
              <div class="form_options">
                <input type="radio" id="licensedCourse" name="courseType" />
                <label for="licensedCourse">Licensed Course</label>
              </div>
              <div class="form_options">
                <input type="radio" id="licensedCourse_disabled" name="courseType" disabled="disabled" />
                <label for="licensedCourse_disabled">Licensed Course</label>
              </div>
            </template>
          </accordionComponent>

          <accordionComponent>
            <template slot="heading">Convert a trial course [[SCENARIO: No trial courses]]</template>
            <template slot="content">
              <p>It looks like you don't have any trial courses available to convert. Try creating a new course!</p>
            </template>
          </accordionComponent>

          <accordionComponent>
            <template slot="heading">Convert a trial course [[SCENARIO: Yes trial courses]]</template>
            <template slot="content">
              <p>It looks like you have some trial courses set up already. Which one do you want to convert into a licensed course?</p>
              <div class="form_options">
                <input id="course_1" name="convertCourse" type="radio">
                <label for="course_1">HSWW 123 Course Title Here</label>
              </div>
              <div class="form_options">
                <input id="course_2" name="convertCourse" type="radio">
                <label for="course_2">HSWW 123 Course Title Here</label>
              </div>
              <div class="form_options">
                <input id="course_3" name="convertCourse" type="radio">
                <label for="course_3">HSWW 123 Course Title Here</label>
              </div>
            </template>
          </accordionComponent>

          <accordionComponent>
            <template slot="heading" class="locked">Convert a trial course</template>
            We need to be able to add the class "locked" on the heading for this scenario
          </accordionComponent>

          <button class="secondary" @close="toggleModalState">Cancel</button>
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
    accordionComponent: () => VComponents.get('vue/components/accordionComponent'),
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
