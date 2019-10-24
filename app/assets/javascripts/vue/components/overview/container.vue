<template>
  <div>
    <div class="content_block intro">
      <h1>My Dashboard</h1>

      <guideMessage>
        <p>
          Welcome <span v-if="!getUserOnboardingStatus">back</span> to your GradeCraft dashboard, {{ getUserFirstName }}!
        </p>
        <p v-if="userIsInstructor">
          I’m here to help you as you set up your course. Look for my messages if you want some tips on how to use GradeCraft features!
        </p>
        <p v-else>
          Look for my messages if you want some tips on how to use GradeCraft features!
        </p>
      </guideMessage>
    </div>

    <tabContainer>
      <template slot="tabBarNav">
        <div v-for="option in tabBarOption">
          <input type="radio" :id="option" :value="option" v-model="tabSection[0]" name="tab_group_1" />
          <label :for="option">{{option}}</label>
        </div>
      </template>
      <template slot="tabSections">
        <div v-if="tabSection[0]==='Current'">
          <div class="content_block" v-if="userIsInstructor">
            <div class="p_button">
              <p>
                This section has all your current courses, including those that other instructors or course managers may share with you. You can add a new course, and publish or unpublish courses at any time.
              </p>
              <buttonModal button_class="action" ref="buttonModal_add">
                <template slot="button-text">Add a course</template>
                <template slot="heading">Add a course</template>
                <template slot="content">
                  <h2>Let’s add a new course!</h2>
                  <h4>Essential Course Info</h4>
                  <form>
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
                        <flat-pickr v-model="newCourse.term.start" :config="config" placeholder="Course start date" id="course_start" class="calendar" autocomplete="off"></flat-pickr>
                        <label for="course_start">Course start date</label>
                      </div>
                      <div class="form_elem">
                        <flat-pickr v-model="newCourse.term.end" :config="config" placeholder="Course end date" id="course_end" class="calendar" autocomplete="off"></flat-pickr>
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

                    <button class="action" type="button" @click.prevent="addCourse()">Add course</button>
                  </form>
                </template>
              </buttonModal>
            </div>
          </div>

          <div class="content_block" v-if="userIsStudent">
            <p>
              This section includes your current courses.
            </p>
            <div class="course_box">
              <courseCard v-for="course in publishedCourses" :key="course.id" :course="course" status="published"></courseCard>
            </div>
            <div class="course_box" v-if="unpublishedCourses.length">
              <courseCard v-for="course in unpublishedCourses" :key="course.id" :course="course" status="unpublished"></courseCard>
            </div>
          </div>

          <accordionComponent accordion_content="bg-grey_barely" :open_default="true" v-if="userIsInstructor || userIsGSI">
            <template slot="heading">Published Courses</template>
            <template slot="content">
              <p class="unspace-bottom">
                <br />
                Published courses are visible to all users added to each course.
              </p>
              <div class="course_box" v-if="publishedCourses.length">
                <courseCard v-for="course in publishedCourses" :key="course.id" :course="course" status="published"
                v-on:copyCourseForm='openCopyCourseForm($event)' v-on:openDeleteCourseModal='openDeleteCourseModal($event)'
                v-on:archiveCourseModal='openArchiveCourseModal($event)' v-on:unpublishCourseModal='openUnpublishCourseModal($event)'></courseCard>
              </div>

              <div class="course_box" v-else>
                <div class="course_card empty">
                  <p><em>You don't have any published courses right now!</em></p>
                </div>
              </div>
            </template>
          </accordionComponent>

          <modalComponent v-if="copyCourseForm" :modalState="modalState" @close="toggleModalState" class="component_container">
            <template slot="heading">Copy a course</template>
            <template slot="content">
              <h2>You’re about to copy __Course #, Name, Semester + Yr__</h2>
              <h4>Essential Course Info</h4>
              <p>
                You can update this info now or do so later:
              </p>
            </template>
            <template slot="submit-button">
              <button type="button" class="action">Copy</button>
            </template>
          </modalComponent>

          <modalComponent v-if="deleteCourseModal" :modalState="modalState" @close="toggleModalState" class="component_container">
            <template slot="heading">Delete</template>
            <template slot="content">hate me</template>
            <template slot="submit-button">hate</template>
          </modalComponent>

          <modalComponent v-if="archiveCourseModal" :modalState="modalState" @close="toggleModalState" class="component_container">
            <template slot="heading">Archive</template>
            <template slot="content">respect me</template>
            <template slot="submit-button">respect</template>
          </modalComponent>

          <modalComponent v-if="unpublishCourseModal" :modalState="modalState" @close="toggleModalState" class="component_container">
            <template slot="heading">Unpublish</template>
            <template slot="content">fear me</template>
            <template slot="submit-button">fear</template>
          </modalComponent>


          <accordionComponent accordion_content="bg-grey_barely" :open_default="true" v-if="userIsInstructor || userIsGSI">
            <template slot="heading">Unpublished Courses</template>
            <template slot="content">
              <p class="unspace-bottom">
                <br />
                Unpublished courses are hidden from students and observers, but visible to and editable by GSIs and instructors.
              </p>
              <div v-if="userIsInstructor && unpublishedCourses.length">
                <div class="course_box" v-if="unpublishedCourses.length">
                  <courseCard v-for="course in unpublishedCourses" :key="course.id" :course="course" status="unpublished"></courseCard>
                </div>
              </div>
              <div class="course_box" v-else>
                <div class="course_card empty">
                  <p><em>You don't have any unpublished courses right now!</em></p>
                </div>
              </div>
            </template>
          </accordionComponent>
        </div>

        <div v-if="tabSection[0]==='Archived'">
          <div class="content_block">
            <p>
              Your archive includes any course in which you had a role of instructor.
            </p>
            <ul class="pink_dots">
              <li>
                <b>You can’t make changes to archived courses. </b>
              </li>
              <li>
                If you like how a course was set up and want to re-use it, you can copy it.
              </li>
              <li>
                If you need to unarchive a course, please email us at <a href="mailto:help@gradecraft.com">help@gradecraft.com</a>
              </li>
            </ul>
            <div v-if="archivedCourses.length">
              <div class="table_functions">
                <div class="filter_box">
                  <p><strong>Select which filters you want to apply:</strong></p>
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
                <div class="search_box">
                  <div class="form_elem">
                    <input type="search" id="searchArchivedCourses" placeholder="Search archived courses">
                    <label for="searchArchivedCourses">Search courses</label>
                  </div>
                </div>
              </div>

              <div class="course_box">
                <courseCard v-for="course in archivedCourses" :key="course.id" :course="course" status="archived"></courseCard>
              </div>
            </div>
            <div class="course_box" v-else>
              <div class="course_card empty">
                <p><em>You don’t have any archived courses to view</em></p>
              </div>
            </div>
          </div>
        </div>

        <div v-if="tabSection[0]==='Past'">
          <div class="content_block">
            <p>
              This section includes any course in which you had a role of student, observer, or GSI. You can’t make changes to past courses but you can review them.
            </p>

            <div v-if="pastCourses.length">
              <div class="table_functions">
                <div class="filter_box">
                  <p><strong>Select which filters you want to apply:</strong></p>
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
                <div class="search_box">
                  <div class="form_elem">
                    <input type="search" id="searchPastCourses" placeholder="Search past courses">
                    <label for="searchPastCourses">Search courses</label>
                  </div>
                </div>
              </div>
              <div class="course_box" v-if="filteredPastCourses.length">
                <courseCard v-for="course in filteredPastCourses" :key="course.id" :course="course" status="past"></courseCard>
              </div>
            </div>
            <div class="course_box" v-else>
              <div class="course_card empty">
                <p><em>You don't have any past courses to view</em></p>
              </div>
            </div>
          </div>
        </div>
      </template>
    </tabContainer>

  </div>
