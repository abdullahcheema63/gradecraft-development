<template>
  <div>
    <p> Hello World </p>
    <p> Hello {{name}} </p>
    <p> {{greeting}} </p>
  </div>
</template>

<!-- have to set lang=coffee so rails-vue-loader can work -->
<script lang='coffee'>
module.exports = {
  name: 'hello-sophia',
  data: () => {name: "Sophia"},
  computed:
    greeting: ->
      this.$store.state.hi
}
</script>
