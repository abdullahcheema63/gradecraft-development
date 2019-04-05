<template>
  <div class="form_elem">
    <input type="text" :id="id" :placeholder="placeholder" class="datetimepicker calendar" />
    <slot></slot>
  </div>
</template>


<script lang='coffee'>`
module.exports = {
  name: 'date-picker',
  props: ['id', 'placeholder'],
  data(){
    return {
      active: false
    }
  },
  mounted(){
    var self = this;
    $(this.$el.querySelector('input')).datetimepicker({
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
