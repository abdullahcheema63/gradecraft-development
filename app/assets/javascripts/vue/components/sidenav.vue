<template>
  <div class="side_nav bg-blue" :class="sidenavClass">
    <div class="nav_icon" :class="{open:active}" @click="toggleActive">
      <div></div>
    </div>

    <div class="nav_links" :class="sidenavClass">
      <!-- Note to E from S: conditional ACTIVE class goes on the active side nav page link -->
      <p class="active">
        <a>Dashboard</a>
      </p>
      <p>
        <a>Courses</a>
      </p>
      <p>
        <a>Users</a>
      </p>
      <p>
        <a>Subscriptions</a>
      </p>
      <p>
        <a>Institutions</a>
      </p>
      <p>
        <a>Utilities</a>
      </p>
    </div>
  </div>

</template>


<script lang='coffee'>`
module.exports = {
  name: 'sidenav',
  props: ['sidenav_class'],
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
    sidenavClass() {
      if (this.active) {
        return 'is-open';
      }
      return 'is-closed';
    }
  }
}
`</script>
