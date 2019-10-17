<template>
  <div class="content_wrapper" :class="maincontentClass">
    <sidenav :sidenavClass="sidenavClass" @toggleActive="toggleActive"></sidenav>
    <utilities :maincontentClass="maincontentClass" @shiftContent="shiftContent"></utilities>
  </div>
</template>


<script lang='coffee'>`
module.exports = {
  name: 'adminutilities',
  components: {
    sidenav: () => VComponents.get('vue/components/sidenav'),
    utilities: () => VComponents.get('vue/components/admin/utilities'),
  },
  data() {
    return {
      active: false
    }
  },
  methods: {
    toggleActive(activeState) {
      this.active = activeState
    },
    shiftContent(activeState) {
      this.active = activeState
    }
  },
  computed: {
    sidenavClass() {
      if (this.active) {
        return 'is-open';
      }
      return 'is-closed';
    },
    maincontentClass() {
      if (this.active) {
        return 'sidenav-open';
      }
      return 'sidenav-closed';
    }
  }
}
`</script>
