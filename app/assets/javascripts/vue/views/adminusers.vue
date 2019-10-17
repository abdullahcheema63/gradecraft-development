<template>
  <div class="content_wrapper">
    <sidenav :sidenavClass="sidenavClass" @toggleActive="toggleActive"></sidenav>
    <userspage :maincontentClass="maincontentClass" @shiftContent="shiftContent"></userspage>
  </div>
</template>


<script lang='coffee'>`
module.exports = {
  name: 'adminusers',
  components: {
    sidenav: () => VComponents.get('vue/components/sidenav'),
    userspage: () => VComponents.get('vue/components/admin/userspage'),
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
