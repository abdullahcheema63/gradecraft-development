<template>
  <div>
    <h2>All Instructor Users</h2>
    <p>Manage instructor users and their licensed accounts.</p>
    <form>
      <div class="form_elem">
        <input type="text" id="name_contains" v-model="searchName" placeholder="Name contains..." />
        <label for="name_contains">Name contains</label>
      </div>
    </form>
    <div class="table_functions">
      <div class="filter_box">
        <p>Select which filters you want to apply to the table below: </p>
        <div>
          <span>
            <input id="licensed_acccounts" type="checkbox" value="licensed" v-model="showLicensed" />
            <label for="licensed_acccounts">Licensed Accounts</label>
          </span>
          <span>
            <input id="unlicensed_accounts" type="checkbox" value="unlicensed" v-model="showUnlicensed" />
            <label for="unlicensed_accounts">Unlicensed accounts</label>
          </span>
          <span>
            <input id="active_accounts" type="checkbox" value="active" v-model="showInActiveCourse" />
            <label for="active_accounts">In Active Course</label>
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
          <tr v-for="instructor in currentPageAllInstructors" :key="instructor.id">
            <td><a href="#">{{instructor.firstName}}</a> </td>
            <td class="no_wrap"><a href="#">{{instructor.lastName}}</a> </td>
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
                <ul>
                  <li v-for="course in instructor.courses" :key="course.id">
                    <span :class="{checked: course.licensed}">&nbsp;</span>
                  </li>
                </ul>
              </td>
              <td>
                <ul>
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
    <tablePagination :items="filteredAllInstructors" @paginate="paginateItems"></tablePagination>
  </div>
</template>

<script lang='coffee'>`
module.exports = {
  name: 'all-instructor-table',
  components: {
    tablePagination: () => VComponents.get('vue/components/structure/tablePagination'),
    buttonDropdown: () => VComponents.get('vue/components/structure/buttonDropdown'),
  },
  data() {
    return {
      currentPageItemMin: 0,
      currentPageItemMax: 10,
      searchName: "",
      showLicensed: "",
      showUnlicensed: "",
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
    filterAllInstructors(instructor){
      if(this.searchName){
        var name = instructor.firstName + " " + instructor.lastName
        name = name.toLowerCase();
        if(!(name.includes(this.searchName.toLowerCase()))) {return false}
      }
      if (this.showLicensed){
        if(instructor.licensed === false){return false}
      }
      if(this.showUnlicensed){
        if(instructor.licensed === true){return false}
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
