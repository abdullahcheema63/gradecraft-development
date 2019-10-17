<template>
  <div class="content_wrapper">
    <sidenav :sidenavClass="sidenavClass" @toggleActive="toggleActive"></sidenav>
    <index :maincontentClass="maincontentClass" @shiftContent="shiftContent"></index>
  </div>
</template>


<script lang='coffee'>`
module.exports = {
  name: 'adminindex',
  components: {
    sidenav: () => VComponents.get('vue/components/sidenav'),
    index: () => VComponents.get('vue/components/admin/index'),
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
