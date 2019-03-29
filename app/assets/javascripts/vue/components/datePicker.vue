<template>
  <input type="text" :id="id" :placeholder="placeholder" class="calendar" />
  <label :for="id">
    <slot name="label_text"></slot>
  </label>
</template>


<script lang='coffee'>`
module.exports = {
  name: 'date-picker',
  props: ['id', 'placeholder', 'for'],
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
