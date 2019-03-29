<template>
  <input type="text" :id="id" :placeholder="placeholder" class="calendar" />
</template>


<script lang='coffee'>`
module.exports = {
  name: 'date-picker',
  props: ['id', 'placeholder'],
  data() {
    return {
      active: false
    }
  },
  mounted() {
    $(this.$el).datetimepicker();
    console.log(this.$el)
  }
}
`</script>
