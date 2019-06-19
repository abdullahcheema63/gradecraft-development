<template>
  <div>
    <h2>My Current Courses</h2>
    <p v-if="!courses.length">You don't have any courses!</p>
    <p v-if="courses && license.max_courses !== null">
      You have used
      <strong>{{licensedCourses.length}} of your {{license.max_courses}} course licenses.</strong>
    </p>
    <div class="course_box">
      <div class="course_card" v-for="c of courses" :key="c.id">
        <h4>
          <span>{{c.name}}</span>
          <span>{{c.semester}} {{c.year}}</span>
        </h4>
        <div class="course_status" style="background-color: #42e29d;" v-if="isLicensed(c)">
          <h3 class="unspace-bottom">
            Status:
            <span>Licensed</span>
          </h3>
        </div>
        <div class="course_status bg-blue_2" v-else>
          <h3 class="unspace-bottom">
            Status:
            <span>Trial</span>
          </h3>
        </div>
        <p><b>Change course status:</b> </p>
        <div>
          <button class="action" v-if="isLicensed(c)" @click="removeCourse(c)">
            Revert to trial course
          </button>
          <button v-if="!isLicensed(c) && (license.max_courses === null || licensedCourses.length < license.max_courses)" @click="addCourse(c)">
            Convert to licensed course
          </button>
        </div>
        <p v-if="isLicensed(c)">
          <em>Any tool integrations or users you’ve added <b>will be lost</b> if you revert this course back to trial status.</em>
        </p>
      </div>
    </div>
  </div>
</template>

<script lang="coffee">
```
const api = "/api/licenses/edit";

const getService = (serviceName) =>
  angular.element(document.body).injector().get(serviceName);

const getAPIHelper = () =>
  getService("GradeCraftAPI");

const apiResponseToData = (responseJson) =>
  getAPIHelper().dataItem(responseJson.data, responseJson, { include: [ "courses", "payments" ] });

module.exports = {
  name: "licenses-course-selector",
  props: {
    courses: Array,
    license: Object,
  },
  computed: {
    licensedCourses: function() {
      return this.courses.filter(c => this.isLicensed(c));
    },
  },
  methods: {
    isLicensed: function(course) {
      return this.license.courses
        && this.license.courses.some(c => c.id === course.id);
    },
    updateCourses: function(courseIds) {
      this.$store.dispatch("updateCourseLicense", courseIds)
    },
    addCourse: async function(course) {
      const newList = this.license.courses
        .map(c => c.id);
      newList.push(course.id);
      await this.updateCourses(newList);
    },
    removeCourse: async function(course) {
      const newList = this.license.courses
        .map(c => c.id)
        .filter(id => id !== course.id);
      await this.updateCourses(newList);
    },
  },
  created: function() {
    console.log(this.license);
  }
}
```
</script>
