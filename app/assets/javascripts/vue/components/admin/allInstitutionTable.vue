<template>
  <div>
    <h2>All Institutions</h2>
    <form>
      <div class="form_elem">
        <input type="text" id="name_contains" v-model="searchName" placeholder="Name contains..." />
        <label for="name_contains">Name contains</label>
      </div>
    </form>
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
          <tr v-for="institution in currentPageAllInstitutions" :key="institution.id">
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
    <tablePagination :items="filteredAllInstitutions" @paginate="paginateItems"></tablePagination>
    <a class="button action next" href="institutions/new">Add a new institution</a>
  </div>
</template>

<script lang='coffee'>`
module.exports = {
  name: 'all-institution-table',
  components: {
    tablePagination: () => VComponents.get('vue/components/structure/tablePagination'),
    buttonDropdown: () => VComponents.get('vue/components/structure/buttonDropdown'),
  },
  data() {
    return {
      searchName: "",
      currentPageItemMin: 0,
      currentPageItemMax: 10,
    }
  },
  computed: {
    allInstitutions(){
      return this.$store.state.allInstitutions;
    },
    filteredAllInstitutions(){
      var allInstitutions = this.allInstitutions;
      return allInstitutions.filter(this.filterAllInstitutions)
    },
    currentPageAllInstitutions(){
      return this.filteredAllInstitutions.slice(this.currentPageItemMin, this.currentPageItemMax)
    }
  },
  methods: {
    filterAllInstitutions(institution){
      if(this.searchName){
        var name = institution.name
        name = name.toLowerCase();

        if(!(name.includes(this.searchName.toLowerCase()))) {return false}
      }
      return institution
    },
    paginateItems(itemRange){
      this.currentPageItemMin = itemRange.min - 1;
      this.currentPageItemMax = itemRange.max;
    }
  }
}
`</script>
