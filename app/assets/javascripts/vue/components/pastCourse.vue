<template>
  <div class='course_box'>
    <div class="course_card" :class="user_card_class">
      <h4>
        <span>{{ course.number }} {{ course.name }}</span>
        <span>{{ course.term.name }} {{ course.term.year }}</span>
      </h4>

      <div class="course_status">
        {{course.instructor}}
        <p :class="course.licensed" v-if="is_licensed" @click="toggleModalState">
          {{ Licensed }}
        </p>
      </div>

      <div>
        <a class="button next">View course</a>
      </div>
    </div>
  </div>
</template>

<script lang='coffee'>`
module.exports = {
  name: 'pastCourse',
  props: ['course'],
  computed: {
    user_card_class() {
      return this.course.role.toLowerCase();
    },
    is_licensed() {
      return this.course.license
    }
  }
}
`</script>
