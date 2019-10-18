<template>
  <div class="side_nav bg-blue" :class="sidenavClass">
    <div class="nav_icon" :class="{open:active}" @click="toggleActive">
      <div></div>
    </div>
    <div class="nav_links" :class="sidenavClass">
      <!-- Note to E from S: conditional ACTIVE class goes on the active side nav page link -->
      <p class="active">
        <a href="/overview/">Dashboard</a>
      </p>
      <p>
        <a href="/overview/courses/">Courses</a>
      </p>
      <p>
        <a href="/overview/users/">Users</a>
      </p>
      <p>
        <a href="/overview/subscriptions/">Subscriptions</a>
      </p>
      <p>
        <a href="/overview/institutions/">Institutions</a>
      </p>
      <p>
        <a href="/overview/utilities/">Utilities</a>
      </p>
    </div>
  </div>

</template>


<script lang='coffee'>`
module.exports = {
  name: 'sidenav',
  props: ['sidenavClass'],
  data() {
    return {
      active: false
    }
  },
  methods: {
    toggleActive() {
      this.active = !this.active;
      this.$emit('toggleActive', this.active)
    }
  }
}
`</script>
