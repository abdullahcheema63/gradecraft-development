<template>
  <div class="main_content">
    <guideControl></guideControl>

    <div class="content_block intro">
        <!-- Note to E from S: conditional for adding App or U-M depending on the database side  -->
        <h1>My _App _or_ U-M_ Dashboard</h1>

        <guideMessage>
          <p>Welcome back, {{ userFirstName }}! </p>
          <p>As an Awesome Admin, you probably don’t need much guidance from me. Nevertheless, I’m here to help orient you, and you can see what I say to instructors and students. </p>
        </guideMessage>
    </div>

    <div class="content_block bg-green_mint_2 flex-4" id="admin_new_activity">
      <div>
        <h2>New Activity</h2>
        <p>In the past 10 days: </p>
      </div>
      <div>
        <h3 class="lining_figures">{{newInstructorsCount}}</h3>
        <div>
          <h4>New Instructor Accounts</h4>
        </div>
      </div>
      <div>
        <h3 class="lining_figures">{{newCourses.length}}</h3>
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
        <h3 class="lining_figures app">{{newSubscriptionsCount}}</h3>
        <div>
          <h4>Subscriptions</h4>
          <p>
            <strong>10?</strong>
            renewed / continued / what goes here?
          </p>
          <p>
            <strong>{{newSubscriptionsCount}}</strong>
            new
          </p>
        </div>
      </div>
    </div>

    <div class="content_block">
      <h2 class="unspace-top">New Courses</h2>
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
            <tr v-for="course in newCourses" :key="course.id">
              <td>{{course.id}}</a> </td>
              <td><a :href="course.url">{{course.name}}</a> </td>
              <td><span :class="{checked: course.subscribed}"></span> </td>
              <td><span :class="{checked: course.active}"></span> </td>
              <td><span :class="{checked: course.published}"></span> </td>
              <td><span :class="{checked: course.copied}"></span> </td>
              <td>
                <ul>
                  <li v-for="instructor in course.instructors" :key="instructor.id">
                    <a :href="instructor.url">{{instructor.name}}</a>
                  </li>
                </ul>
              </td>
              <td>{{course.semester}}</td>
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
      <tablePagination :items="newCourses" @paginate="paginateItems"></tablePagination>
      <a class="button action next" href="courses/new">Add a new course</a>
    </div>
  </div>
</template>

<script lang='coffee'>`
module.exports = {
  name: 'index',
  components: {
    tablePagination: () => VComponents.get('vue/components/structure/tablePagination'),
    buttonDropdown: () => VComponents.get('vue/components/structure/buttonDropdown'),
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
    this.$store.dispatch("getNewActivity");
  },
  computed: {
    userFirstName(){
      return this.$store.state.user.firstName;
    },
    newActivity(){
      return this.$store.getters.newActivity
    },
    newCourses(){
      return this.newActivity.courses
    },
    newInstructorsCount(){
      return this.newActivity.newInstructorsCount
    },
    newSubscriptionsCount(){
      return this.newActivity.newSubscriptionsCount
    },
    allSubscriptions(){
      return this.$store.state.allSubscriptions;
    },
    newTrialCoursesCount(){
      if(this.newCourses.length >= 0){
        var count = this.newCourses.reduce(function(n, course){
          return n + (course.subscribed === false);
        }, 0);
        return count
      }
    },
    newPublishedCoursesCount(){
      if(this.newCourses.length >= 0){
        var count = this.newCourses.reduce(function(n, course){
          return n + (course.published === true);
        }, 0);
        return count
      }
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
    paginateItems(itemRange){
      this.currentPageItemMin = itemRange.min - 1;
      this.currentPageItemMax = itemRange.max;
    }
  }
}
`</script>
