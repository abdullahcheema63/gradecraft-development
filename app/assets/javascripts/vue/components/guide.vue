<template>
  <div class="accordion guide" @click="toggleActive">
    <h3 :class="{open:active}">
      <span></span>
    </h3>
    <div :class="guideClass">
      <div>
        <p>
          hellooo it's stormy out there
        </p>
        <slot></slot>
      </div>
    </div>
  </div>
</template>

<script lang='coffee'>`
module.exports = {
  name: 'guide',
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
    guideClass() {
      if (this.active) {
        return 'is-open';
      }
      return 'is-closed';
    }
  }
}
`</script>
