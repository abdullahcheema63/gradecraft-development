<template>
  <div>
    <div class="content_block bg-blue_2 flex-4" id="admin_new_activity">
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
        <h3 class="lining_figures app_licenses">16?</h3>
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
    </accordionComponent>
    <accordionComponent>
      <template slot="heading">Subscription expiration</template>
      <template slot="content">
        <p>Licenses that will expire within 30 days from today</p>
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
    </accordionComponent>
  </div>
</template>

<script lang='coffee'>`
module.exports = {
  name: 'new-activity',
  components: {
    tablePagination: () => VComponents.get('vue/components/structure/tablePagination'),
    buttonDropdown: () => VComponents.get('vue/components/structure/buttonDropdown'),
    accordionComponent: () => VComponents.get('vue/components/structure/accordionComponent'),
  },
  data() {
    return {
      currentPageItemMin: 0,
      currentPageItemMax: 10,
    }
  },
  computed: {
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
