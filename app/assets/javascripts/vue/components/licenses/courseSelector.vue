<template>
  <div>
    <h2>Courses</h2>
    <em v-if="!courses.length">You don't have any courses.</em>
    <p>
      <strong v-if="courses && license.max_courses !== null">You have licensed {{licensedCourses.length}} / {{license.max_courses}} courses.</strong>
    </p>
    <ul v-for="c of courses" :key="c.id">
      <li>
        <span>{{c.name}}</span>
        <span>{{isLicensed(c)}}</span>
        <button v-if="isLicensed(c)" @click="removeCourse(c)">
          Remove from License
        </button>
        <button v-if="!isLicensed(c) && (license.max_courses === null || licensedCourses.length < license.max_courses)" @click="addCourse(c)">
          Add to License
        </button>
      </li>
    </ul>
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
    getLicense: async function() {
      const resp = await fetch(api);
      if (resp.status === 404) {
        return undefined;
      }
      else if (!resp.ok) {
        throw resp;
      }
      const json = await resp.json();
      return apiResponseToData(json);
    },
    updateCourses: async function(courseIds) {
      const resp = await fetch(api, {
        method: "PUT",
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ courses: courseIds }),
      });
      if (!resp.ok) {
        console.error("resp not ok!");
        console.error(resp);
        console.error(await resp.text());
      }
      const body = await resp.json();
      console.log(resp);
      console.log(body);
      const data = apiResponseToData(body);
      console.log(data);
      this.$emit("updated", data);
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