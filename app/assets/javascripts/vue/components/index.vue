<template>
  <div>
    <p> Hello World </p>
    <p> Hello {{name}} </p>
    <p> {{currentCourses}} </p>
  </div>
</template>

<!-- have to set lang=coffee so rails-vue-loader can work -->
<!-- adding back ticks ` escapes coffeescript to js -->
<script lang='coffee'>`
module.exports = {
  name: 'index',
  data() {return {name: "Sophia"}},
  computed: {
    currentCourses(){
      return this.$store.getters.currentCourseMembership;
    }
  }
}
`</script>
