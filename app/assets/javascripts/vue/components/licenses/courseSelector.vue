<template>
  <div class="content_block">
    <h2 class="unspace-top">My Current Courses</h2>
    
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
          <button class="action" v-if="isLicensed(c)" @click.prevent="removeCourse(c)">
            Revert to trial course
          </button>
          <button v-if="!isLicensed(c) && (license.max_courses === null || licensedCourses.length < license.max_courses)" @click.prevent="addCourse(c)">
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

module.exports = {
  name: "licenses-course-selector",
  props: {
    courses: Array,
    license: Object,
  },
  computed: {
    licensedCourses(){
      return this.$store.state.userLicense.courses
    },
  },
  methods: {
    isLicensed(course) {
      return this.licensedCourses
        && this.licensedCourses.some(c => c.id === course.id);
    },
    updateCourses(courseIds) {
      this.$store.dispatch("updateCourseLicense", courseIds)
    },
    addCourse(course) {
      const newList = this.licensedCourses
        .map(c => c.id);
      newList.push(course.id);
      this.updateCourses(newList);
    },
    removeCourse(course) {
      const newList = this.licensedCourses
        .map(c => c.id)
        .filter(id => id !== course.id);
      this.updateCourses(newList);
    },
  }
}
```
</script>
