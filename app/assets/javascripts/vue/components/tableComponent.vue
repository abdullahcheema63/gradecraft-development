<template>
  <div>
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
      <table class="has_actions">
        <thead>
          <tr>
            <th v-for="header in rawTableHeaders">{{formattedTableHeaders(header)}}</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in currentPageContent" :key="row.id">
            <td>
              <a :href="row.url">{{row.id}}</a>
            </td>
            <td><a href="#">{{row.name}}</a> </td>
            <td><span :class="{checked: row.licensed}"></span> </td>
            <td><span :class="{checked: row.active}"></span> </td>
            <td><span :class="{checked: row.published}"></span> </td>
            <td>
              <ul>
                <li v-for="instructor in row.instructors" :key="instructor">
                  <a href="#">{{instructor}}</a>
                </li>
              </ul>
            </td>
            <td>{{row.studentNumber}}</td>
            <td>{{row.term}}</td>
            <td>{{row.year}}</td>
            <td>{{row.created}}</td>
            <td>
              <buttonDropdown>
                <template slot="button_text">Download</template>
                <template slot="content">
                  <ul>
                    <li><a>Awarded Badges</a> </li>
                    <li><a>Research Grades</a> </li>
                    <li><a>Final Grades</a> </li>
                    <li><a>Assignment Structure</a> </li>
                    <li><a>Assignment Submissions</a> </li>
                    <li><a>Assignment Type Summaries</a> </li>
                    <li><a>Full Gradebook</a> </li>
                    <li><a>Badges</a> </li>
                    <li><a>Grading Scheme</a> </li>
                  </ul>
                </template>
              </buttonDropdown>

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

          <tr v-for="row in currentPageContent" :key="row.id">
            <td v-for="value in row">
              {{value}}
            </td>

            <td>
              <buttonDropdown>
                <template slot="button_text">Download</template>
                <template slot="content">
                  <ul>
                    <li><a>Awarded Badges</a> </li>
                    <li><a>Research Grades</a> </li>
                    <li><a>Final Grades</a> </li>
                    <li><a>Assignment Structure</a> </li>
                    <li><a>Assignment Submissions</a> </li>
                    <li><a>Assignment Type Summaries</a> </li>
                    <li><a>Full Gradebook</a> </li>
                    <li><a>Badges</a> </li>
                    <li><a>Grading Scheme</a> </li>
                  </ul>
                </template>
              </buttonDropdown>

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

    <tablePagination :items="filteredContent" @paginate="paginateItems"></tablePagination>
  </div>
</template>

<script lang='coffee'>`
module.exports = {
  name: 'table-component',
  components: {
    tablePagination: () => VComponents.get('vue/components/tablePagination'),
    buttonDropdown: () => VComponents.get('vue/components/buttonDropdown'),
  },
  props: ['content'],
  data() {
    return {
      currentPageItemMin: 0,
      currentPageItemMax: 2,
      active: false,
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
    rawTableHeaders(){
      return Object.keys(this.content[0])
    },
    filteredContent(){
      var allContent = this.content;
      allContent = allContent.filter( course => {
        if (!(this.termYear.includes(course.year)) && this.termYear.length) {return false}
        if (!(this.termName.includes(course.term)) && this.termName.length) {return false}
        return true
      })
      return allContent
        .filter(this.filterByPublished)
        .filter(this.filterByActive)
    },
    currentPageContent(){
      return this.filteredContent.slice(this.currentPageItemMin, this.currentPageItemMax);
    },
  },
  methods: {
    formattedTableHeaders(label){
      if (label === 'id'){return 'Course #'}
      if (label === 'name'){return 'Course Name'}
      if (label === 'created'){return 'Created'}
      if (label === 'licensed'){return 'Licensed'}
      if (label === 'active'){return 'Active'}
      if (label === 'published'){return 'Published'}
      if (label === 'instructors'){return 'Instructor(s)'}
      if (label === 'studentNumber'){return '# Students'}
      if (label === 'term'){return 'Semester'}
      if (label === 'year'){return 'Year'}
    },
    isArray(value){
      return typeof value === "object"
    },
    isBoolean(value){
      return typeof value === "boolean"
    },
    isString(value){
      return typeof value === "string"
    },
    filterByPublished(course) {
      if (this.showPublished && this.showUnpublished) {
        return course
      } else if (this.showPublished && !course.published) {
        return false
      } else if (this.showUnpublished && course.published) {
        return false
      }
      return course
    },
    filterByActive(course) {
      if (this.showActive && this.showInactive) {
        return course
      } else if (this.showActive && !course.active) {
        return false
      } else if (this.showInactive && course.active) {
        return false
      }
      return course
    },
    paginateItems(itemRange){
      this.currentPageItemMin = itemRange.min - 1;
      this.currentPageItemMax = itemRange.max;
    }
  }
}
`</script>
