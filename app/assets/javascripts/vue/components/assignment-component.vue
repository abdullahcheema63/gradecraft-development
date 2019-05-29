<template>
  <accordionComponent>
    <template slot="heading">Assignments</template>
    <template slot="content">
      <div class="table_container">
        <table>
          <thead>
            <tr>
              <th>Assignment</th>
              <th>Due at</th>
              <th>Options</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>Hello</td>
              <td>World</td>
              <td>I am Me</td>
            </tr>
          </tbody>
        </table>
      </div>
    </template>
  </accordionComponent>
</template>

<script lang='coffee'>`
module.exports = {
  name: 'assignment-component',
  components: {
    accordionComponent: () => VComponents.get('vue/components/accordionComponent'),
    tablePagination: () => VComponents.get('vue/components/tablePagination'),
  },
  data() {
    return {
      hello: "hello"
    }
  },
  created: function() {
    this.prevScrollPos = window.pageYOffset;
    window.addEventListener('scroll', this.scrollGuide);
  },
  destroyed: function() {
    window.removeEventListener('scroll', this.scrollGuide);
  },
  computed: {
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
  }
}
`</script>
