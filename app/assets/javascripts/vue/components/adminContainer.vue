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
              <tr v-for="course in newCourses" :key="course.id">
                <td><a href="#">{{course.id}}</a> </td>
                <td><a href="#">{{course.name}}</a> </td>
                <td><span :class="{checked: course.licensed}"></span> </td>
                <td><span :class="{checked: course.active}"></span> </td>
                <td><span :class="{checked: course.published}"></span> </td>
                <td><span :class="{checked: course.copied}"></span> </td>
                <td>
                  <ul>
                    <li v-for="instructor in course.instructors" :key="instructor">
                      <a href="#">{{instructor}}</a>
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
                        <li><a>Edit</a> </li>
                        <li><a>Copy</a> </li>
                        <li><a>Copy + Students</a> </li>
                        <li><a>Delete</a> </li>
                      </ul>
                    </template>
                  </buttonDropdown>
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
            <span class="table_prev disabled"></span>
            <p class="active">1</p>
            <p><a>2</a></p>
            <span class="table_next"></span>
          </div>
        </div>

        <button class="action next">Add a new course</button>
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
              <tr v-for="user in expiringInstructors" :key="user.userId">
                <td><a href="#">{{user.firstName}}</a> </td>
                <td><a href="#">{{user.lastName}}</a> </td>
                <td>{{user.expirationDate}} </td>
                <td>{{user.paymentMethod}} </td>
                <td>{{user.activeCoursesNumber}} </td>
                <td>
                  <div class="button-container">
                    <a class="button secondary" :href="'mailto:' + user.email" >Send email</a>
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
          <h2>All Courses </h2>
          <p>Manage and view all courses&mdash;active and inactive, published and unpublished. </p>

          <tableComponent :content="allCourses"></tableComponent>

          <button type="button" class="action">Export this table view</button>
        </div>

        <div v-if="tabSection[0]==='Instructor Accounts'">
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
                <tr v-for="user in filteredInstructors" :key="user.userId">
                  <td><a href="#">{{user.firstName}}</a> </td>
                  <td><a href="#">{{user.lastName}}</a> </td>
                  <td>{{user.expirationDate}} </td>
                  <td>{{user.paymentMethod}} </td>
                  <td style="width: 100px;">{{user.accountType}} </td>
                  <td>
                    <ul>
                      <li v-for="course in user.activeCoursesList" :key="course.courseName">
                        <a href="#" class="table_truncate">{{course.courseName}}</a>
                      </li>
                    </ul>
                  </td>
                  <td>
                    <ul class="checked_list">
                      <li v-for="course in user.activeCoursesList" :key="course.courseName">
                        <span :class="{checked: course.courseLicensed}">&nbsp;</span>
                      </li>
                    </ul>
                  </td>
                  <td>
                    <ul class="student_list">
                      <li v-for="course in user.activeCoursesList" :key="course.courseName">
                        {{course.courseStudents}}
                      </li>
                    </ul>
                  </td>
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
          <div class="table_pagination">
            <p>
              Results: <span class="displayed">3</span> of <span class="total">200</span>
            </p>
            <div>
              <span class="table_prev disabled"></span>
              <p class="active">1</p>
              <p><a>2</a></p>
              <p><a>3</a></p>
              <p><a>4</a></p>
              <span class="table_next"></span>
            </div>
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
                <tr v-for="user in getAllUsers">
                  <td>{{user.id}}</td>
                  <td><a href="#">{{user.firstName}}</a> </td>
                  <td><a href="#">{{user.lastName}}</a> </td>
                  <td>{{user.email}}</td>
                  <template v-if="user.courses.length">
                    <tr v-for="course in user.courses">
                      <td><a :href="course.change_course_path">{{course.name}}</a> </td>
                      <td>{{course.role}} </td>
                      <td>{{course.semester}}</td>
                      <td>{{course.year}}</td>
                      <td>{{course.score}}</td>
                    </tr>
                  </template>
                  <td></td>
                  <td></td>
                  <td></td>
                  <td></td>
                  <td></td>
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
    guideMessage: () => VComponents.get('vue/components/guideMessage'),
    buttonModal: () => VComponents.get('vue/components/buttonModal'),
    accordionComponent: () => VComponents.get('vue/components/accordionComponent'),
    tabContainer: () => VComponents.get('vue/components/tabContainer'),
    buttonDropdown: () => VComponents.get('vue/components/buttonDropdown'),
    datePicker: () => VComponents.get('vue/components/datePicker'),
    tableComponent: () => VComponents.get('vue/components/tableComponent'),
  },
  data() {
    return {
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
      },
      allInstructors: [
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
        {
          userId: 60,
          email: "blah@test.com",
          firstName: "User",
          lastName: "McUserpants",
          licensedAccount: true,
          expirationDate: "Mon Jul 1 2019 15:22:00 GMT-0400 (Eastern Daylight Time)",
          paymentMethod: "Stripe",
          accountType: "Higher Ed #1",
          activeCoursesNumber: "2",
          activeCoursesList: [
            {
              courseName: "Active Course 1 with a super long name",
              courseLicensed: true,
              courseStudents: "200",
            },
            {
              courseName: "Active Course 2",
              courseLicensed: true,
              courseStudents: "200",
            },
          ],
        },
        {
          userId: 51,
          email: "mcUserpants@test.com",
          firstName: "User",
          lastName: "McUserpants",
          licensedAccount: true,
          expirationDate: "Wed May 22 2019 15:22:00 GMT-0400 (Eastern Daylight Time)",
          paymentMethod: "Legacy",
          accountType: "K—12",
          activeCoursesNumber: "7",
          activeCoursesList: [
            {
              courseName: "Active course 1 with long name goes in here",
              courseLicensed: false,
              courseStudents: "0",
            },
            {
              courseName: "Active course 2 with long name goes in here",
              courseLicensed: true,
              courseStudents: "2,000",
            },
            {
              courseName: "Active course 3 with long name goes in here",
              courseLicensed: true,
              courseStudents: "58,000",
            },
            {
              courseName: "Active course 4 with long name goes in here",
              courseLicensed: false,
              courseStudents: "0",
            },
            {
              courseName: "Active course 5",
              courseLicensed: true,
              courseStudents: "60",
            },
            {
              courseName: "Active course 6",
              courseLicensed: false,
              courseStudents: "60",
            },
            {
              courseName: "Active course 7",
              courseLicensed: true,
              courseStudents: "600,000",
            },
          ],
        },
        {
          userId: 52,
          email: "bloop@test.com",
          firstName: "User",
          lastName: "McUserpants",
          licensedAccount: true,
          expirationDate: "Wed May 22 2019 15:22:00 GMT-0400 (Eastern Daylight Time)",
          paymentMethod: "OTT",
          accountType: "Higher Ed #2",
          activeCoursesNumber: "3",
          activeCoursesList: [
            {
              courseName: "Active course 1 with long name goes in here",
              courseLicensed: false,
              courseStudents: "0",
            },
            {
              courseName: "Active course 2 with long name goes in here",
              courseLicensed: true,
              courseStudents: "2,000",
            },
            {
              courseName: "Active course 3 with long name goes in here",
              courseLicensed: true,
              courseStudents: "58,000",
            },
            {
              courseName: "Active course 4 with long name goes in here",
              courseLicensed: false,
              courseStudents: "0",
            },
          ],
        },
      ],
      newCourses: [
        {
          id: 91,
          name: "This is a New Course",
          created: "Wed, Apr 20, 2019, 4:31pm EDT",
          licensed: true,
          active: true,
          published: true,
          copied: true,
          instructors: ["Instructor 1"],
          term: "Fall",
          year: "2019"
        },
        {
          id: 92,
          name: "This is a New Course too",
          created: "Wed, Apr 20, 2019, 4:31pm EDT",
          licensed: false,
          active: true,
          published: true,
          copied: false,
          instructors: ["Instructor 1"],
          term: "Fall",
          year: "2019"
        },
        {
          id: 93,
          name: "This One as Well!",
          created: "Wed, Apr 20, 2019, 4:31pm EDT",
          licensed: false,
          active: false,
          published: true,
          copied: false,
          instructors: ["Instructor 1"],
          term: "Fall",
          year: "2019"
        }
      ],
      allCourses: [
        {
          id: 123,
          name: "Test Course",
          licensed: true,
          active: true,
          published: true,
          instructors: [
            {
              text: "Instructor 1",
              url: "https://gradecraft.com",
            },
            {
              text: "Instructor 2",
              url: "https://gradecraft.com",
            }
          ],
          studentNumber: "1,000",
          term: "Fall",
          year: "2019",
          created: "Wed, Apr 10, 2019, 4:31pm EDT",
          url: "https://gradecraft.com",
        },
        {
          id: 223,
          name: "Blahhhh",
          licensed: false,
          active: false,
          published: false,
          instructors: [
            {
              text: "Instructor 3",
              url: "https://gradecraft.com",
            }
          ],
          studentNumber: "100",
          term: "Fall",
          year: "2017",
          created: "Wed, Apr 10, 2019, 4:31pm EDT",
          url: "https://gradecraft.com",
        },
        {
          id: 323,
          name: "Bloop",
          licensed: true,
          active: false,
          published: false,
          instructors: [
            {
              text: "Instructor 4",
              url: "https://gradecraft.com",
            },
            {
              text: "Instructor 5",
              url: "https://gradecraft.com",
            }
          ],
          studentNumber: "500",
          term: "Winter",
          year: "2015",
          created: "Wed, Apr 10, 2019, 4:31pm EDT",
          url: "https://gradecraft.com",
        },
      ]
    }
  },
  created: function() {
    this.$store.dispatch("getAllUsers")
  },
  computed: {
    getUserFirstName(){
      return this.$store.getters.userFirstName;
    },
    filteredInstructors(){
        var allInstructors = this.allInstructors;
        return allInstructors.filter(this.filterByLicensedAccount)
    },
    expiringInstructors(){
      var allInstructors = this.allInstructors;
      return allInstructors.filter(this.filterExpiringInstructors)
    },
    getAllUsers(){
      return this.$store.state.allUsers;
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
    courseCopyRequest(){
      this.$refs.buttonModal_copy.toggleModalState()
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
      var formattedInstructorExpiration = new Date(instructor.expirationDate);
      if (!instructor.licensedAccount) {
        return false
      } else if (new Date(instructor.expirationDate) >= formattedDate) {
        return false
      }
      return instructor
    },
  }
}
`</script>
