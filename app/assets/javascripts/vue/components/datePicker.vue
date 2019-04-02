<template>
  <input type="text" :id="id" :placeholder="placeholder" class="datetimepicker calendar" />
</template>


<script lang='coffee'>`
module.exports = {
  name: 'date-picker',
  props: ['id', 'placeholder', 'for'],
  data(){
    return {
      active: false
    }
  },
  mounted(){
    var self = this;
    $(this.$el).datetimepicker({
      onSelect: function(date) {
        self.$emit('update-date', date);
      }
    });
  },
  beforeDestroy(){
    $(this.$el).datepicker('hide').datepicker('destroy');
  }
}
`</script>
