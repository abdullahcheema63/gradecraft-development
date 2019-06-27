<template>
  <div>
    <div class="content_block intro">
      <h1>My Dashboard</h1>
      <guideMessage>
        <p>Welcome back, {{ getUserFirstName }}!</p>
        <p>As an Awesome Admin, you probably don’t need much guidance from me. Nevertheless, I’m here to help orient you, and you can see what I say to instructors and students. </p>
      </guideMessage>

      <newActivity></newActivity>
    </div>

    <tabContainer>
      <template slot="tabBarNav">
        <div v-for="option in tabBarOption">
          <input type="radio" :id="option" :value="option" v-model="tabSection[0]" name="tab_group_1" />
          <label :for="option">{{option}}</label>
        </div>
      </template>
      <template slot="tabSections">
        <div v-if="tabSection[0]==='Courses'">
          <allCourseTable></allCourseTable>
        </div>

        <div v-if="tabSection[0]==='Instructors'">
          <allInstructorTable></allInstructorTable>
        </div>

        <div v-if="tabSection[0]==='Users'">
          <allUserTable></allUserTable>
        </div>

        <div v-if="tabSection[0]==='Institutions'">
          <allInstitutionTable></allInstitutionTable>
        </div>

        <div v-if="tabSection[0]==='Utilities'">
          <h2>Administrative Utilities</h2>
          <p>Most "Admin" options from the nav bar have been generally replaced by this overview page</p>
          <p>Admin abilites that are tied to a specifc course have been moved to "Course settings" "admin" tab</p>
          <ul>
            <li>__New__ Unlocks </li>
          </ul>
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
    guideMessage: () => VComponents.get('vue/components/guideMessage'),
    buttonModal: () => VComponents.get('vue/components/buttonModal'),
    accordionComponent: () => VComponents.get('vue/components/accordionComponent'),
    buttonDropdown: () => VComponents.get('vue/components/buttonDropdown'),
    tablePagination: () => VComponents.get('vue/components/tablePagination'),
    newActivity: () => VComponents.get('vue/components/admin/newActivity'),
    tabContainer: () => VComponents.get('vue/components/tabContainer'),
    allCourseTable: () => VComponents.get('vue/components/admin/allCourseTable'),
    allUserTable: () => VComponents.get('vue/components/admin/allUserTable'),
    allInstructorTable: () => VComponents.get('vue/components/admin/allInstructorTable'),
    allInstitutionTable: () => VComponents.get('vue/components/admin/allInstitutionTable'),
  },
  data() {
    return {
      tabBarOption: ["Courses", "Instructors", "Users", "Institutions", "Utilities"],
      tabSection: ["Courses"],
      courseToLicense: "",
      newCourse: {
        id: "",
        name: "",
        number: "",
        licensed: false,
        role: "admin",
        term: {
          name: "",
          year: "",
          start: "",
          end: ""
        },
      },
      newCourseErrors: [],
    }
  },
  created: function() {
    this.$store.dispatch("getCourseMemberships");
    this.$store.dispatch("getAllInstructors");
    this.$store.dispatch("getAllUsers");
    this.$store.dispatch("getAllInstitutions");
  },
  computed: {
    getUserFirstName(){
      return this.$store.getters.userFirstName;
    },
  },

  methods: {
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
  }
}
`</script>
