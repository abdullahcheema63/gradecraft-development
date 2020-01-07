<template>
  <div class="main_content" :class="maincontentClass">
    <div class="content_block intro">
      <h1>{{environmentName}} Courses</h1>
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
                <a class="button action secondary next" href="/courses/new">Add a course</a>
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
                      <td>{{formatDate(course.created)}}</td>
                      <td class="no_wrap">
                        <buttonDropdown>
                          <template slot="button_text">Options</template>
                          <template slot="content">
                            <ul>
                              <li><a :href="course.editURL">Edit</a> </li>
                              <li v-if="course.active"><a @click.prevent="archiveCourse(course.id)">Archive</a> </li>
                              <li v-if="!course.active"><a @click.prevent="unarchiveCourse(course.id)">Unarchive</a> </li>
                              <li><a @click.prevent="copyCourse(course.id)">Copy</a> </li>
                              <li><a :href="course.copyStudentsURL">
                                Copy + Students
                                <!-- (remove for course / LO (need API)) -->
                              </a> </li>
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
            <div class="table_functions">
              <div class="filter_box">
                <p><b>Select which filters you want to apply:</b> </p>
                <div>
                  <span>
                    <input id="publishedArchived" type="checkbox" value="true" v-model="showPublishedArchived" />
                    <label for="publishedArchived">Published</label>
                  </span>
                  <span>
                    <input id="unpublishedArchived" type="checkbox" value="true" v-model="showUnpublishedArchived" />
                    <label for="unpublishedArchived">Unpublished</label>
                  </span>
                  <span>
                    <input id="subscribedArchived" type="checkbox" value="subscribed" v-model="showSubscribedArchived" />
                    <label for="subscribedArchived">Subscribed</label>
                  </span>
                  <span>
                    <input id="unsubscribedArchived" type="checkbox" value="unsubscribed" v-model="showUnsubscribedArchived" />
                    <label for="unsubscribedArchived">Unsubscribed</label>
                  </span>
                </div>
                <div>
                  <span v-for="year in archivedCourseTermYear" :key="year">
                    <input :id="year" type="checkbox" v-model="archivedTermYear" :value="year"/>
                    <label :for="year">{{year}}</label>
                  </span>
                </div>
                <div>
                  <span v-for="term in archivedCourseTermName" :key="term">
                    <input :id="term" type="checkbox" v-model="archivedTermName" :value="term"/>
                    <label :for="term">{{term}}</label>
                  </span>
                </div>
              </div>
              <div class="search_box">
                <div class="form_elem">
                  <input type="search" id="searchArchivedCourseName" v-model="searchArchivedCourseName" placeholder="Search all archived courses" />
                  <label for="searchArchivedCourseName">Search courses</label>
                </div>
              </div>
            </div>

            <div v-if="currentPageArchivedCourses.length">
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
                    <tr v-for="course in currentPageArchivedCourses">
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
                      <td>{{formatDate(course.created)}}</td>
                      <td class="no_wrap">
                        <buttonDropdown>
                          <template slot="button_text">Options</template>
                          <template slot="content">
                            <ul>
                              <li><a :href="course.editURL">Edit</a> </li>
                              <li v-if="course.active"><a @click.prevent="archiveCourse(course.id)">Archive</a> </li>
                              <li v-if="!course.active"><a @click.prevent="unarchiveCourse(course.id)">Unarchive</a> </li>
                              <li><a @click.prevent="copyCourse(course.id)">Copy</a> </li>
                              <li><a :href="course.copyStudentsURL">
                                Copy + Students
                                <!-- (remove for course / LO (need API)) -->
                              </a> </li>
                              <li><a @click.prevent="deleteCourse(course.id)">Delete</a></li>
                            </ul>
                          </template>
                        </buttonDropdown>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
              <tablePagination :items="filteredArchivedCourses" :paginateBy="currentPageItemMax" @paginate="paginateItems"></tablePagination>
              <button type="button" class="action secondary">Export this table view</button>
              <p style="background: aquamarine;">
                ^ Not done
              </p>
            </div>
            <div v-else>
              <h4 class="pink_text">No archived courses were found with the selected filters. </h4>
            </div>
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
      searchArchivedCourseName: '',
      showSubscribed: false,
      showUnsubscribed: false,
      showPublished: false,
      showUnpublished: false,
      showSubscribedArchived: false,
      showUnsubscribedArchived: false,
      showPublishedArchived: false,
      showUnpublishedArchived: false,
      courseTermYear: ['2014', '2015', '2016', '2017', '2018', '2019', '2020'],
      courseTermName: ['Fall', 'Winter', 'Spring', 'Summer'],
      archivedCourseTermYear: ['2014', '2015', '2016', '2017', '2018', '2019', '2020'],
      archivedCourseTermName: ['Fall', 'Winter', 'Spring', 'Summer'],
      termName: [],
      termYear: [],
      archivedTermName: [],
      archivedTermYear: [],
    }
  },
  computed: {
    tabBarOption(){
      var options = ["Current", "Archived"]
      return options
    },
    allCourses(){
      return this.$store.getters.allActiveCourses;
    },
    allArchivedCourses(){
      return this.$store.getters.allArchivedCourses;
    },
    filteredAllCourses(){
      var allCourses = this.allCourses;
      return allCourses.filter(this.filterAllCourses)
    },
    filteredArchivedCourses(){
      var allArchivedCourses = this.allArchivedCourses;
      return allArchivedCourses.filter(this.filterArchivedCourses)
    },
    currentPageAllCourses(){
      return this.filteredAllCourses.slice(this.currentPageItemMin, this.currentPageItemMax)
    },
    currentPageArchivedCourses(){
      return this.filteredArchivedCourses.slice(this.currentPageItemMin, this.currentPageItemMax)
    },
    user(){
      return this.$store.getters.user;
    },
    environmentName(){
      if (this.user.environment === 'development'){return "Local"}
      if (this.user.environment === 'production'){return "Umich"}
      if (this.user.environment === 'beta'){return "App"}
    },
  },
  methods: {
    formatDate(date){
      return moment(String(date)).format('LLLL')
    },
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
    filterArchivedCourses(course){
      if (this.searchArchivedCourseName){
        var name = course.name
        name = name.toLowerCase()
        if(!(name.includes(this.searchArchivedCourseName.toLowerCase()))){return false}
      }
      if(this.showSubscribedArchived != this.showUnsubscribedArchived){
        if(this.showSubscribedArchived != course.subscribed){return false}
      }
      if(this.showPublishedArchived != this.showUnpublishedArchived){
        if(this.showPublishedArchived != course.published){return false}
      }
      if(this.archivedTermName.length){
        if (!(this.archivedTermName.includes(course.term))) {return false}
      }
      if(this.archivedTermYear.length){
        if (!(this.archivedtermYear.includes(course.year))) {return false}
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
