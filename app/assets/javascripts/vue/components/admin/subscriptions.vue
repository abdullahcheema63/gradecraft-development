<template>
  <div class="main_content" :class="maincontentClass">
    <div class="content_block intro">
      <h1>Subscriptions</h1>
      <p>
        Manage and view all instructors with active subscriptions.
      </p>
    </div>

    <div class="content_block">
      <div class="table_functions">
        <div class="filter_box">
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

                <th># Subscribed Courses </th>
                <th>Monthly Cost ($)</th>

                <th>Subscribed Courses </th>

                <th>Unpublished</th>
                <th>Date Last Paid</th>

                <th>Actions </th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="instructor in currentPageAllInstructors" :key="instructor.id">
                <td><a href="#">{{instructor.firstName}}</a> </td>
                <td class="no_wrap"><a href="#">{{instructor.lastName}}</a> </td>
                <td>{{instructor.subscriptionExpires}} </td>

                <td>Number </td>
                <td>Price </td>

                <template v-if="instructor.courses.length">
                  <td>
                    <ul>
                      <li v-for="course in instructor.courses" :key="course.id">
                        <a :href="course.changeCoursePath" class="table_truncate" :title="course.name">{{course.name}}</a>
                      </li>
                    </ul>
                  </td>
                  <td>
                    <ul>
                      <li v-for="course in instructor.courses" :key="course.id">
                        <span :class="{alert: !course.published}">&nbsp;</span>
                      </li>
                    </ul>
                  </td>
                </template>

                <td>Date </td>

                <td>
                  <a class="button secondary" :href="'mailto:' + instructor.email">Email</a>
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
  </div>
</template>

<script lang='coffee'>`
module.exports = {
  name: 'instructors',
  props: ['maincontentClass'],
  components: {
    tablePagination: () => VComponents.get('vue/components/structure/tablePagination'),
  },
  created: function() {
    this.$store.dispatch("getAllInstructors");
  },
  data() {
    return {
      active: false,
      currentPageItemMin: 0,
      currentPageItemMax: 10,
      searchName: "",
      showSubscribed: "",
      showUnsubscribed: "",
      showInActiveCourse: "",
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
    shiftContent() {
      this.active = !this.active;
      this.$emit('shiftContent', this.active)
    },
    filterAllInstructors(instructor){
      if(this.searchName){
        var name = instructor.firstName + " " + instructor.lastName
        name = name.toLowerCase();
        if(!(name.includes(this.searchName.toLowerCase()))) {return false}
      }
      if (this.showSubscribed != this.showUnsubscribed){
        if(this.showSubscribed != instructor.subscribed){return false}
      }
      if(this.showInActiveCourse){
        if(this.hasActiveCourse(instructor.courses) != true){return false}
      }
      return instructor
    },
    paginateItems(itemRange){
      this.currentPageItemMin = itemRange.min - 1;
      this.currentPageItemMax = itemRange.max;
    },
    hasActiveCourse(courses){
      var isActive = false
      courses.forEach(function (course) {
        if(course.active === true){isActive = true}
      });
      return isActive
    }
  }
}
`</script>
