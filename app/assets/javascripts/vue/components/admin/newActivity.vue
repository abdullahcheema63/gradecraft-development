<template>
  <div>
    <h2>New Activity</h2>
    <p>In the past 10 days: </p>
    <div class="flex-3">
      <div class="bg-blue_2">
        <h4>New Instructor Accounts</h4>
        <p class="summary_data">
          <span class="lining_figures">{{allNewInstructors.length}}</span>
          total
        </p>
      </div>
      <div class="bg-blue_2">
        <h4>New Courses</h4>
        <p class="summary_data column-2">
          <span class="lining_figures">{{allNewCourses.length}}</span>
        </p>
        <p class="summary_data column-2">
          <span class="lining_figures">{{this.newTrialCoursesCount}}</span>
          free trial courses
        </p>
        <p class="summary_data column-2">
          <span class="lining_figures">{{this.newPublishedCoursesCount}}</span>
          published courses
        </p>
      </div>
      <div class="bg-blue_2">
        <h4>Course Licenses</h4>
        <p class="summary_data">
          <span class="lining_figures">??</span>
          total
        </p>
        <p class="summary_data">
          <span class="lining_figures">??</span>
          renewed
        </p>
        <p class="summary_data">
          <span class="lining_figures">??</span>
          new
        </p>
      </div>
    </div>
  </div>
  </div>
</template>

<script lang='coffee'>`
module.exports = {
  name: 'new-activity',
  components: {
    tablePagination: () => VComponents.get('vue/components/tablePagination'),
    buttonDropdown: () => VComponents.get('vue/components/buttonDropdown'),
    accordionComponent: () => VComponents.get('vue/components/accordionComponent'),
  },
  created: function(){
    this.$store.dispatch("getAllInstructors");
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
