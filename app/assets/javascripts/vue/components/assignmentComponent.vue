<template>
  <accordionComponent>
    <template slot="heading">Assignments</template>
    <template slot="content">
      <div class="table_container">
        <table>
          <thead>
            <tr>
              <th>Assignment</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="assignment in allAssignments">
              <accordionComponent>
                <template slot="heading">{{assignment.name}}</template>
                <template slot="content">
                  {{assignment.points}}
                </template>
              </accordionComponent>
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
  computed: {
    allAssignments(){
      var assignments = [
        {
          name: "Assignment1",
          points: 1000,
          dueAt: "december 32 2021",
        },
        {
          name: "Assignment2",
          points: 2000,
          dueAt: "december 32 2222"
        }
      ]
      return assignments
    }
  },
  methods: {
  }
}
`</script>
