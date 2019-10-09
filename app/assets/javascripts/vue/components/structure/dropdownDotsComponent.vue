<template>
  <div class="dropdown_dots" ref="clickAway">
    <button type="button" :class="dropdownClass" @click="toggleDropdownState">
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
  data() {
    return {
      dropDownViz: this.dropdownState
    }
  },
  methods: {
    toggleDropdownState(e){
      this.dropDownViz = !this.dropDownViz;
      if (this.dropDownViz) {
        window.addEventListener('click', this.closeDropdowns);
      };
      e.stopPropagation();
    },
    closeDropdowns(e) {
      if(!this.$refs.clickAway.contains(e.target)){
        this.dropDownViz = false;
        window.removeEventListener('click', this.closeDropdowns);
      }
    }
  },
  computed: {
    dropdownClass() {
      if (this.dropDownViz) {
        return 'is-open';
      }
      return 'is-closed';
    }
  },
}
`</script>
