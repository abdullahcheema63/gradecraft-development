<template>
  <div>
    <div class="content_block intro">
      <h1>My Dashboard</h1>
      <guideMessage>
        <p>Welcome back, {{ getUserFirstName }}!</p>
        <p>As an Awesome Admin, you probably don’t need much guidance from me. Nevertheless, I’m here to help orient you, and you can see what I say to instructors and students. </p>
      </guideMessage>

      <h2>New Activity</h2>
      <p>In the past 10 days: </p>
      <div class="flex-3">
        <div class="bg-blue_2">
          <h4>New User Accounts</h4>
          <p class="summary_data">
            <span class="lining_figures">{{newTrialUsers.length}}</span>
            free trial accounts
          </p>
          <p class="summary_data">
            <span class="lining_figures">{{newLicenseUsers.length}}</span>
            licensed accounts
          </p>
        </div>
        <div class="bg-blue_2">
          <h4>User Licenses</h4>
          <p class="summary_data">
            <span class="lining_figures">4</span>
            new licenses
          </p>
          <p class="summary_data">
            <span class="lining_figures">5</span>
            renewed licenses
          </p>
        </div>
        <div class="bg-blue_2">
          <h4>New Courses</h4>
          <p class="summary_data column-2">
            <span class="lining_figures">{{allNewCourses.length}}</span>
            total
          </p>
          <p class="summary_data column-2">
            <span class="lining_figures">{{newTrialCourses.length}}</span>
            free trial courses
          </p>
          <p class="summary_data column-2">
            <span class="lining_figures">Uh</span>
            copied
          </p>
          <p class="summary_data column-2">
            <span class="lining_figures">{{newLicenseCourses.length}}</span>
            licensed courses
          </p>
        </div>
      </div>
    </div>

    <accordionComponent>
      <template slot="heading">New courses</template>
      <template slot="content">
        <p>Courses created in the past 10 days</p>
        <div class="table_container">
          <table>
            <thead>
              <tr>
                <th>Course # </th>
                <th>Course Name </th>
                <th>Licensed </th>
                <th>Active </th>
                <th>Published </th>
                <th>Copied </th>
                <th>Instructor(s) </th>
                <th>Semester </th>
                <th>Year </th>
                <th>Created </th>
                <th>Actions </th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="course in allNewCourses" :key="course.id">
                <td><a href="#">{{course.id}}</a> </td>
                <td><a href="#">{{course.name}}</a> </td>
                <td><span :class="{checked: course.licensed}"></span> </td>
                <td><span :class="{checked: course.active}"></span> </td>
                <td><span :class="{checked: course.published}"></span> </td>
                <td><span :class="{checked: course.copied}"></span> </td>
                <td>
                  <ul>
                    <li v-for="instructor in course.instructors" :key="instructor.id">
                      <a :href="instructor.url">{{instructor.text}}</a>
                    </li>
                  </ul>
                </td>
                <td>{{course.term}}</td>
                <td>{{course.year}}</td>
                <td>{{course.created}}</td>
                <td>
                  <buttonDropdown>
                    <template slot="button_text">Options</template>
                    <template slot="content">
                      <ul>
                        <li><a :href="course.editURL">Edit</a> </li>
                        <li><a :href="course.copyURL">Copy</a> </li>
                        <li><a :href="course.copyStudentsURL">Copy + Students</a> </li>
                        <li><a>Delete (needs url link)</a> </li>
                      </ul>
                    </template>
                  </buttonDropdown>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        <tablePagination :items="allNewCourses" @paginate="paginateItems"></tablePagination>

        <a class="button action next" href="courses/new">Add a new course</a>
      </template>
    </accordionComponent>

    <accordionComponent>
      <template slot="heading">License expiration</template>
      <template slot="content">
        <p>User accounts that will expire within 30 days from today</p>
        <div class="table_container">
          <table>
            <thead>
              <tr>
                <th>First Name </th>
                <th>Last Name </th>
                <th>License Expiration </th>
                <th>Payment Method </th>
                <th># Active Courses </th>
                <th>Actions </th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="instructor in expiringLicenseInstructors" :key="instructor.id">
                <td><a href="#">{{instructor.firstName}}</a> </td>
                <td><a href="#">{{instructor.lastName}}</a> </td>
                <td>{{instructor.licenseExpires}} </td>
                <td>{{instructor.paymentMethod}} </td>
                <td>{{instructor.activeCoursesNumber}} </td>
                <td>
                  <div class="button-container">
                    <a class="button secondary" :href="'mailto:' + instructor.email" >Send email</a>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        <div class="table_pagination">
          <p>
            Results: <span class="displayed">3</span> of <span class="total">100</span>
          </p>
          <div>
            <button class="table_prev disabled"></button>
            <button class="active">1</button>
            <button>2</button>
            <button class="table_next"></button>
          </div>
        </div>
      </template>
    </accordionComponent>

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
          <h2>All Instructor Users</h2>
          <p>Manage instructor users and their licensed accounts.</p>
          <div class="table_functions">
            <div class="filter_box">
              <p>Select which filters you want to apply to the table below: </p>
              <div>
                <span>
                  <input id="licensed_acccounts" type="checkbox" value="licensed" v-model="showLicensedAccounts" />
                  <label for="licensed_acccounts">Licensed Accounts</label>
                </span>
                <span>
                  <input id="free_trial_accounts" type="checkbox" value="free" v-model="showFreeAccounts" />
                  <label for="free_trial_accounts">Free trial accounts</label>
                </span>
              </div>
            </div>
          </div>
          <div class="table_container">
            <table>
              <thead>
                <tr>
                  <th>First Name </th>
                  <th>Last Name </th>
                  <th>License Expiration </th>
                  <th>Payment Method </th>
                  <th>Account Type</th>
                  <th>Active Courses </th>
                  <th>Licensed Course </th>
                  <th># Students in Course </th>
                  <th>Actions </th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="instructor in allInstructors1" :key="instructor.id">
                  <td><a href="#">{{instructor.firstName}}</a> </td>
                  <td><a href="#">{{instructor.lastName}}</a> </td>
                  <td>{{instructor.licenseExpires}} </td>
                  <td>{{instructor.paymentMethod}} </td>
                  <td style="width: 100px;">{{instructor.accountType}} </td>
                  <template v-if="instructor.courses.length">
                    <td>
                      <ul>
                        <li v-for="course in instructor.courses" :key="course.id">
                          <a :href="course.changeCoursePath" class="table_truncate">{{course.name}}</a>
                        </li>
                      </ul>
                    </td>
                    <td>
                      <ul class="checked_list">
                        <li v-for="course in instructor.courses" :key="course.id">
                          <span :class="{checked: course.licensed}">&nbsp;</span>
                        </li>
                      </ul>
                    </td>
                    <td>
                      <ul class="student_list">
                        <li v-for="course in instructor.courses" :key="course.id">
                          {{course.studentCount}}
                        </li>
                      </ul>
                    </td>
                  </template>
                  <td>
                    <buttonDropdown>
                      <template slot="button_text">Options</template>
                      <template slot="content">
                        <ul>
                          <li>What options go in here? </li>
                        </ul>
                      </template>
                    </buttonDropdown>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
          <tablePagination :items="allInstructors1" @paginate="paginateItems"></tablePagination>
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
    tabContainer: () => VComponents.get('vue/components/tabContainer'),
    buttonDropdown: () => VComponents.get('vue/components/buttonDropdown'),
    tablePagination: () => VComponents.get('vue/components/tablePagination'),
    allCourseTable: () => VComponents.get('vue/components/admin/allCourseTable'),
    allUserTable: () => VComponents.get('vue/components/admin/allUserTable'),
    allInstitutionTable: () => VComponents.get('vue/components/admin/allInstitutionTable'),
  },
  data() {
    return {
      toggled: true,
      showFreeAccounts: false,
      showLicensedAccounts: false,
      currentPageItemMin: 0,
      currentPageItemMax: 10,
      tabBarOption: ["Courses", "Instructors", "Users", "Institutions", "Utilities"],
      tabSection: ["Courses"],
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
      allInstructorsOLD: [
        {
          userId: 50,
          email: "blah@test.com",
          firstName: "User",
          licensedAccount: false,
          lastName: "Free Trial",
          expirationDate: "",
          paymentMethod: "",
          accountType: "Free Trial",
          activeCoursesNumber: "1",
          activeCoursesList: [
            {
              courseName: "Active Course 1",
              courseLicensed: false,
              courseStudents: "10",
            },
          ],
        },
      ],
    }
  },
  created: function() {
    this.$store.dispatch("getCourseMemberships");
    this.$store.dispatch("getAllInstructors");
  },
  computed: {
    getUserFirstName(){
      return this.$store.getters.userFirstName;
    },
    filteredInstructors1(){
        var allInstructors = this.allInstructors1;
        return allInstructors.filter(this.filterByLicensedAccount)
    },
    expiringLicenseInstructors(){
      var allInstructors = this.allInstructors;
      return allInstructors.filter(this.filterExpiringInstructors)
    },
    allCourses(){
      return this.$store.state.allCourses;
    },
    allUsers(){
      return this.$store.state.allUsers;
    },
    allInstructors(){
      return this.$store.state.allInstructors
    },
    allInstructors1(){
      return this.filterAllInstructors(this.$store.state.allInstructors);
    },
    allNewCourses(){
      return this.filterNewCourses(this.allCourses)
    },
    newTrialCourses(){
      var allNewCourses = this.allNewCourses;
      return allNewCourses.filter( course => {
        if( course.licensed === false){return course}
        return false
        })
    },
    newLicenseCourses(){
      var allNewCourses = this.allNewCourses;
      return allNewCourses.filter( course => {
        if( course.licensed === true){return course}
        return false
        })
    },
    allNewUsers(){
      return this.filterNewUsers(this.allUsers)
    },
    newTrialUsers(){
      var allNewUsers = this.allNewUsers;
      return allNewUsers.filter( user => {
        if( user.license === "trial" ){return user}
        return false
      })
    },
    newLicenseUsers(){
      var allNewUsers = this.allNewUsers;
      return allNewUsers.filter( user => {
        if( user.license === "licensed" ){return user}
        return false
      })
    },
  },

  methods: {
    filterNewCourses(allCourses){
      var tenDaysAgo = new Date();
      tenDaysAgo.setDate(tenDaysAgo.getDate() - 100);
      return allCourses.filter( course => {
        if( course.created < tenDaysAgo ){return false}
        return course
      })
    },
    filterAllInstructors(allInstructors){
      return allInstructors.filter( instructor => {
        if( this.showFreeAccounts && instructor.accountType != "the best"){return false}
        if( this.showLicensedAccounts && instructor.accountType != "the best"){return false}
        return instructor
      })
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
    filterByLicensedAccount(user) {
      if (this.showLicensedAccounts && this.showFreeAccounts) {
        return user
      } else if (this.showLicensedAccounts && !user.licensedAccount) {
        return false
      } else if (this.showFreeAccounts && user.licensedAccount) {
        return false
      }
      return user
    },
    filterExpiringInstructors(instructor){
      var now = new Date();
      var expirationMax = now.setDate(now.getDate() + 30);
      var formattedDate = new Date(expirationMax);
      var formattedInstructorExpiration = new Date(instructor.licenseExpires);
      if (!instructor.licenseExpires) {
        return false
      } else if (new Date(instructor.licenseExpires) >= formattedDate) {
        return false
      }
      instructor.licenseExpires = formattedInstructorExpiration
      return instructor
    },
    filterNewUsers(allUsers){
      var tenDaysAgo = new Date();
      tenDaysAgo.setDate(tenDaysAgo.getDate() - 100);
      return allUsers.filter( user => {
        if( user.createdAt < tenDaysAgo ){ return false }
        return user
      })
    },
    paginateItems(itemRange){
      this.currentPageItemMin = itemRange.min - 1;
      this.currentPageItemMax = itemRange.max;
    }
  }
}
`</script>
