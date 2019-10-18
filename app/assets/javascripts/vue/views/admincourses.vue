<template>
  <div class="content_wrapper">
    <sidenav :sidenavClass="sidenavClass" @toggleActive="toggleActive"></sidenav>
    <courses :maincontentClass="maincontentClass" @shiftContent="shiftContent"></courses>
  </div>
</template>


<script lang='coffee'>`
module.exports = {
  name: 'admincourses',
  components: {
    sidenav: () => VComponents.get('vue/components/sidenav'),
    courses: () => VComponents.get('vue/components/admin/courses'),
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
