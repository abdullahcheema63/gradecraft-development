<template>
  <accordionComponent>
    <template slot="heading">Assignments</template>
    <template slot="content">
      <div class="table_container">
        <table class="accordion_table">
          <thead>
            <tr>
              <th class="assignment_title">Assignment Title</th>
              <th class="assignment_due">Due Date</th>
              <th class="assignment_legend"></th>
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
            <tr class="accordion">
              <td>
                <h3>
                  <span></span>
                  Test Assignment Title
                </h3>
              </td>
              <td>
                test
              </td>
              <td>
                test
              </td>
              <div class="is-closed">
                <div>
                  <h5>Testing content</h5>
                </div>
              </div>
            </tr>
          </tbody>
        </table>
      </div>

      <h2>Test Structure: Static Prototype</h2>
      <div class="table_container">
        <div class="accordion_table">
          <div class="accordion_table-head">
            <p>Assignment Title</p>
            <p>Due Date</p>
            <p> </p>
          </div>
          <div class="accordion_table-body">
            <tableAccordion v-for="assignment in allAssignments">
              <template slot="assignment_title">{{assignment.name}}</template>
              <template slot="assignment_due">{{assignment.dueBy}}</template>
              <template slot="assignment_content">
                <div>
                  <h3>Assignment Summary</h3>
                  <p>
                    <b>Opens on:</b>
                    <br />
                    {{assignment.openOn}}
                  </p>
                  <p>
                    <b>Due by:</b>
                    <br />
                    {{assignment.dueBy}}
                  </p>
                  <p>
                    <b>Accepted until:</b>
                    <br />
                    {{assignment.acceptUntil}}
                  </p>

                </div>
                <div>
                  <h3>Assignment Actions</h3>
                  {{assignment.points}}
                </div>
              </template>
            </tableAccordion>
          </div>
        </div>
      </div>
    </template>
  </accordionComponent>
</template>

<script lang='coffee'>`
module.exports = {
  name: 'assignment-component',
  components: {
    accordionComponent: () => VComponents.get('vue/components/accordionComponent'),
    tableAccordion: () => VComponents.get('vue/components/tableAccordion'),
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
          openOn: "December 33, 2020",
          dueBy: "December 32 2021",
          acceptUntil: "May 40, 2040"
        },
        {
          name: "Assignment2",
          points: 2000,
          openOn: "December 33, 2020",
          dueBy: "December 32 2222",
          acceptUntil: "May 40, 2040"
        }
      ]
      return assignments
    }
  },
  methods: {
  }
}
`</script>
