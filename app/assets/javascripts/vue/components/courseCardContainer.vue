<template>
  <div>
    <div class="content_block intro">
      <h1>My Dashboard</h1>

      <guideMessage v-if="!getUserOnboardingStatus">
        <p>Hello, {{ getUserFirstName }}, and welcome to your GradeCraft dashboard! </p>
        <p>As your Guide, I’m here to help orient you in the many opportunities this tool offers. Look for my messages if you want some tips on how to use our features! </p>
      </guideMessage>
      <guideMessage v-else>
        <p>Welcome back to your GradeCraft dashboard, {{ getUserFirstName }}!</p>
        <p>As your Guide, I’m here to help orient you in the many opportunities this tool offers. Look for my messages if you want some tips on how to use our features! </p>
      </guideMessage>
    </div>

    <div class="content_block">
      <h2 class="unspace-top">Current Courses</h2>
      <div class="course_box" v-if="currentCourses.length">
        <courseCard v-for="course in currentCourses" :key="course.id"  :course="course" status="published"></courseCard>
      </div>
      <div class="course_box" v-else>
        <div class="course_card empty">
          <p><em>You don't have any published, active courses!</em></p>
        </div>
      </div>
    </div>

    <div class="content_block" v-if="userIsInstructor && unpublishedCourses.length">
      <h2 class="unspace-top">Unpublished Courses</h2>
      <div class="course_box" v-if="unpublishedCourses.length">
        <courseCard v-for="course in unpublishedCourses" :key="course.id" :course="course" status="unpublished"></courseCard>
      </div>
      <div class="course_box" v-else>
        <div class="course_card empty">
          <p><em>You don't have any unpublished courses</em></p>
        </div>
      </div>
    </div>

    <div class="content_block" v-if="pastCourses.length">
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
          <span v-for="year in courseTermYear" :key="year">
            <input :id="year" type="checkbox" v-model="termYear" :value="year"/>
            <label :for="year">{{year}}</label>
          </span>
        </div>
        <div>
          <span v-for="term in courseTermName" :key="term">
            <input :id="term" type="checkbox" v-model="termName" :value="term"/>
            <label :for="term">{{term}}</label>
          </span>
        </div>
      </div>
      <div class="course_box">
        <courseCard v-for="course in filteredPastCourses" :key="course.id" :course="course" status="past"></courseCard>
      </div>
    </div>

    <div class="content_block bg-green_mint" v-if="userIsInstructor">
      <h2>Add a New Course</h2>

      <p v-if="userHasPaid">
        With your
        <b>licensed account,</b>
        you can explore all GradeCraft has to offer and <b>create licensed courses.</b> <br />
        Licensed courses have the ability to:
      </p>
      <p v-else>
        With your
        <b>free trial account,</b>
        you can explore GradeCraft as much as you’d like! <br />
        The only things you can’t do are:
      </p>

      <ul>
        <li>Integrate with other tools (like Canvas or Moodle)</li>
        <li>Import or add other users (such as assistants and students)</li>
      </ul>

      <p v-if="userHasPaid">
        Your account license allows you <b>___2___ licensed courses,</b> active until ___May 14, 2019___.
      </p>
      <p v-else>
        Feel free to create as many trial courses as you need to discover what our tool can do for you and your students:
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
                  <div class="flex-2 form_pair">
                    <div class="form_elem">
                      <input type="text" v-model="newCourse.number" id="course_number" required="required" placeholder="Your course number" />
                      <label for="course_number">Course #</label>
                    </div>
                    <div class="form_elem">
                      <input type="text" v-model="newCourse.name" id="course_name" required="required" placeholder="Your course name" />
                      <label for="course_name">Course name</label>
                    </div>
                    <div class="form_elem">
                      <flat-pickr v-model="newCourse.term.start" :config="config" placeholder="Course start date" id="course_start" class="calendar"></flat-pickr>
                      <label for="course_start">Course start date</label>
                    </div>
                    <div class="form_elem">
                      <flat-pickr v-model="newCourse.term.end" :config="config" placeholder="Course end date" id="course_end" class="calendar"></flat-pickr>
                      <label for="course_end">Course end date</label>
                    </div>

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
                  <div class="form_options" v-for="course in unLicensedCourses" :key="course.id" >
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

      <div v-if="allCourses.length">
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
                <div class="form_options" v-for="course in currentAndPastCourses" :key="course.id" >
                  <input type="radio" :id="'copy-' + course.id" v-model="copyCourseID" :value="course.id"></input>
                  <label :for="'copy-' + course.id">{{course.name}}, {{course.term.name}} {{course.term.year}}</label>
                </div>
                <br>
                <p>
                  <b>Please note that your copy will be a trial course by default.</b>
                  You will need to add more licensed courses to your account in order to convert it to a licensed course.
                </p>
                <button class='action' type="button" @click.prevent="courseCopyRequest()">Submit request</button>
              </form>
            </div>
          </template>
        </buttonModal>
      </div>

      <div v-if="userHasPaid == false">
        <h3>Upgrade your account</h3>
        <p>
          If you like what you see, you can
          <b>upgrade your account</b>
          with a license of your choice! Purchasing a license will allow you to integrate GradeCraft with other tools, and add users to your courses.
        </p>
        <p>
          <a href="https://gradecraft.com/licenses/" target="_blank">Learn more about licensing options</a> to see what’s best for you. We have options for Higher Ed, K–12, and entire schools or districts; but if you need a custom arrangement, we’re more than happy to help!
        </p>
        <button class="action secondary next">Upgrade my account</button>
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
    buttonModal: () => VComponents.get('vue/components/structure/buttonModal'),
    accordionComponent: () => VComponents.get('vue/components/structure/accordionComponent'),
    formContainer: () => VComponents.get('vue/components/formContainer'),
    VueFlatpickr
  },
  data() {
    return {
      config: {
        allowInput: true,
        enableTime: true,
        dateFormat: "D, M d, Y at h:i K",
        static: true,
      },
      newCourseStartDate: null,
      newCourseEndDate: null,
      termYear: [],
      termName: [],
      formQuestion: ["Create a new course", "Convert a trial course"],
      formResponse: ["Create a new course"],
      courseToLicense: "",
      newCourse: {
        name: "",
        number: "",
        role: "Instructor",
        term: {
          name: "",
          year: "",
          start: null,
          end: null
        },
        licensed: false
      },
      newCourseErrors: [],
      copyCourseID: ""
    }
  },
  created: function() {
    this.$store.dispatch("getCourseMemberships")
  },
  computed: {
    currentCourses(){
      return this.$store.state.user.courseMembership.filter( membership => {
        var today = new Date();
        var start = new Date(membership.term.start);
        var end = new Date(membership.term.end);

        if (today < start){return false;}
        if (today > end){return false;}

        return membership.published
      });
    },
    pastCourses(){
      return this.$store.state.user.courseMembership.filter( membership => {
        var today = new Date();
        var end = new Date(membership.term.end);
        if(today < end){return false;}

        return membership.published
      })
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
    allCourses(){
      var courses = this.currentAndPastCourses.concat(this.unpublishedCourses);
      return courses
    },
    unpublishedCourses(){
      return this.$store.state.user.courseMembership.filter( membership => {
        if(membership.licensed){return false;}
        return membership
      })
    },
    unLicensedCourses(){
      return this.$store.state.user.courseMembership.filter( membership => {
        if(membership.licensed){return false;}
        return membership
      })
    },
    courseTermYear(){
      return this.pastCourses.map(courseMembership => courseMembership.term.year)
    },
    courseTermName(){
      return this.pastCourses.map(courseMembership => courseMembership.term.name)
    },
    userHasPaid(){
      return this.$store.state.user.hasPaid;
    },
    getUserFirstName(){
      return this.$store.state.user.firstName;
    },
    getUserOnboardingStatus(){
      return this.$store.getters.userOnboardingStatus;
    },
    userIsInstructor(){
      var courseRoles = this.$store.state.user.courseMembership.map( course => {
        return course.role
      })
      return courseRoles.includes('professor')
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
      this.$store.dispatch('copyCourse', this.copyCourseID)
    }
  }
}
`</script>
