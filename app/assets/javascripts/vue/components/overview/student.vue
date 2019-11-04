<template>
  <div>
    <div class="content_block intro">
      <h1>My Dashboard</h1>

      <guideMessage>
        <p>
          Welcome <span v-if="!getUserOnboardingStatus">back</span> to your GradeCraft dashboard, {{ userFirstName }}!
        </p>
        <p>
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
          <div class="content_block">
            <p>
              This section includes your current courses.
            </p>

            <div class="course_box" v-if="!userIsGSI">
              <courseCard v-for="course in publishedCourses" :key="course.id" :course="course" status="published"></courseCard>
            </div>
            <div class="course_box" v-if="unpublishedCourses.length && !userIsGSI">
              <courseCard v-for="course in unpublishedCourses" :key="course.id" :course="course" status="unpublished"></courseCard>
            </div>
          </div>

          <accordionComponent accordion_content="bg-grey_barely" :open_default="true" v-if="userIsGSI">
            <template slot="heading">Published Courses</template>
            <template slot="content">
              <p class="unspace-bottom">
                <br />
                Published courses are visible to all users added to each course.
              </p>
              <div class="course_box" v-if="publishedCourses.length">
                <courseCard v-for="course in publishedCourses" :key="course.id" :course="course" status="published"></courseCard>
              </div>

              <div class="course_box" v-else>
                <div class="course_card empty">
                  <p><em>You don't have any published courses right now!</em></p>
                </div>
              </div>
            </template>
          </accordionComponent>

          <accordionComponent accordion_content="bg-grey_barely" :open_default="true" v-if="userIsGSI">
            <template slot="heading">Unpublished Courses</template>
            <template slot="content">
              <p class="unspace-bottom">
                <br />
                Unpublished courses are hidden from students and observers, but visible to and editable by GSIs and instructors.
              </p>
              <div v-if="unpublishedCourses.length">
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

<script lang='coffee'>`
module.exports = {
  name: 'student',
  components: {
    courseCard: () => VComponents.get('vue/components/overview/courseCard'),
    accordionComponent: () => VComponents.get('vue/components/structure/accordionComponent'),
    tabContainer: () => VComponents.get('vue/components/structure/tabContainer'),
    guideMessage: () => VComponents.get('vue/components/structure/guideMessage'),
  },
  data() {
    return {
      tabBarOption: ["Current", "Past"],
      tabSection: ["Current"],
      config: {
        allowInput: true,
        enableTime: true,
        dateFormat: "D, M d, Y at h:i K",
        static: true,
      },
      termYear: [],
      termName: [],
    }
  },
  created: function() {
    this.$store.dispatch("getCourseMemberships");
  },
  computed: {
    userIsGSI(){
      var courseRoles = this.$store.state.user.courseMembership.map( course => {
        return course.role
      })
      return courseRoles.includes('gsi')
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
    pastCourses(){
      return this.$store.state.user.courseMembership.filter( course => {
        return !(course.active)
      })
    },
    filteredPastCourses(){
      var allPastCourses = this.pastCourses;
      return allPastCourses.filter( course => {
          if (!(this.termYear.includes(course.term.year)) && this.termYear.length) {return false}
          if (!(this.termName.includes(course.term.name)) && this.termName.length) {return false}
          return true
      })
    },
    courseTermYear(){
      return new Set(this.pastCourses.map(courseMembership => courseMembership.term.year))
    },
    courseTermName(){
      return new Set(this.pastCourses.map(courseMembership => courseMembership.term.name))
    },
    userFirstName(){
      return this.$store.state.user.firstName;
    },
    getUserOnboardingStatus(){
      return this.$store.getters.userOnboardingStatus;
    },
  },
  methods: {
    close() {
      this.toggleModalState()
    },
    toggleModalState(){
      this.modalState = !this.modalState
    }
  }
}
`</script>
