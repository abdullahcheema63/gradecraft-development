<template>
  <div class="content_wrapper">
    <sidenav :sidenavClass="sidenavClass" @toggleActive="toggleActive"></sidenav>
    <subscriptions :maincontentClass="maincontentClass" @shiftContent="shiftContent"></subscriptions>
  </div>
</template>


<script lang='coffee'>`
module.exports = {
  name: 'adminsubscriptions',
  components: {
    sidenav: () => VComponents.get('vue/components/sidenav'),
    subscriptions: () => VComponents.get('vue/components/admin/subscriptions'),
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
