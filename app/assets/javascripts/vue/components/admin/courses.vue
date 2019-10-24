<template>
  <div class="main_content" :class="maincontentClass">
    <div class="content_block intro">
      <h1>_App _or_ U-M_ Courses</h1>
      <p style="background: aquamarine;">
        Note to E from S: the “App” vs “U-M” part of the heading above is conditional, based on which data side the admin is logged into.
      </p>
      <p>
        Manage and view all courses.
      </p>
    </div>

    <tabContainer>
      <template slot="tabBarNav">
        <div v-for="option in tabBarOption">
          <input type="radio" :id="option" :value="option" v-model="tabSection[0]" name="tab_group_1" />
          <label :for="option">{{option}}</label>
        </div>
      </template>
      <template slot="tabSections">
        <div v-if="tabSection[0]==='Current'">
          <div class="content_block">
            <div class="p_button">
              <p>
                Manage and view all current courses.
              </p>
              <div>
                <button class="action secondary next">Add a course</button>
              </div>
            </div>

            <div class="table_functions">
              <div class="filter_box">
                <p><b>Select which filters you want to apply:</b> </p>
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
                    <input id="subscribed" type="checkbox" value="subscribed" v-model="showSubscribed" />
                    <label for="subscribed">Subscribed</label>
                  </span>
                  <span>
                    <input id="unsubscribed" type="checkbox" value="unsubscribed" v-model="showUnsubscribed" />
                    <label for="unsubscribed">Unsubscribed</label>
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
                  <input type="search" id="searchCourseName" v-model="searchCourseName" placeholder="Search all courses" />
                  <label for="searchCourseName">Search courses</label>
                </div>
              </div>
            </div>

            <div v-if="currentPageAllCourses.length">
              <div class="table_container">
                <table>
                  <thead>
                    <tr>
                      <th>ID </th>
                      <th>Course # </th>
                      <th>Course Name </th>
                      <th>Published</th>
                      <th>Subscribed </th>
                      <th>Instructor(s)</th>
                      <th># Students </th>
                      <th>Semester </th>
                      <th>Year </th>
                      <th>Created </th>
                      <th>Actions </th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="course in currentPageAllCourses">
                      <td><a :href="course.url">{{course.id}}</a></td>
                      <td><a :href="course.url">{{course.number}}</a></td>
                      <td><a class="table_truncate" :href="course.url">{{course.name}}</a></td>
                      <td><span :class="{checked: course.published}">&nbsp;</span></td>
                      <td><span :class="{checked: course.subscribed}">&nbsp;</span></td>
                      <td>
                        <ul><li v-for="instructor in course.instructors"><a :href="instructor.url">{{instructor.text}}</a></li></ul>
                      </td>
                      <td>{{course.studentNumber}}</td>
                      <td>{{course.term}}</td>
                      <td>{{course.year}}</td>
                      <td>{{course.created}}</td>
                      <td class="no_wrap">
                        <buttonDropdown>
                          <template slot="button_text">Export</template>
                          <template slot="content">
                            <ul>
                              <li><a :href="course.earnedBadgesURL">Export Earned Badges</a> </li>
                              <li><a :href="course.researchGradesURL">Research Grades</a> </li>
                              <li><a :href="course.finalGradesURL">Final Grades</a> </li>
                              <li><a :href="course.submissionsURL">Assignment Submissions</a> </li>
                              <li><a :href="course.assignmentStructureURL">Assignment Structure</a> </li>
                              <li><a :href="course.assignmentTypeSummaryURL">Assignment Type Summaries</a> </li>
                              <li><a :href="course.gradebookURL">Full Gradebook</a> </li>
                              <li><a :href="course.badgeStructureURL">Export Badges Structure</a> </li>
                              <li><a :href="course.gradeSchemeStructureURL">Grading Scheme</a> </li>
                            </ul>
                          </template>
                        </buttonDropdown>

                        <buttonDropdown>
                          <template slot="button_text">Options</template>
                          <template slot="content">
                            <ul>
                              <li><a :href="course.editURL">Edit</a> </li>
                              <li v-if="course.active"><a @click.prevent="archiveCourse(course.id)">Archive</a> </li>
                              <li v-if="!course.active"><a @click.prevent="unarchiveCourse(course.id)">Unrchive</a> </li>
                              <li><a @click.prevent="copyCourse(course.id)">Copy</a> </li>
                              <li><a :href="course.copyStudentsURL">Copy + Students(remove for course / LO (need API))</a> </li>
                              <li><a @click.prevent="deleteCourse(course.id)">Delete</a></li>
                            </ul>
                          </template>
                        </buttonDropdown>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
              <tablePagination :items="filteredAllCourses" :paginateBy="currentPageItemMax" @paginate="paginateItems"></tablePagination>
              <button type="button" class="action secondary">Export this table view</button>
              <p style="background: aquamarine;">
                ^ Not done
              </p>
            </div>
            <div v-else>
              <h4 class="pink_text">No courses were found with the selected filters. </h4>
            </div>
          </div>
        </div>

        <div v-if="tabSection[0]==='Archived'">
          <div class="content_block">
            <p>Manage and view all archived courses. </p>
          </div>
        </div>
      </template>
    </tabContainer>
  </div>
