<template>
  <div class="main_content">
    <guideControl></guideControl>

    <div class="content_block intro">
        <!-- Note to E from S: conditional for adding App or U-M depending on the database side  -->
        <h1>My _App _or_ U-M_ Dashboard</h1>

        <guideMessage>
          <p>Welcome back, {{ getUserFirstName }}! </p>
          <p>As an Awesome Admin, you probably don’t need much guidance from me. Nevertheless, I’m here to help orient you, and you can see what I say to instructors and students. </p>
        </guideMessage>
    </div>

    <div class="content_block bg-green_mint_2 flex-4" id="admin_new_activity">
      <div>
        <h2>New Activity</h2>
        <p>In the past 10 days: </p>
      </div>
      <div>
        <h3 class="lining_figures">{{allNewInstructors.length}}</h3>
        <div>
          <h4>New Instructor Accounts</h4>
        </div>
      </div>
      <div>
        <h3 class="lining_figures">{{allNewCourses.length}}</h3>
        <div>
          <h4>New Courses</h4>
          <p><strong>{{this.newPublishedCoursesCount}}</strong>
            published
          </p>
          <p><strong>{{this.newTrialCoursesCount}}</strong>
            trial <span>courses</span>
          </p>
        </div>
      </div>
      <div>
        <h3 class="lining_figures app">16?</h3>
        <div>
          <h4>Subscriptions</h4>
          <p>
            <strong>10?</strong>
            renewed
          </p>
          <p>
            <strong>6?</strong>
            new
          </p>
        </div>
      </div>
    </div>

    <div class="content_block">
      <h2>New Courses</h2>
      <p>Here are all the courses created in the past 10 days.</p>
      <div class="table_container">
        <table>
          <thead>
            <tr>
              <th>Course # </th>
              <th>Course Name </th>
              <th>Subscribed </th>
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
                      <li><a :href="course.editURL">Edit</a></li>
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
    </div>

    <!-- <accordionComponent>
      <template slot="heading">New courses</template>
      <template slot="content">
        <p>Courses created in the past 10 days</p>
        <div class="table_container">
          <table>
            <thead>
              <tr>
                <th>Course # </th>
                <th>Course Name </th>
                <th>Subscribed </th>
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
                        <li><a :href="course.editURL">Edit</a></li>
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
    </accordionComponent> -->

    <!-- <accordionComponent>
      <template slot="heading">Subscription expiration</template>
      <template slot="content">
        <p>Subscriptions that will expire within 30 days from today</p>
        <div class="table_container" v-if="expiringLicenseInstructors.length">
          <table>
            <thead>
              <tr>
                <th>First Name </th>
                <th>Last Name </th>
                <th>Renewal Date </th>
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
      </template>
    </accordionComponent> -->
  </div>
</template>

<script lang='coffee'>`
module.exports = {
  name: 'index',
  components: {
    tablePagination: () => VComponents.get('vue/components/structure/tablePagination'),
    buttonDropdown: () => VComponents.get('vue/components/structure/buttonDropdown'),
    accordionComponent: () => VComponents.get('vue/components/structure/accordionComponent'),
    guideMessage: () => VComponents.get('vue/components/structure/guideMessage'),
    guideControl: () => VComponents.get('vue/components/guideControl'),
  },
  data() {
    return {
      currentPageItemMin: 0,
      currentPageItemMax: 10,
    }
  },
  created: function() {
    this.$store.dispatch("getAllCourses");
    this.$store.dispatch("getAllInstructors");
  },
  computed: {
    getUserFirstName(){
      return this.$store.state.user.firstName;
    },
    allInstructors(){
      return this.$store.state.allInstructors
    },
    allNewInstructors(){
      var allInstructors = this.allInstructors;
      return allInstructors.filter(this.filterNewInstructors)
    },
    expiringLicenseInstructors(){
      var allInstructors = this.allInstructors;
      return allInstructors.filter(this.filterExpiringInstructors)
    },
    allCourses(){
      return this.$store.state.allCourses;
    },
    allNewCourses(){
      return this.filterNewCourses(this.allCourses)
    },
    allSubscriptions(){
      return this.$store.state.allSubscriptions;
    },
    newTrialCoursesCount(){
      var count = this.allNewCourses.reduce(function(n, course){
        return n + (course.licensed === false);
      }, 0);
      return count
    },
    newPublishedCoursesCount(){
      var count = this.allNewCourses.reduce(function(n, course){
        return n + (course.published === true);
      }, 0);
      return count
    }
  },
  methods: {
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
    filterNewInstructors(instructor){
      var tenDaysAgo = new Date();
      tenDaysAgo.setDate(tenDaysAgo.getDate() - 100);
      if( instructor.createdAt < tenDaysAgo ) {return false}
      return instructor
    },
    filterNewCourses(allCourses){
      var tenDaysAgo = new Date();
      tenDaysAgo.setDate(tenDaysAgo.getDate() - 100);
      return allCourses.filter( course => {
        if( course.created < tenDaysAgo ){return false}
        return course
      })
    },
    paginateItems(itemRange){
      this.currentPageItemMin = itemRange.min - 1;
      this.currentPageItemMax = itemRange.max;
    }
  }
}
`</script>
