<template>
  <div class="button_container">
    <button type="button" class="secondary dropdown" :class="{open:active}" @click="toggleActive">
      <slot name="button_text"></slot>
    </button>
    <div :class="dropdownClass">
      <slot name="content"></slot>
    </div>
  </div>
</template>


<script lang='coffee'>`
module.exports = {
  name: 'button_dropdown',
  props: ['dropdown_class'],
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
    dropdownClass() {
      if (this.active) {
        return 'is-open';
      }
      return 'is-closed';
    }
  }
}
`</script>
