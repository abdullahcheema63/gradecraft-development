<template>
  <div>
    <div class="content_block">
      <h2 class="unspace-top">Current Courses</h2>
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
      <h2 class="unspace-top">Unpublished Courses</h2>
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
      <h2 class="unspace-top">Past Courses</h2>
      <guideMessage>
        <p>
          These are all your
          <em>published,</em>
          inactive courses. You can request to copy them if you like how you’ve set them up in the past—just use the “request a copy” feature in the section below!
        </p>
      </guideMessage>

      <div class="filter_box">
        <p>Select which filters you want to apply:</p>
        <div>
          <span v-for="year in courseTermYear">
            <input :id="year"type="checkbox" v-model="termYear" :value="year"/>
            <label :for="year">{{year}}</label>
          </span>
        </div>
        <div>
          <span v-for="term in courseTermName">
            <input :id="term" type="checkbox" v-model="termName" :value="term"/>
            <label :for="term">{{term}}</label>
          </span>
        </div>
      </div>
      <div class="course_box">
        <courseCard v-for="course in filteredPastCourses" :course="course" status="past"></courseCard>
      </div>
    </div>

    <div class="content_block bg-green_mint">
      <h2>Add a New Course</h2>
      <p>With your licensed account, you can explore all GradeCraft has to offer and
        create licensed courses. Licensed courses have the ability to:</p>
      <ul>
        <li>Integrate with other tools (like Canvas or Moodle)</li>
        <li>Import or add other users (such as assistants and students)</li>
      </ul>
      <p>
        Your license allows you <b>2 licensed courses,</b> active until May 14, 2019.
      </p>

      <buttonModal button_class="action" ref="buttonModal_add">
        <template slot="button-text">Add a course</template>
        <template slot="heading">Add a new course</template>
        <template slot="content">
          <form>
            <formContainer>
              <template slot="question">
                <div class="tab_toggle">
                  <span v-for="question in formQuestion">
                    <input type="radio" :id="question" :value="question" v-model="formResponse[0]" name="toggle_group" />
                    <label :for="question">{{question}}</label>
                  </span>
                </div>
              </template>
              <template slot="form-response">
                <div v-if="formResponse[0]==='Create a new course'">
                  <p>Use this form to create a new course from scratch:</p>

                  <h3>Essential Course Info</h3>
                  <div v-if="newCourseErrors.length" class="inline_alert_msg">
                    <p>
                      Please fill out the <b>required fields</b> below if you want to create a new course.
                    </p>
                  </div>
                  <div class="flex-2">
                    <div class="form_elem">
                      <input type="text" v-model="newCourse.number" id="course_number" required="required" placeholder="Your course number" />
                      <label for="course_number">Course #</label>
                    </div>
                    <div class="form_elem">
                      <input type="text" v-model="newCourse.name" id="course_name" required="required" placeholder="Your course name" />
                      <label for="course_name">Course name</label>
                    </div>
<<<<<<< Updated upstream
                    <datePicker @update-date="updateStartDate" id="course_start" placeholder="Course start date">
                      <label for="course_start">Start date</label>
                    </datePicker>
                    <datePicker @update-date="updateEndDate" id="course_end" placeholder="Course end date">
