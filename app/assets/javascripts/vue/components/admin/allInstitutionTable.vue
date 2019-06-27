<template>
  <div>
    <h2>All Institutions</h2>
    <p>Need to add button to add Institution</p>
    <p>Need to add search text bar</p>
    <div class="table_container">
      <table>
        <thead>
          <tr>
            <th>Name </th>
            <th>Has Site License?</th>
            <th>Type</th>
            <th>Options</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="institution in allInstitutions" :key="institution.id">
            <td>{{institution.name}}</td>
            <td><span :class="{checked: institution.hasSiteLicense}"></span> </td>
            <td>{{institution.institutionType}}</td>
            <td>
              <buttonDropdown>
                <template slot="button_text">Options</template>
                <template slot="content">
                  <ul>
                    <li><a :href="institution.editURL">Edit</a> </li>
                  </ul>
                </template>
              </buttonDropdown>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <tablePagination :items="allInstitutions" @paginate="paginateItems"></tablePagination>
  </div>
</template>

<script lang='coffee'>`
module.exports = {
  name: 'all-institution-table',
  components: {
    tablePagination: () => VComponents.get('vue/components/tablePagination'),
    buttonDropdown: () => VComponents.get('vue/components/buttonDropdown'),
  },
  data() {
    return {
      currentPageItemMin: 0,
      currentPageItemMax: 10,
    }
  },
  computed: {
    allInstitutions(){
      return this.$store.state.allInstitutions;
    },
  },
  methods: {
    paginateItems(itemRange){
      this.currentPageItemMin = itemRange.min - 1;
      this.currentPageItemMax = itemRange.max;
    }
  }
}
`</script>
