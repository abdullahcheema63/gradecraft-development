<template>
  <div class="main_content" :class="maincontentClass">
    <guideControl></guideControl>

    <div class="content_block intro">
        <h1>My {{environmentName}} Dashboard</h1>

        <guideMessage>
          <p>Welcome back, {{ user.firstName }}! </p>
          <p>As an Awesome Admin, you probably don’t need much guidance from me. Nevertheless, I’m here to help orient you, and you can see what I say to instructors and students. </p>
        </guideMessage>
    </div>

    <div class="content_block bg-green_mint_2 flex-4" id="admin_new_activity">
      <div>
        <h2>New Activity</h2>
        <p>In the past 10 days: </p>
      </div>
      <div>
        <h3 class="lining_figures">{{newActivity.newInstructorsCount}}</h3>
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
          <p><strong>{{this.newUnpublishedCoursesCount}}</strong>
            unpublished
          </p>
        </div>
      </div>
      <div>
        <h3 class="lining_figures app">{{newActivity.newSubscriptionsCount}}</h3>
        <div>
          <h4>New Subscriptions</h4>
          <p>
            <strong>{{newActivity.paidCoursesCount}}</strong>
            Paid courses
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
              <th>ID </th>
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
            <tr v-if="newCourses.length === 0">
              <td colspan="12" class="empty">
                <p>
                  <em>No new courses were created in the past 10 days</em>
                </p>
              </td>
            </tr>
            <tr v-else v-for="course in newCourses" :key="course.id">
              <td><a :href="course.url">{{course.id}}</a> </td>
              <td><a :href="course.url">{{course.number}}</a></td>
              <td><a :href="course.url" class="table_truncate" :title="course.name">{{course.name}}</a> </td>
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
      <a class="button action next" href="courses/new">Add a course</a>
    </div>
  </div>
</template>

<script lang='coffee'>`
module.exports = {
  name: 'index',
  props: ['maincontentClass'],
  components: {
    tablePagination: () => VComponents.get('vue/components/structure/tablePagination'),
    buttonDropdown: () => VComponents.get('vue/components/structure/buttonDropdown'),
    guideMessage: () => VComponents.get('vue/components/structure/guideMessage'),
    guideControl: () => VComponents.get('vue/components/guideControl'),
  },
  data() {
    return {
      active: false,
      currentPageItemMin: 0,
      currentPageItemMax: 10,
    }
  },
  created: function() {
    this.$store.dispatch("getNewActivity");
  },
  computed: {
    user(){
      return this.$store.getters.user;
    },
    environmentName(){
      if (this.user.environment === 'development'){return "Local"}
      if (this.user.environment === 'production'){return "Umich"}
      if (this.user.environment === 'beta'){return "App"}
    },
    newActivity(){
      return this.$store.getters.newActivity
    },
    newCourses(){
      return this.newActivity.courses
    },
    allSubscriptions(){
      return this.$store.state.allSubscriptions;
    },
    newUnpublishedCoursesCount(){
      if(this.newCourses.length >= 0){
        var count = this.newCourses.reduce(function(n, course){
          return n + (course.published === false);
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
    shiftContent() {
      this.active = !this.active;
      this.$emit('shiftContent', this.active)
    },
    filterExpiringInstructors(instructor){
      var now = new Date();
      var expirationMax = now.setDate(now.getDate() + 30);
      var formattedDate = new Date(expirationMax);
      var formattedInstructorExpiration = new Date(instructor.subscriptionExpires);
      if (!instructor.subscriptionExpires) {
        return false
      } else if (new Date(instructor.subscriptionExpires) >= formattedDate) {
        return false
      }
      instructor.subscriptionExpires = formattedInstructorExpiration
      return instructor
    },
    paginateItems(itemRange){
      this.currentPageItemMin = itemRange.min - 1;
      this.currentPageItemMax = itemRange.max;
    }
  }
}
`</script>
