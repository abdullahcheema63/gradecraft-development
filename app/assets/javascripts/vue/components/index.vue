<template>
  <div>
    <p> Hello World </p>
    <p> Hello {{name}} </p>
    <p> {{currentCourses[0]}} </p>
  </div>
</template>

<!-- have to set lang=coffee so rails-vue-loader can work -->
<!-- adding back ticks ` escapes coffeescript to js -->
<script lang='coffee'>`
module.exports = {
  name: 'hello-sophia',
  data() {return {name: "Sophia"}},
  computed: {
    greeting(){
      return this.$store.state.user.firstName
    },
    currentCourses(){
      return this.$store.getters.currentCourseMembership;
    }
  }
}
`</script>
