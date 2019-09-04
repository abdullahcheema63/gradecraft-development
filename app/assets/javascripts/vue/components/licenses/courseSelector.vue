<template>
  <div class="content_block bg-green_mint_2">
    <h2>My Current Courses</h2>
    <p>
      Select courses you want to pay for and choose payment methods. When the course is done, come back here to turn off the payments.
    </p>

    <div class="table_container">
      <table class="form_options-present my_subscription">
        <thead>
          <tr>
            <th>Course # </th>
            <th>Course Name </th>
            <th>Semester </th>
            <th>Published </th>
            <th>Paid </th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>HSWW 123</td>
            <td>Hogwarts First Years</td>
            <td>Fall 2019</td>
            <td><span class="checked">&nbsp;</span></td>
            <td class="form_options alt-2">
              <input type="checkbox" id="course_select_1" checked="checked" />
              <label for="course_select_1">&nbsp; </label>
            </td>
          </tr>
          <tr>
            <td>HSWW 456</td>
            <td>Hogwarts Fourth Years</td>
            <td>Fall 2020</td>
            <td> </td>
            <td class="form_options alt-2">
              <input type="checkbox" id="course_select_2" />
              <label for="course_select_2">&nbsp; </label>
            </td>
          </tr>
          <tr>
            <td>HSWW 456</td>
            <td>Hogwarts Fourth Years</td>
            <td>Fall 2020</td>
            <td> </td>
            <td class="form_options alt-2">
              <input type="checkbox" id="course_select_3" checked="checked" disabled="disabled" />
              <label for="course_select_3">Madame Maxime </label>
            </td>
          </tr>
          <tr v-for="c of courses" :key="c.id">
            <td>{{c.number}}</td>
            <td>{{c.name}}</td>
            <td>{{c.semester}} {{c.year}}</td>
            <td><span v-if="c.published" class="checked">&nbsp;</span> </td>

            <td v-if="c.licensed" class="form_options alt-2">
              <input type="checkbox" checked="checked" id="" />
              <label for="">&nbsp; </label>
            </td>
            <!-- SOPHIA to ERIK: another v-if is if someone else has paid, then you can adapt the disabled static option I have above -->
            <td v-else class="form_options alt-2">
              <input type="checkbox" id="" />
              <label for="">&nbsp; </label>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- SOPHIA to ERIK: we can delete this div.course_box section once you think we've gotten all the functionality we can reuse out of it -->
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
