<template>
  <div>
    <div class="content_block intro">
      <h1>My Dashboard</h1>

      <guideMessage>
        <p>
          Welcome <span v-if="!getUserOnboardingStatus">back</span> to your GradeCraft dashboard, {{ userFirstName }}!
        </p>
        <p>
          I’m here to help you as you set up your courses. Look for my messages if you want some tips on how to use GradeCraft features!
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
          <div class="content_block">
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

          <accordionComponent accordion_content="bg-grey_barely" :open_default="true">
            <template slot="heading">Published Courses</template>
            <template slot="content">
              <p class="unspace-bottom">
                <br />
                Published courses are visible to all users added to each course.
              </p>
              <div class="course_box" v-if="publishedCourses.length">
                <courseCard v-for="course in publishedCourses" :key="course.id" :course="course" status="published"
                v-on:copyCourseForm='openCopyCourseForm($event)' v-on:deleteCourseModal='openDeleteCourseModal($event)'
                v-on:archiveCourseModal='openArchiveCourseModal($event)' v-on:unpublishCourseModal='openUnpublishCourseModal($event)'></courseCard>
              </div>

              <div class="course_box" v-else>
                <div class="course_card empty">
                  <p><em>You don't have any published courses right now!</em></p>
                </div>
              </div>
            </template>
          </accordionComponent>

          <accordionComponent accordion_content="bg-grey_barely" :open_default="true">
            <template slot="heading">Unpublished Courses</template>
            <template slot="content">
              <p class="unspace-bottom">
                <br />
                Unpublished courses are hidden from students and observers, but visible to and editable by GSIs and instructors.
              </p>
              <div v-if="unpublishedCourses.length">
                <div class="course_box" v-if="unpublishedCourses.length">
                  <courseCard v-for="course in unpublishedCourses" :key="course.id" :course="course" status="unpublished"
                  v-on:copyCourseForm='openCopyCourseForm($event)' v-on:deleteCourseModal='openDeleteCourseModal($event)'
                  v-on:archiveCourseModal='openArchiveCourseModal($event)' v-on:publishCourseModal='openPublishCourseModal($event)'></courseCard>
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
                <courseCard v-for="course in archivedCourses" :key="course.id" :course="course" status="archived"
                v-on:copyCourseForm='openCopyCourseForm($event)' v-on:deleteCourseModal='openDeleteCourseModal($event)'
                v-on:publishCourseModal='openPublishCourseModal($event)' v-on:unpublishCourseModal='openUnpublishCourseModal($event)'></courseCard>
              </div>
            </div>
            <div class="course_box" v-else>
              <div class="course_card empty">
                <p><em>You don’t have any archived courses to view</em></p>
              </div>
            </div>
          </div>
        </div>

        <modalComponent v-if="copyCourseForm" :modalState="modalState" @close="toggleModalState" class="component_container">
          <template slot="heading">Copy a course</template>
          <template slot="content">
            <div v-if="copyingCourse">
              <h3> yooo its copy time!! dance yeti dance!! </h3>
            </div>
            <h2>You’re about to copy {{this.selectedCourse.number}} {{this.selectedCourse.name}}, {{this.selectedCourse.term.name}} {{this.selectedCourse.term.year}}</h2>
            <h4>Essential Course Info</h4>
            <p>
              You can update this info now or do so later:
            </p>
          </template>
          <template slot="submit-button">
            <button type="button" class="action" @click="copyCourse(selectedCourse.id)">Copy</button>
          </template>
        </modalComponent>

        <modalComponent v-if="deleteCourseModal" :modalState="modalState" @close="toggleModalState" class="component_container">
          <template slot="heading">Delete Course Confirmation</template>
          <template slot="content">
            <div v-if="deletingCourse">
              <h3> yooo its chopping time!! dance yeti dance!! bye course!! see ya never!! </h3>
            </div>
            <h2>Please confirm you want to delete your course</h2>
            <p>
              You’re about to delete {{this.selectedCourse.number}} {{this.selectedCourse.name}}, {{this.selectedCourse.term.name}} {{this.selectedCourse.term.year}}.
              <br />
              <strong>This cannot be undone.</strong>
            </p>
          </template>
          <template slot="submit-button">
            <button type="button" class="action" style="margin-bottom: 1em;" @click="deleteCourse(selectedCourse.id)">Delete my course</button>
            <br />
          </template>
        </modalComponent>

        <modalComponent v-if="archiveCourseModal" :modalState="modalState" @close="toggleModalState" class="component_container">
          <template slot="heading">Archive Course Confirmation</template>
          <template slot="content">
            <h2>Please confirm you want to archive your course</h2>
            <p>
              You’re about to archive {{this.selectedCourse.number}} {{this.selectedCourse.name}}, {{this.selectedCourse.term.name}} {{this.selectedCourse.term.year}}.
              <br />
              <strong>You will not be able to unarchive it</strong> without emailing us at <a href="mailto:help@gradecraft.com">help@gradecraft.com</a>
            </p>
            <p>
              Archiving a course is useful when your term has ended and students are no longer active in GradeCraft.
            </p>
          </template>
          <template slot="submit-button">
            <button type="button" class="action" style="margin-bottom: 1em;" @click="archiveCourse(selectedCourse.id)">Archive my course</button>
            <br />
          </template>
        </modalComponent>

        <modalComponent v-if="unpublishCourseModal" :modalState="modalState" @close="toggleModalState" class="component_container">
          <template slot="heading">Unpublish Course Confirmation</template>
          <template slot="content">
            <h2>Please confirm you want to unpublish your course</h2>
            <p>
              You’re about to unpublish {{this.selectedCourse.number}} {{this.selectedCourse.name}}, {{this.selectedCourse.term.name}} {{this.selectedCourse.term.year}}.
              <br />
              It will be <strong>hidden from students and observers</strong> in the course, but remain visible to and editable by any GSIs and instructors in the course.
            </p>

            <p>
              Unpublishing a course is useful if you need to make significant changes during a term and just need to make it temporarily invisible when students are active in GradeCraft.
            </p>

            <!-- <p style="background: yellow;">
              FUTURE DEV CYCLE
              To E from S: The following p-tag is v-if conditional, to show for users if they're the one paying for the selected course.
            </p> -->
            <p>
              Unpublishing a course <strong>does not remove it from your subscription.</strong> You can <a href="/subscriptions">manage your subscription</a> if you want to make this change.
            </p>
          </template>
          <template slot="submit-button">
            <button type="button" class="action" style="margin-bottom: 1em;" @click="unpublishCourse(selectedCourse.id)">Unpublish my course</button>
            <br />
          </template>
        </modalComponent>

        <modalComponent v-if="publishCourseModal" :modalState="modalState" @close="toggleModalState" class="component_container">
          <template slot="heading">Publish Course Confirmation</template>
          <template slot="content">
            <h2>Please confirm you want to Publish your course</h2>
            <p>
              You’re about to Publish {{this.selectedCourse.number}} {{this.selectedCourse.name}}, {{this.selectedCourse.term.name}} {{this.selectedCourse.term.year}}.
              <br />
              add words for more betterness
            </p>

            <p>
              Publishing
            </p>
          </template>
          <template slot="submit-button">
            <button type="button" class="action" style="margin-bottom: 1em;" @click="publishCourse(selectedCourse.id)">Publish my course</button>
            <br />
          </template>
        </modalComponent>
      </template>
    </tabContainer>
  </div>
