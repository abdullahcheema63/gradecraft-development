<template>
  <div>
    <p> Hello World </p>
    <p> Hello {{name}} </p>
  </div>
</template>

<!-- have to set lang=coffee so rails-vue-loader can work -->
<script lang='coffee'>
module.exports = {
  name: 'Hello',
  data: () => {name: "Sophia"}
}
</script>
