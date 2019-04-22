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
            <span class="lining_figures">36</span>
            free trial accounts
          </p>
          <p class="summary_data">
            <span class="lining_figures">2</span>
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
            <span class="lining_figures">16</span>
            total
          </p>
          <p class="summary_data column-2">
            <span class="lining_figures">306</span>
            free trial courses
          </p>
          <p class="summary_data column-2">
            <span class="lining_figures">5</span>
            copied
          </p>
          <p class="summary_data column-2">
            <span class="lining_figures">6</span>
            licensed courses
          </p>
        </div>
      </div>
    </div>

    <accordionComponent>
      <template slot="heading">New courses</template>
      <template slot="content">
        <button class="action next">Add a new course</button>

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
                <th>Actions </th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td><a href="#">0123</a> </td>
                <td><a href="#">Course name</a> </td>
                <td><span class="checked"></span> </td>
                <td><span class="checked"></span> </td>
                <td><span class="checked"></span> </td>
                <td><span class="checked"></span> </td>
                <td><a href="#">Instructor name</a> </td>
                <td>Fall </td>
                <td>2018 </td>
                <td>
                  <div class="button-container">
                    <button type="button" class="secondary">Options</button>
                  </div>
                </td>
              </tr>
              <tr>
                <td><a href="#">0123</a> </td>
                <td><a href="#">Course name</a> </td>
                <td> </td>
                <td> </td>
                <td><span class="checked"></span> </td>
                <td> </td>
                <td><a href="#">Instructor name</a> </td>
                <td>Fall </td>
                <td>2018 </td>
                <td>
                  <div class="button-container">
                    <button type="button" class="secondary">Options</button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
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
              <tr>
                <td><a href="#">User first name</a> </td>
                <td><a href="#">User last name</a> </td>
                <td>Nov 22, 2020 </td>
                <td>Legacy </td>
                <td>1 </td>
                <td>
                  <div class="button-container">
                    <button type="button" class="secondary">Send email</button>
                  </div>
                </td>
              </tr>
              <tr>
                <td><a href="#">User first name</a> </td>
                <td><a href="#">User last name</a> </td>
                <td>Nov 22, 2020 </td>
                <td>OTT </td>
                <td>1 </td>
                <td>
                  <div class="button-container">
                    <button type="button" class="secondary">Send email</button>
                  </div>
                </td>
              </tr>
              <tr>
                <td><a href="#">User first name</a> </td>
                <td><a href="#">User last name</a> </td>
                <td>Nov 22, 2020 </td>
                <td>Stripe </td>
                <td>30 </td>
                <td>
                  <div class="button-container">
                    <button type="button" class="secondary">Send email</button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
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
          <h2>All Courses </h2>
          <p>Manage and view all courses&mdash;active and inactive, published and unpublished. </p>

          <div class="table_functions">
            <div class="filter_box">
              <p>Select which filters you want to apply to the table below: </p>
              <div>
                <span>
                  <input id="published" type="checkbox" value="published" />
                  <label for="published">Published</label>
                </span>
                <span>
                  <input id="unpublished" type="checkbox" value="unpublished" />
                  <label for="unpublished">Unpublished</label>
                </span>
                <span>
                  <input id="active" type="checkbox" value="active" />
                  <label for="active">Active</label>
                </span>
                <span>
                  <input id="inactive" type="checkbox" value="inactive" />
                  <label for="inactive">Inactive</label>
                </span>
              </div>
              <div>
                <span>
                  <input id="2018" type="checkbox" value="2018"/>
                  <label for="2018">2018</label>
                </span>
                <span>
                  <input id="2017" type="checkbox" value="2017"/>
                  <label for="2017">2017</label>
                </span>
                <span>
                  <input id="2016" type="checkbox" value="2016" />
                  <label for="2016">2016</label>
                </span>
                <span>
                  <input id="2015" type="checkbox" value="2015" />
                  <label for="2015">2015</label>
                </span>
                <span>
                  <input id="2014" type="checkbox" value="2014" />
                  <label for="2014">2014</label>
                </span>
              </div>
              <div>
                <span>
                  <input id="Fall" type="checkbox" value="Fall">
                  <label for="Fall">Fall</label>
                </span>
                <span>
                  <input id="Winter" type="checkbox" value="Winter">
                  <label for="Winter">Winter</label>
                </span>
                <span>
                  <input id="Spring" type="checkbox" value="Spring">
                  <label for="Spring">Spring</label>
                </span>
                <span>
                  <input id="Summer" type="checkbox" value="Summer">
                  <label for="Summer">Summer</label>
                </span>
              </div>
            </div>
            <div class="search_box">
              <div class="form_elem">
                <input type="search" id="search_courses" placeholder="Search all courses" />
                <label for="search_courses">Search courses</label>
              </div>
            </div>
          </div>
          <div class="table_container">
            <table>
              <thead>
                <tr>
                  <th>Course # </th>
                  <th>Course Name </th>
                  <th>Licensed </th>
                  <th>Active </th>
                  <th>Published </th>
                  <th>Instructor(s) </th>
                  <th># Students </th>
                  <th>Semester </th>
                  <th>Year </th>
                  <th>Actions </th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td><a href="#">0123</a> </td>
                  <td><a href="#">Course name</a> </td>
                  <td><span class="checked"></span> </td>
                  <td><span class="checked"></span> </td>
                  <td><span class="checked"></span> </td>
                  <td><a href="#">Instructor name</a> </td>
                  <td>10,000 </td>
                  <td>Fall </td>
                  <td>2018 </td>
                  <td>
                    <div class="button-container">
                      <button type="button" class="secondary">Download</button>
                      <button type="button" class="secondary">Options</button>
                    </div>
                  </td>
                </tr>
                <tr>
                  <td><a href="#">0123</a> </td>
                  <td><a href="#">Course name</a> </td>
                  <td><span class="checked"></span> </td>
                  <td><span class="checked"></span> </td>
                  <td><span class="checked"></span> </td>
                  <td><a href="#">Instructor name</a> </td>
                  <td>10,000 </td>
                  <td>Fall </td>
                  <td>2018 </td>
                  <td>
                    <div class="button-container">
                      <button type="button" class="secondary">Download</button>
                      <button type="button" class="secondary">Options</button>
                    </div>
                  </td>
                </tr>
                <tr>
                  <td><a href="#">0123</a> </td>
                  <td><a href="#">Course name</a> </td>
                  <td> </td>
                  <td> </td>
                  <td><span class="checked"></span> </td>
                  <td><a href="#">Instructor name</a> </td>
                  <td>10,000 </td>
                  <td>Fall </td>
                  <td>2018 </td>
                  <td>
                    <div class="button-container">
                      <button type="button" class="secondary">Download</button>
                      <button type="button" class="secondary">Options</button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
          <div class="table_pagination">
            <p>
              Results: 20 of 20
            </p>
            <div>
              <span class="table-prev"></span>
              <p class="active"><a>1</a></p>
              <p><a>2</a></p>
              <p><a>3</a></p>
              <span class="table-next"></span>
            </div>
          </div>
        </div>

        <div v-if="tabSection[0]==='Instructor Accounts'">
          <h2>All Instructor Users</h2>
          <p>Manage instructor users and their licensed accounts.</p>
          <div class="table_functions">
            <div class="filter_box">
              <p>Select which filters you want to apply to the table below: </p>
              <div>
                <span>
                  <input id="licensed_acccounts" type="checkbox" value="licensed_acccounts" />
                  <label for="licensed_acccounts">Licensed Accounts</label>
                </span>
                <span>
                  <input id="free_trial_accounts" type="checkbox" value="free_trial_accounts" />
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
                <tr>
                  <td><a href="#">User first name</a> </td>
                  <td><a href="#">User last name</a> </td>
                  <td>Nov 22, 2020 </td>
                  <td>Legacy </td>
                  <td>Higher Ed #1 </td>
                  <td><a href="#">Course name here</a> </td>
                  <td><span class="checked"></span> </td>
                  <td>200 </td>
                  <td>
                    <div class="button-container">
                      <button type="button" class="secondary">Options</button>
                    </div>
                  </td>
                </tr>
                <tr>
                  <td><a href="#">User first name</a> </td>
                  <td><a href="#">User last name</a> </td>
                  <td>Nov 22, 2020 </td>
                  <td>Legacy </td>
                  <td>Higher Ed #1 </td>
                  <td><a href="#">Course name here</a> </td>
                  <td><span class="checked"></span> </td>
                  <td>200 </td>
                  <td>
                    <div class="button-container">
                      <button type="button" class="secondary">Options</button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <div v-if="tabSection[0]==='Search All Users'">
          <h2>Search for users across all courses and account types </h2>
          <h3>Search by: </h3>
          <form>
            <div class="form_elem">
              <input type="text" id="name_contains" placeholder="Name contains..." />
              <label for="name_contains">Name contains</label>
            </div>
            <div class="form_elem">
              <input type="text" id="username_contains" placeholder="Username contains..." />
              <label for="username_contains">Username contains</label>
            </div>
            <div class="form_elem">
              <input type="text" id="email_contains" placeholder="Email contains..." />
              <label for="email_contains">Email contains</label>
            </div>
            <button class="action">Search</button>
          </form>
          <h3>Search Results:</h3>
          <div class="table_container">
            <table>
              <thead>
                <tr>
                  <th>ID # </th>
                  <th>First Name </th>
                  <th>Last Name </th>
                  <th>Email </th>
                  <th>Courses </th>
                  <th>Course User Type</th>
                  <th>Semester </th>
                  <th>Year </th>
                  <th>Student Score </th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td>32</td>
                  <td><a href="#">User first name</a> </td>
                  <td><a href="#">User last name</a> </td>
                  <td>Email address </td>
                  <td><a href="#">Course name</a> </td>
                  <td>Student </td>
                  <td>Winter </td>
                  <td>2018 </td>
                  <td>200,000 </td>
                </tr>
                <tr>
                  <td>50</td>
                  <td><a href="#">User first name</a> </td>
                  <td><a href="#">User last name</a> </td>
                  <td>Email address </td>
                  <td><a href="#">Course name</a> </td>
                  <td>Student </td>
                  <td>Winter </td>
                  <td>2018 </td>
                  <td>200,000 </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <div v-if="tabSection[0]==='Utilities'">
          <h2>Administrative Utilities</h2>
          <p>__NOTE__ This section will include the current sections: </p>
          <ul>
            <li>Delete Course Memberships </li>
            <li>Manage Institutions </li>
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
  name: 'admin-container',
  components: {
    courseCard: () => VComponents.get('vue/components/courseCard'),
    pastCourse: () => VComponents.get('vue/components/pastCourse'),
    guideMessage: () => VComponents.get('vue/components/guideMessage'),
    buttonModal: () => VComponents.get('vue/components/buttonModal'),
    accordionComponent: () => VComponents.get('vue/components/accordionComponent'),
    tabContainer: () => VComponents.get('vue/components/tabContainer'),
    datePicker: () => VComponents.get('vue/components/datePicker'),
  },
  data() {
    return {
      termYear: [],
      termName: [],
      tabBarOption: ["Courses", "Instructor Accounts", "Search All Users", "Utilities"],
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
    allCourses(){
      var courses = this.currentAndPastCourses.concat(this.unpublishedCourses);
      return courses
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
    },
    getUserFirstName(){
      return this.$store.getters.userFirstName;
    },
    getUserOnboardingStatus(){
      return this.$store.getters.userOnboardingStatus;
    },
    getUserIsInstructor(){
      return this.$store.getters.userIsInstructor;
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