</template>

<!-- have to set lang=coffee so rails-vue-loader can work -->
<!-- adding back ticks ` escapes coffeescript to js -->
<script lang='coffee'>`
module.exports = {
  name: 'container',
  components: {
    courseCard: () => VComponents.get('vue/components/overview/courseCard'),
    pastCourse: () => VComponents.get('vue/components/pastCourse'),
    guideMessage: () => VComponents.get('vue/components/structure/guideMessage'),
    buttonModal: () => VComponents.get('vue/components/structure/buttonModal'),
    modalComponent: () => VComponents.get('vue/components/structure/modalComponent'),
    accordionComponent: () => VComponents.get('vue/components/structure/accordionComponent'),
    formContainer: () => VComponents.get('vue/components/formContainer'),
    tabContainer: () => VComponents.get('vue/components/structure/tabContainer'),
    VueFlatpickr
  },
  data() {
    return {
      tabSection: ["Current"],
      config: {
        allowInput: true,
        enableTime: true,
        dateFormat: "D, M d, Y at h:i K",
        static: true,
      },
      copyCourseForm: false,
      deleteCourseModal: false,
      archiveCourseModal: false,
      unpublishCourseModal: false,
      modalState: true,
      copyingCourse: false,
      creatingCourse: false,
      newCourseStartDate: null,
      newCourseEndDate: null,
      termYear: [],
      termName: [],
      formQuestion: ["Create a new course", "Copy an existing course", "Convert a trial course"],
      formResponse: ["Create a new course"],
      courseToSubscribe: "",
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
        subscribed: false
      },
      newCourseErrors: [],
      copyCourseID: ""
    }
  },
  created: function() {
    this.$store.dispatch("getCourseMemberships")
  },
  computed: {
    tabBarOption(){
      if (this.userIsStudent) {
        var options = ["Current", "Past"]
      }
      else if ( this.userIsStudent && this.userIsInstructor ){
        var options = ["Current", "Archived", "Past"]
      }
      else {
        var options = ["Current", "Archived"]
      }
      return options
    },
    currentCourses(){
      return this.$store.state.user.courseMembership.filter( course => {
        return course.active
      });
    },
    publishedCourses(){
      return this.currentCourses.filter( course => {
        return course.published
      });
    },
    unpublishedCourses(){
      return this.currentCourses.filter( course => {
        return !course.published
      });
    },
    archivedCourses(){
      return this.$store.state.user.courseMembership.filter( course => {
        return !course.active
      });
    },
    pastCourses(){
      return this.$store.state.user.courseMembership.filter( course => {
        return !(course.active)
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
    courseTermYear(){
      return new Set(this.pastCourses.map(courseMembership => courseMembership.term.year))
    },
    courseTermName(){
      return new Set(this.pastCourses.map(courseMembership => courseMembership.term.name))
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
    },
    userIsStudent(){
      var courseRoles = this.$store.state.user.courseMembership.map( course => {
        return course.role
      })
      return courseRoles.includes('Student')
    },
    userIsGSI(){
      var courseRoles = this.$store.state.user.courseMembership.map( course => {
        return course.role
      })
      return courseRoles.includes('gsi')
    },
    copyError(){
      return this.$store.state.courseCopyError
    },
    courseCreationError(){
      return this.$store.state.courseCreationError
    },
    modalClass() {
      if (this.modalState) {
        return 'is-open';
      }
      return 'is-closed';
    }
  },
  methods: {
    openCopyCourseForm(course){
      console.log("copy course form course: ", course)
      this.copyCourseForm = true
      this.modalState = true
    },
    openDeleteCourseModal(course){
      console.log("delete course form course: ", course)
      this.deleteCourseModal = true
      this.modalState = true
    },
    openArchiveCourseModal(course){
      console.log("archive course form course: ", course)
      this.archiveCourseModal = true
      this.modalState = true
    },
    openUnpublishCourseModal(course){
      console.log("unpublish course form course: ", course)
      this.unpublishCourseModal = true
      this.modalState = true
    },
    addCourse(){
      var errors = this.checkAddCourseForm()

      if(!errors.length){
        this.creatingCourse = true
        this.$store.dispatch('addNewCourse', this.newCourse)
      }
    },
    close() {
      this.toggleModalState()
    },
    toggleModalState(){
      this.modalState = !this.modalState
      this.copyCourseForm = false
      this.deleteCourseModal = false
      this.archiveCourseModal = false
      this.unpublishCourseModal = false
    },
    checkAddCourseForm(){
      this.newCourseErrors = []

      if(!this.newCourse.name || !this.newCourse.number){
        this.newCourseErrors.push("Missing input for required fields")
      }
      return this.newCourseErrors
    },
  }
}
`</script>
