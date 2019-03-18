<template>
  <div id="guide_control" :class="guideClass" @click="toggleGuide">
    <h4 v-if="showGuide">Hide<br/>Guide</h4>
    <h4 v-else>Show<br/>Guide</h4>
  </div>
</template>

<script lang='coffee'>`
module.exports = {
  name: 'guide-control',
  methods: {
    toggleGuide(){
      this.$store.dispatch('toggleGuideControl')
    }
  },
  computed: {
    showGuide(){
      return this.$store.getters.userGuideStatus;
    },
    guideClass(){
      if ( this.showGuide ){ return "guide-showing"}
      else { return 'guide-hiding'}
    }
  }
}
`</script>
