<template>
  <div :class="guideClassControl">
    <h3 :class="{open:active}" @click="toggleActive">
      <span></span>
    </h3>
    <div :class="guideClass">
      <div>
        <slot></slot>
      </div>
    </div>
  </div>
</template>

<script lang='coffee'>`
module.exports = {
  name: 'guide-message',
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
    },
    showGuide(){
      return this.$store.getters.userGuideStatus;
    },
    guideClassControl(){
      if ( this.showGuide ){ return "accordion guide"}
      else { return "accordion guide hiding"}
    }
  }
}
`</script>
