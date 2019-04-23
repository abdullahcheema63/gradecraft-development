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
          <span>
            <input id="2018" type="checkbox" value="2018"/>
            <label for="2018">2018</label>
          </span>
          <span>
            <input id="2017" type="checkbox" value="2017"/>
            <label for="2017">2017</label>
          </span>


          <span>
            <input id="2016" type="checkbox" value="2016" />
            <label for="2016">2016</label>
          </span>
          <span>
            <input id="2015" type="checkbox" value="2015" />
            <label for="2015">2015</label>
          </span>
          <span>
            <input id="2014" type="checkbox" value="2014" />
            <label for="2014">2014</label>
          </span>
        </div>
        <div>
          <span>
            <input id="Fall" type="checkbox" value="Fall">
            <label for="Fall">Fall</label>
          </span>
          <span>
            <input id="Winter" type="checkbox" value="Winter">
            <label for="Winter">Winter</label>
          </span>
          <span>
            <input id="Spring" type="checkbox" value="Spring">
            <label for="Spring">Spring</label>
          </span>
          <span>
            <input id="Summer" type="checkbox" value="Summer">
            <label for="Summer">Summer</label>
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
            <th>Course # </th>
            <th>Course Name </th>
            <th>Licensed </th>
            <th>Active </th>
            <th>Published </th>
            <th>Instructor(s) </th>
            <th># Students </th>
            <th>Semester </th>
            <th>Year </th>
            <th>Actions </th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="course in filteredCourses" :key="course.id">
            <td><a href="#">{{course.id}}</a> </td>
            <td><a href="#">{{course.name}}</a> </td>
            <td><span :class="{checked: course.licensed}"></span> </td>
            <td><span :class="{checked: course.active}"></span> </td>
            <td><span :class="{checked: course.published}"></span> </td>
            <td>
              <ul>
                <li v-for="instructor in course.instructors" :key="instructor">
                  <a href="#">{{instructor}}</a>
                </li>
              </ul>
            </td>
            <td>{{course.studentNumber}}</td>
            <td>{{course.term}}</td>
            <td>{{course.year}}</td>
            <td>
              <div class="button-container">
                <button type="button" class="secondary">Download</button>
                <button type="button" class="secondary">Options</button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <div class="table_pagination">
      <p>
        Results: 20 of 20
      </p>
      <div>
        <span class="table-prev"></span>
        <p class="active"><a>1</a></p>
        <p><a>2</a></p>
        <p><a>3</a></p>
        <span class="table-next"></span>
      </div>
    </div>
  </div>
</template>


<script lang='coffee'>`
module.exports = {
  name: 'table-component',
  data() {
    return {
      active: false,
      showPublished: '',
      showUnpublished: '',
      showActive: '',
      showInactive: '',
      termYear: [],
      termName: [],
      allCourses: [
        {
          id: 123,
          name: "Test Course",
          licensed: true,
          active: true,
          published: true,
          instructors: ["Instructor 1", "Instructor 2"],
          studentNumber: "1,000",
          term: "Fall",
          year: "2019"
        },
        {
          id: 223,
          name: "Blahhhh",
          licensed: false,
          active: false,
          published: false,
          instructors: ["Instructor 1"],
          studentNumber: "100",
          term: "Fall",
          year: "2020"
        },
        {
          id: 323,
          name: "Bloop",
          licensed: true,
          active: false,
          published: false,
          instructors: ["Instructor Dude"],
          studentNumber: "500",
          term: "Winter",
          year: "2020"
        },
      ]
    }
  },
  computed: {
    filteredCourses(){
      var allCourses = this.allCourses;
      return allCourses
        .filter(this.filterByPublished)
        .filter(this.filterByActive)
    }
  },
  methods: {
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
    }
  }
}
`</script>
