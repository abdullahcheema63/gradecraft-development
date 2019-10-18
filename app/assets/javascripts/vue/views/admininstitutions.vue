<template>
  <div class="content_wrapper">
    <sidenav :sidenavClass="sidenavClass" @toggleActive="toggleActive"></sidenav>
    <institutions :maincontentClass="maincontentClass" @shiftContent="shiftContent"></institutions>
  </div>
</template>


<script lang='coffee'>`
module.exports = {
  name: 'admininstitutions',
  components: {
    sidenav: () => VComponents.get('vue/components/sidenav'),
    institutions: () => VComponents.get('vue/components/admin/institutions'),
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