=======
                    <div class="form_elem">
                      <datePicker id="course_start" placeholder="Course start date" v-model="newCourse.term.start">
                        <template name="label_text">Start Date</template>
                      </datePicker>
                    </div>
                    <div class="form_elem">
                      <input type="text" v-model="newCourse.term.end" id="course_end" placeholder="Course end date" class="datetimepicker-input calendar" />
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
                      <label for="course_end">End date</label>
                    </datePicker>

                    <div class="form_elem">
                      <select id="course_semester" v-model="newCourse.term.name">
                        <option value="" selected="selected" disabled="disabled">Semester</option>
                        <option :value="'Fall'">Fall</option>
                        <option :value="'Winter'">Winter</option>
                        <option :value="'Spring'">Spring</option>
                        <option :value="'Summer'">Summer</option>
                      </select>
                      <label for="course_semester">Semester</label>
                    </div>
                    <div class="form_elem">
                      <select id="course_year" v-model="newCourse.term.year">
                        <option value="" selected="selected" disabled="disabled">Year</option>
                        <option :value="2020">2020</option>
                        <option :value="2019">2019</option>
                        <option :value="2018">2018</option>
                        <option :value="2017">2017</option>
                      </select>
                      <label for="course_year">Year</label>
                    </div>
                  </div>

                  <h3>Course Type</h3>
                  <p v-if="userHasPaid === false">
                    You currently have a <b>free trial account</b> and can only add trial courses right now.
                  </p>
                  <div class="form_options">
                    <input type="radio" id="newTrialCourse" v-model="newCourse.licensed" :value=false />
                    <label for="newTrialCourse">Trial Course</label>
                  </div>
                  <div class="form_options" v-if="userHasPaid">
                    <input type="radio" id="newLicensedCourse" v-model="newCourse.licensed" :value=true />
                    <label for="newLicensedCourse">Licensed Course</label>
                  </div>
                  <div class="form_options" v-else>
                    <input type="radio" id="licensedCourse_disabled" name="courseType" disabled="disabled" />
                    <label for="licensedCourse_disabled">Licensed Course</label>
                  </div>
                </div>
                <div v-else-if="formResponse[0]==='Convert a trial course' && userHasPaid">
                  <p>It looks like you have some trial courses set up already. Which one do you want to convert into a licensed course?</p>
                  <div class="form_options" v-for="course in unLicensedCourses">
                    <input type="radio" :id="'convert-license-' + course.id" v-model="courseToLicense" :value="course.id">
                    <label :for="'convert-license-' + course.id">{{course.name}}, {{course.term.name}} {{course.term.year}}</label>
                  </div>
                </div>
                <div v-else>
                  <p>You currently have a <b>free trial account</b> and cannot convert trial courses into licensed ones right now. </p>
                  <p>Try creating a new course instead! </p>
                </div>
              </template>
            </formContainer>
          </form>
        </template>
        <template slot="submit-button">
          <slot name="submit-button">
            <button class="action" type="button" @click.prevent="addCourse()">Add course</button>
          </slot>
        </template>
      </buttonModal>



      <h3>Copy an existing course</h3>
      <p>If you like your setup from a previous course and would like to
        duplicate it instead of starting from scratch, we can also
        help you copy an existing course:
      </p>
      <buttonModal button_class="action secondary" ref="buttonModal_copy">
        <template slot="button-text">Request a copy</template>
        <template slot="heading">Copy a past course</template>
        <template slot="content">
          <div>
            <h2>Request a copy of an existing course</h2>
            <p>Which existing course would you like to copy?</p>
            <form>
              <div class="form_options" v-for="course in currentAndPastCourses">
                <input type="radio" :id="'copy-' + course.id" v-model="copyRequest.course" :value="course.id"></input>
                <label :for="'copy-' + course.id">{{course.name}}, {{course.term.name}} {{course.term.year}}</label>
              </div>
              <br>
              <p>
                <b>Please note that your copy will be a trial course by default.</b>
                You will need to add more licensed courses to your account in order to convert it to a licensed course.
              </p>
              <p>Are there any additional notes you would like us to know?</p>
              <div class='form_elem'>
                <textarea v-model="copyRequest.notes"></textarea>
                <label>Additional notes</label>
              </div>
              <p>You will receive an email confirmation of your request after submitting, and a GradeCraft support staff member will reach out to you within 24 hours, Monday&ndash;Friday, 9am&ndash;5pm EST.</p>
              <button class='action' type="button" @click.prevent="courseCopyRequest()">Submit request</button>
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
    formContainer: () => VComponents.get('vue/components/formContainer'),
    datePicker: () => VComponents.get('vue/components/datePicker'),
  },
  data() {
    return {
      termYear: [],
      termName: [],
      formQuestion: ["Create a new course", "Convert a trial course"],
      formResponse: ["Create a new course"],
      courseToLicense: "",
      newCourse: {
        id: "",
        name: "",
        number: "",
        role: "Instructor",
        term: {
          name: "",
          year: "",
          start: "",
          end: ""
        },
        licensed: false
      },
      newCourseErrors: [],
      copyRequest: {
        course: [],
        notes: ""
      }
    }
  },
  computed: {
    currentCourses(){
      return this.$store.getters.currentCourseMembership;
    },
    pastCourses(){
      return this.$store.getters.pastCourseMembership;
    },
    currentAndPastCourses(){
      var courses = this.currentCourses.concat(this.pastCourses);
      return courses
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
    unLicensedCourses(){
      return this.$store.getters.unLicensedCourseMembership;
    },
    courseTermYear(){
      return this.pastCourses.map(courseMembership => courseMembership.term.year)
    },
    courseTermName(){
      return this.pastCourses.map(courseMembership => courseMembership.term.name)
    },
    userHasPaid(){
      return this.$store.getters.userHasPaid;
    }
  },
  methods: {
    updateStartDate(date){
      this.newCourse.term.start = date;
    },
    updateEndDate(date){
      this.newCourse.term.end = date;
    },
    addCourse(){
      var response = this.formResponse[0];
      if( response == "Create a new course"){
        var errors = this.checkAddCourseForm()

        if(!errors.length){
          this.$store.dispatch('addNewCourse', this.newCourse)
          this.$refs.buttonModal_add.toggleModalState()
        }
      }
      else{
        this.$store.dispatch('licenseCourse', this.courseToLicense)
        this.$refs.buttonModal_add.toggleModalState()
      }
    },
    checkAddCourseForm(){
      this.newCourseErrors = []

      if(!this.newCourse.name || !this.newCourse.number){
        this.newCourseErrors.push("Missing input for required fields")
      }
      return this.newCourseErrors
    },
    courseCopyRequest(){
      this.$refs.buttonModal_copy.toggleModalState()
    }
  }
}
`</script>
