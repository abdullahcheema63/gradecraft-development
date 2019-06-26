<template>
  <div>
    <h2>All Courses </h2>
    <p>Manage and view all courses&mdash;active and inactive, published and unpublished. </p>

    <div class="table_functions">
      <div class="filter_box">
        <p>Select which filters you want to apply to the table below: </p>
        <div>
          <span>
            <input id="published" type="checkbox" value="true" v-model="showPublished" />
            <label for="published">Published</label>
          </span>
          <span>
            <input id="unpublished" type="checkbox" value="true" v-model="showUnpublished" />
            <label for="unpublished">Unpublished</label>
          </span>
          <span>
            <input id="active" type="checkbox" value="active" v-model="showActive" />
            <label for="active">Active</label>
          </span>
          <span>
            <input id="inactive" type="checkbox" value="inactive" v-model="showInactive" />
            <label for="inactive">Inactive</label>
          </span>
        </div>
        <div>
          <span v-for="year in courseTermYear" :key="year">
            <input :id="year" type="checkbox" v-model="termYear" :value="year"/>
            <label :for="year">{{year}}</label>
          </span>
        </div>
        <div>
          <span v-for="term in courseTermName" :key="term">
            <input :id="term" type="checkbox" v-model="termName" :value="term"/>
            <label :for="term">{{term}}</label>
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
            <th>Course ID </th>
            <th>Course Name </th>
            <th>Licensed </th>
            <th>Active </th>
            <th>Published</th>
            <th>Instructor(s)</th>
            <th># Students </th>
            <th>Semester </th>
            <th>Year </th>
            <th>Created </th>
            <th>Actions </th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="course in allCourses">
            <td>{{course.id}}</td>
            <td>{{course.name}}</td>
            <td><span :class="{checked: course.licensed}">&nbsp;</span></td>
            <td><span :class="{checked: course.active}">&nbsp;</span></td>
            <td><span :class="{checked: course.published}">&nbsp;</span></td>
            <td>
              <ul><li v-for="instructor in course.instructors"><a :href="instructor.url">{{instructor.text}}</a></li></ul>
            </td>
            <td>{{course.studentNumber}}</td>
            <td>{{course.term}}</td>
            <td>{{course.year}}</td>
            <td>{{course.created}}</td>
            <td>
              <buttonDropdown>
                <template slot="button_text">Options</template>
                <template slot="content">
                  <ul>
                    <li>Copy over options from table component </li>
                  </ul>
                </template>
              </buttonDropdown>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <button type="button" class="action">Export this table view</button>
  </div>
</template>

<script lang='coffee'>`
module.exports = {
  name: 'all-course-table',
  components: {
    tablePagination: () => VComponents.get('vue/components/tablePagination'),
    buttonDropdown: () => VComponents.get('vue/components/buttonDropdown'),
  },
  created: function(){
    this.$store.dispatch("getCourseMemberships");
  },
  data() {
    return {
      currentPageItemMin: 0,
      currentPageItemMax: 10,
      showPublished: '',
      showUnpublished: '',
      showActive: '',
      showInactive: '',
      showLicensedAccounts: '',
      showFreeAccounts: '',
      courseTermYear: ['2014', '2015', '2016', '2017', '2018', '2019'],
      termYear: [],
      courseTermName: ['Fall', 'Winter', 'Spring', 'Summer'],
      termName: [],
    }
  },
  computed: {
    allCourses(){
      return this.$store.state.allCourses;
    }
  },
  methods: {
    paginateItems(itemRange){
      this.currentPageItemMin = itemRange.min - 1;
      this.currentPageItemMax = itemRange.max;
    }
  }
}
`</script>