</template>
<script lang='coffee'>`
module.exports = {
  name: 'instructor',
  components: {
    courseCard: () => VComponents.get('vue/components/overview/courseCard'),
    accordionComponent: () => VComponents.get('vue/components/structure/accordionComponent'),
    buttonModal: () => VComponents.get('vue/components/structure/buttonModal'),
    modalComponent: () => VComponents.get('vue/components/structure/modalComponent'),
    formContainer: () => VComponents.get('vue/components/formContainer'),
    tabContainer: () => VComponents.get('vue/components/structure/tabContainer'),
    guideMessage: () => VComponents.get('vue/components/structure/guideMessage'),
    VueFlatpickr
  },
  data() {
    return {
      tabBarOption: ["Current", "Archived"],
      tabSection: ["Current"],
      config: {
        allowInput: true,
        enableTime: true,
        dateFormat: "D, M d, Y at h:i K",
        static: true,
      },
      selectedCourse: {},
      termYear: [],
      termName: [],
      newCourseErrors: [],
      newCourse: {
        name: "",
        number: "",
        role: "professor",
        term: {
          name: "",
          year: "",
          start: null,
          end: null
        },
        subscribed: false
      },
      copyCourseForm: false,
      copyingCourse: false,
      deleteCourseModal: false,
      deletingCourse: false,
      archiveCourseModal: false,
      unpublishCourseModal: false,
      publishCourseModal: false,
      modalState: true,
      copyingCourse: false,
      creatingCourse: false,
    }
  },
  created: function() {
    this.$store.dispatch("getCourseMemberships");
  },
  computed: {
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
    filteredArchivedCourses(){
      var allArchivedCourses = this.archivedCourses;
      return allArchivedourses.filter( course => {
          if (!(this.termYear.includes(course.term.year)) && this.termYear.length) {return false}
          if (!(this.termName.includes(course.term.name)) && this.termName.length) {return false}
          return true
      })
    },
    courseTermYear(){
      return new Set(this.archivedCourses.map(courseMembership => courseMembership.term.year))
    },
    courseTermName(){
      return new Set(this.archivedCourses.map(courseMembership => courseMembership.term.name))
    },
    userFirstName(){
      return this.$store.state.user.firstName;
    },
    getUserOnboardingStatus(){
      return this.$store.getters.userOnboardingStatus;
    },
  },
  methods: {
    openCopyCourseForm(course){
      console.log("copy course form course: ", course)
      this.selectedCourse = course
      this.copyCourseForm = true
      this.modalState = true
    },
    openDeleteCourseModal(course){
      console.log("delete course form course: ", course)
      this.selectedCourse = course
      this.deleteCourseModal = true
      this.modalState = true
    },
    openArchiveCourseModal(course){
      console.log("archive course form course: ", course)
      this.selectedCourse = course
      this.archiveCourseModal = true
      this.modalState = true
    },
    openUnpublishCourseModal(course){
      console.log("unpublish course form course: ", course)
      this.selectedCourse = course
      this.unpublishCourseModal = true
      this.modalState = true
    },
    openPublishCourseModal(course){
      console.log("publish course form course: ", course)
      this.selectedCourse = course
      this.publishCourseModal = true
      this.modalState = true
    },
    copyCourse(courseID){
      this.copyingCourse = true
      this.$store.dispatch('copyCourse', courseID)
    },
    unpublishCourse(courseID){
      this.$store.dispatch('unpublishCourse', courseID)
    },
    publishCourse(courseID){
      this.$store.dispatch('publishCourse', courseID)
    },
    archiveCourse(courseID){
      this.$store.dispatch('archiveCourse', courseID)
    },
    deleteCourse(courseID){
      this.deletingCourse = true
      this.$store.dispatch('deleteCourse', courseID)
    },
    addCourse(){
      var errors = this.checkAddCourseForm()

      if(!errors.length){
        this.creatingCourse = true
        this.$store.dispatch('addNewCourse', this.newCourse)
      }
    },
    checkAddCourseForm(){
      this.newCourseErrors = []

      if(!this.newCourse.name || !this.newCourse.number){
        this.newCourseErrors.push("Missing input for required fields")
      }
      return this.newCourseErrors
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
      this.publishCourseModal = false
    }
  }
}
`</script>
