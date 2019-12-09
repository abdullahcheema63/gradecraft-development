<template>
  <div>
    <div class="content_block intro">
      <h1>My Dashboard</h1>

      <guideMessage>
        <p>
          Welcome <span v-if="hasSeenOnboarding">back</span> to your GradeCraft dashboard, {{ userFirstName }}!
        </p>
        <p>
          Look for my messages if you want some tips on how to use GradeCraft features!
          You can also <a @click="showOnboardingModal();">review our onboarding slides</a> at any time.
        </p>
      </guideMessage>

      <modalComponent v-if="onboarding" :modalState="modalState" @close="toggleModalState(); sawOnboarding();" class="component_container onboarding">
        <template slot="heading">Welcome to GradeCraft!</template>
        <template slot="content">
          <vue-slick :options="slickOptions" class="onboarding_slides">
            <div class="slides student_1">
              <div></div>
              <div>
                <h2>Hey there, {{userFirstName}}!</h2>
                <p>
                  Welcome to GradeCraft! Make the most of your gameful course:
                </p>
                <ul class="pink_dots">
                  <li>Build up points from zero to the grade you want</li>
                  <li>Make assignment choices that work for you</li>
                  <li>Learn from quick, clear feedback and analytics</li>
                  <li>Let yourself fail and try again</li>
                </ul>
              </div>
            </div>
            <div class="slides student_2">
              <div></div>
              <div>
                <h2>Earn up</h2>
                <p>
                  Start from zero and earn your way up to the grade you want to get. Your final grade is independent from your peers’ grades.
                </p>
              </div>
            </div>
            <div class="slides student_3">
              <div></div>
              <div>
                <h2>Plan your path</h2>
                <p>
                  Plan out your assignments with the Points Planner. Choose assignments that match your goals as well as the skills and topics you're most interested in.
                </p>
              </div>
            </div>
            <div class="slides student_4">
              <div></div>
              <div>
                <h2>Track your progress</h2>
                <p>
                  Keep track of your progress with analytics and clear, timely, and transparent feedback from your instructors.
                </p>
              </div>
            </div>
            <div class="slides student_5">
              <div></div>
              <div>
                <h2>Try, try again!</h2>
                <p>
                  Gameful courses support risk-taking. If you get a low score on an assignment, look for ways to recover points&mdash;like resubmitting assignments multiple times, or choosing extra assignments to earn more points toward your goal.
                </p>
                <h3>Ready to go?</h3>
                <button @click="toggleModalState" type="button" class="action" style="margin-top: 0.75em;">Let’s get started!</button>
              </div>
            </div>
          </vue-slick>
        </template>
        <template slot="cancel-link"> &nbsp; </template>
      </modalComponent>
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
                Published courses are visible to students, observers, assistants, and instructors added to each course.
              </p>
              <div class="course_box" v-if="publishedCourses.length">
                <courseCard v-for="course in publishedCourses" :key="course.id" :course="course" status="published"></courseCard>
              </div>

              <div class="course_box" v-else>
                <div class="course_card empty">
                  <p><em>You don’t have any published courses right now!</em></p>
                </div>
              </div>
            </template>
          </accordionComponent>

          <accordionComponent accordion_content="bg-grey_barely" :open_default="true" v-if="userIsGSI">
            <template slot="heading">Unpublished Courses</template>
            <template slot="content">
              <p class="unspace-bottom">
                <br />
                Unpublished courses are hidden from students and observers, but can be seen and edited by assistants and instructors.
              </p>
              <div v-if="unpublishedCourses.length">
                <div class="course_box" v-if="unpublishedCourses.length">
                  <courseCard v-for="course in unpublishedCourses" :key="course.id" :course="course" status="unpublished"></courseCard>
                </div>
              </div>
              <div class="course_box" v-else>
                <div class="course_card empty">
                  <p><em>You don’t have any unpublished courses right now!</em></p>
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
                    <input type="search" v-model="searchPastCourses" id="searchPastCourses" placeholder="Search past courses">
                    <label for="searchPastCourses">Search courses</label>
                  </div>
                </div>
              </div>
              <div class="course_box" v-if="filteredPastCourses.length">
                <courseCard v-for="course in filteredPastCourses" :key="course.id" :course="course" status="past"></courseCard>
              </div>
              <div class="course_box" v-else>
                <div class="course_card empty">
                  <p><em>Sorry, there are no matching search results!</em></p>
                </div>
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
    modalComponent: () => VComponents.get('vue/components/structure/modalComponent'),
    vueSlickCarousel
  },
  data() {
    return {
      showOnboarding: false,
      slickOptions: {
        dots: true,
        prevArrow: '<button class="slick-prev" aria-label="Previous" type="button"> </button>',
        nextArrow: '<button class="slick-next" aria-label="Next" type="button"> </button>',
      },
      tabBarOption: ["Current", "Past"],
      tabSection: ["Current"],
      config: {
        allowInput: true,
        enableTime: true,
        dateFormat: "D, M d, Y at h:i K",
        static: true,
      },
      searchPastCourses: "",
      termYear: [],
      termName: [],
      modalState: true,
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
      return allPastCourses.filter(this.filterPastCourses)
    },
    courseTermYear(){
      return new Set(this.pastCourses.map(course => {
        if(course.term.year) {return course.term.year }
      }))
    },
    courseTermName(){
      return new Set(this.pastCourses.map(course => {
        if (course.term.name.length) {
          return course.term.name}
      }))
    },
    userFirstName(){
      return this.$store.state.user.firstName;
    },
    onboarding(){
      if(!this.hasSeenOnboarding){
        return true
      }
      else if(this.showOnboarding === false) {
        return false
      }
      else{
        return true
      }
    },
    hasSeenOnboarding(){
      return this.$store.getters.hasSeenOnboarding;
    },
  },
  methods: {
    filterPastCourses(course){
      if (this.searchPastCourses){
        var name = course.name.toLowerCase()
        var number = course.number.toLowerCase()
        if(!(name.includes(this.searchPastCourses.toLowerCase()) || number.includes(this.searchPastCourses.toLowerCase())) ){return false}
      }
      if(this.termName.length){
        if (!(this.termName.includes(course.term.name))) {return false}
      }
      if(this.termYear.length){
        if (!(this.termYear.includes(course.term.year))) {return false}
      }
      return course
    },
    close() {
      this.toggleModalState()
    },
    toggleModalState(){
      this.modalState = !this.modalState
    },
    sawOnboarding(){
      if(!this.hasSeenOnboarding){
        this.$store.dispatch('seenOnboarding')
      }
    },
    showOnboardingModal(){
      this.modalState = true
      this.showOnboarding = true
    }
  }
}
`</script>
