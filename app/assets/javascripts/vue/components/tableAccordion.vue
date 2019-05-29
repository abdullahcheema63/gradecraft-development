<template>
  <div class="accordion in_table">
    <div class="row_heading" :class="{open:active}" @click="toggleActive">
      <h3>
        <span></span>
        <slot name="assignment_title"></slot>
      </h3>
      <p class="date">
        <slot name="assignment_due"></slot>
      </p>
    </div>

    <div :class="accordionClass">
      <div class="content">
        <slot name="assignment_content"></slot>
      </div>
    </div>
  </div>
</template>


<script lang='coffee'>`
module.exports = {
  name: 'accordion-component',
  props: ['accordion_class'],
  data() {
    return {
      active: false
    }
  },
  methods: {
    toggleActive() {
      this.active = !this.active
    }
  },
  computed: {
    accordionClass() {
      if (this.active) {
        return 'is-open';
      }
      return 'is-closed';
    }
  }
}
`</script>
