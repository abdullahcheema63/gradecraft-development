<template>
  <div class="content_block">
    <p>Manage and view all instructor accounts.</p>

    <div class="table_functions">
      <div class="filter_box">
        <p><b>Select which filters you want to apply:</b> </p>
        <div>
          <span>
            <input id="subscribed_acccounts" type="checkbox" value="subscribed" v-model="showSubscribed" />
            <label for="subscribed_acccounts">Active Subscription</label>
          </span>
          <span>
            <input id="unsubscribed_accounts" type="checkbox" value="unsubscribed" v-model="showUnsubscribed" />
            <label for="unsubscribed_accounts">No subscription</label>
          </span>
          <span>
            <input id="active_accounts" type="checkbox" value="published" v-model="showInPublishedCourse" />
            <label for="active_accounts">In a Published Course</label>
          </span>
        </div>
      </div>
      <div class="search_box">
        <form>
          <div class="form_elem">
            <input type="search" id="name_contains" v-model="searchName" placeholder="Search by instructor name" />
            <label for="name_contains">Search instructors</label>
          </div>
        </form>
      </div>
    </div>
    <div v-if="currentPageAllInstructors.length">
      <div class="table_container">
        <table>
          <thead>
            <tr>
              <th>First Name </th>
              <th>Last Name </th>
              <th>Subscription Renewal Date </th>
              <th>Current Courses </th>
              <th>Published Course </th>
              <th>Subscribed Course </th>
              <th># Students in Course </th>
              <th>Actions </th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="instructor in currentPageAllInstructors" :key="instructor.id">
              <!-- <td><a href="#">{{instructor.firstName}}</a> </td>
              <td class="no_wrap"><a href="#">{{instructor.lastName}}</a> </td> -->
              <!-- In the future, we'll make the instructor's names link to an individual profile page -->
              <td>{{instructor.firstName}} </td>
              <td class="no_wrap">{{instructor.lastName}} </td>
              <td>{{instructor.subscriptionExpires}} </td>
              <template v-if="instructor.courses.length">
                <td>
                  <ul>
                    <li v-for="course in userActiveCourses(instructor.courses)" :key="course.id">
                      <a :href="course.changeCoursePath" class="table_truncate" :title="course.name">{{course.name}}</a>
                    </li>
                  </ul>
                </td>
                <td>
                  <ul>
                    <li v-for="course in userActiveCourses(instructor.courses)" :key="course.id">
                      <span :class="{checked: course.published}">&nbsp;</span>
                    </li>
                  </ul>
                </td>
                <td>
                  <ul>
                    <li v-for="course in userActiveCourses(instructor.courses)" :key="course.id">
                      <span :class="{checked: course.subscribed}">&nbsp;</span>
                    </li>
                  </ul>
                </td>
                <td>
                  <ul>
                    <li v-for="course in userActiveCourses(instructor.courses)" :key="course.id">
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
      <tablePagination :items="filteredAllInstructors" @paginate="paginateItems"></tablePagination>
      <button type="button" class="action secondary">Export this table view</button>
      <p style="background: aquamarine;">
        ^ Not done
      </p>
    </div>
    <div v-else>
      <h4 class="pink_text">No users found with those search parameters. </h4>
    </div>
  </div>
</template>

<script lang='coffee'>`
module.exports = {
  name: 'instructors',
  components: {
    tablePagination: () => VComponents.get('vue/components/structure/tablePagination'),
    buttonDropdown: () => VComponents.get('vue/components/structure/buttonDropdown'),
  },
  created: function() {
    this.$store.dispatch("getAllInstructors");
  },
  data() {
    return {
      currentPageItemMin: 0,
      currentPageItemMax: 10,
      searchName: "",
      showSubscribed: "",
      showUnsubscribed: "",
      showInPublishedCourse: "",
    }
  },
  computed: {
    allInstructors(){
      return this.$store.state.allInstructors;
    },
    filteredAllInstructors(){
      var allInstructors = this.allInstructors
      return allInstructors.filter(this.filterAllInstructors)
    },
    currentPageAllInstructors(){
      return this.filteredAllInstructors.slice(this.currentPageItemMin, this.currentPageItemMax);
    }
  },
  methods: {
    filterAllInstructors(instructor){
      if(this.searchName){
        var name = instructor.firstName + " " + instructor.lastName
        name = name.toLowerCase();
        if(!(name.includes(this.searchName.toLowerCase()))) {return false}
      }
      if (this.showSubscribed != this.showUnsubscribed){
        if(this.showSubscribed != instructor.subscribed){return false}
      }
      if(this.showInPublishedCourse){
        if(this.hasPublishedCourse(instructor.courses) != true){return false}
      }
      return instructor
    },
    paginateItems(itemRange){
      this.currentPageItemMin = itemRange.min - 1;
      this.currentPageItemMax = itemRange.max;
    },
    userActiveCourses(courses){
      return courses.filter(course => course.active)
    },
    hasPublishedCourse(courses){
      var isPublished = false
      courses.forEach(function (course) {
        if(course.published === true){isPublished = true}
      });
      return isPublished
    }
  }
}
`</script>