</template>

<script lang='coffee'>`
module.exports = {
  name: 'courses',
  props: ['maincontentClass'],
  components: {
    tablePagination: () => VComponents.get('vue/components/structure/tablePagination'),
    buttonDropdown: () => VComponents.get('vue/components/structure/buttonDropdown'),
    tabContainer: () => VComponents.get('vue/components/structure/tabContainer'),
  },
  created: function() {
    this.$store.dispatch("getAllCourses");
  },
  data() {
    return {
      active: false,
      tabSection: ["Current"],
      currentPageItemMin: 0,
      currentPageItemMax: 10,
      searchCourseName: '',
      showSubscribed: false,
      showUnsubscribed: false,
      showPublished: false,
      showUnpublished: false,
      showActive: false,
      showInactive: false,
      courseTermYear: ['2014', '2015', '2016', '2017', '2018', '2019'],
      courseTermName: ['Fall', 'Winter', 'Spring', 'Summer'],
      termName: [],
      termYear: [],
    }
  },
  computed: {
    tabBarOption(){
      var options = ["Current", "Archived"]
      return options
    },
    allCourses(){
      return this.$store.state.allCourses;
    },
    filteredAllCourses(){
      var allCourses = this.allCourses;
      return allCourses.filter(this.filterAllCourses)
    },
    currentPageAllCourses(){
      return this.filteredAllCourses.slice(this.currentPageItemMin, this.currentPageItemMax)
    }
  },
  methods: {
    shiftContent() {
      this.active = !this.active;
      this.$emit('shiftContent', this.active)
    },
    filterAllCourses(course){
      if (this.searchCourseName){
        var name = course.name
        name = name.toLowerCase()
        if(!(name.includes(this.searchCourseName.toLowerCase()))){return false}
      }
      if(this.showSubscribed != this.showUnsubscribed){
        if(this.showSubscribed != course.subscribed){return false}
      }
      if(this.showActive != this.showInactive){
        if (this.showActive != course.active){return false}
      }
      if(this.showPublished != this.showUnpublished){
        if(this.showPublished != course.published){return false}
      }
      if(this.termName.length){
        if (!(this.termName.includes(course.term))) {return false}
      }
      if(this.termYear.length){
        if (!(this.termYear.includes(course.year))) {return false}
      }
      return course
    },
    deleteCourse(courseId){
      this.$store.dispatch("deleteCourse", courseId);
    },
    copyCourse(courseId){
      this.$store.dispatch("copyCourse", courseId);
    },
    archiveCourse(courseID){
      this.$store.dispatch('archiveCourse', courseID)
    },
    unarchiveCourse(courseID){
      this.$store.dispatch('unarchiveCourse', courseID)
    },
    paginateItems(itemRange){
      this.currentPageItemMin = itemRange.min - 1;
      this.currentPageItemMax = itemRange.max;
    }
  }
}
`</script>
