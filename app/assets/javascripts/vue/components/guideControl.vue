<template>
  <div id="guide_control" :class="guideClass" @click="toggleGuide">
    <h4 v-if="showGuide">Hide<br/>Guide</h4>
    <h4 v-else>Show<br/>Guide</h4>
  </div>
</template>

<script lang='coffee'>`
module.exports = {
  name: 'guide-control',
  data() {
    return {
      prevScrollPos: null
    }
  },
  created: function() {
    this.prevScrollPos = window.pageYOffset;
    window.addEventListener('scroll', this.scrollGuide);
  },
  destroyed: function() {
    window.removeEventListener('scroll', this.scrollGuide);
  },
  methods: {
    toggleGuide(){
      this.$store.dispatch('toggleGuideControl')
    },
    scrollGuide(e) {
      var currentScrollPos = window.pageYOffset;

      if (this.prevScrollPos > currentScrollPos) {
        document.getElementById("guide_control").classList.remove("mini");
      } else {
        document.getElementById("guide_control").classList.add("mini");
      }

      this.prevScrollPos = currentScrollPos;
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
