<template>
  <div>
    <h2>Courses</h2>
    <ul v-for="c of courses" :key="c.id">
      <li>
        <span>{{c.name}}</span>
        <span>{{isLicensed(c)}}</span>
        <button v-if="isLicensed(c)">
          Remove from License
        </button>
        <button v-if="!isLicensed(c)">
          Add to License
        </button>
      </li>
    </ul>
  </div>
</template>

<script lang="coffee">
```
const api = "/api/licenses";

const getService = (serviceName) =>
  angular.element(document.body).injector().get(serviceName);

const getAPIHelper = () =>
  getService("GradeCraftAPI");

const apiResponseToData = (responseJson) =>
  getAPIHelper().dataItem(responseJson.data, responseJson);

module.exports = {
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
        body: JSON.stringify(courseIds),
      });
      const body = await resp.json();
      if (!resp.ok) {
        console.error("resp not ok!");
        console.error(resp);
        console.error(body);
      }
      console.log(resp);
      console.log(body);
      const data = apiResponseToData(body);
      console.log(data);
      this.$emit("updated", data);
    },
    addCourse: async function(course) {
      console.log("addCourse");
      console.log(course);
      const newList = this.licensedCourses()
        .map(c => c.id)
        .filter(id => id !== course.id);
      await this.updateCourses(newList);
    },
    removeCourse: async function(course) {
      console.log("removeCourse");
      console.log(course);
      const newList = this.licensedCourses()
        .map(c => c.id);
      newList.push(course.id);
      await this.updateCourses(newList);
    },
  },
}
```
</script>