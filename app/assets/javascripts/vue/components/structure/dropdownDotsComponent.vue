<template>
  <div class="dropdown_dots">
    <button type="button" :class="dropdownClass" @click="toggle">
      <svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"
      viewBox="0 0 25 5" style="enable-background:new 0 0 25 5;" xml:space="preserve">
        <g>
          <circle
            style="fill: var(--dotColor, #2E70BE)"
            cx="12.5" cy="2.5" r="2"/>
          <circle
            style="fill: var(--dotColor, #2E70BE)"
            cx="20.5" cy="2.5" r="2"/>
          <circle
            style="fill: var(--dotColor, #2E70BE)"
            cx="4.5" cy="2.5" r="2"/>
        </g>
      </svg>
    </button>
    <div :class="dropdownClass">
      <slot name="content"></slot>
    </div>
  </div>
</template>

<script lang='coffee'>`
module.exports = {
  name: 'dropdown-dots-component',
  props: {
    dropdownState: {
      default: false,
      type: Boolean
    }
  },
  methods: {
    toggle() {
      this.toggleDropdownState()
    },
    toggleDropdownState(){
      this.dropdownState = !this.dropdownState
    }
  },
  computed: {
    dropdownClass() {
      if (this.dropdownState) {
        return 'is-open';
      }
      return 'is-closed';
    }
  },
}
`</script>
