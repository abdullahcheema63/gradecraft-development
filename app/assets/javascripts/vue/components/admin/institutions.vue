<template>
  <div class="main_content" :class="maincontentClass">
    <div class="content_block intro">
      <h1>{{environmentName}} Institutions</h1>
      <p>
        Manage and view all institutions.
      </p>
    </div>

    <div class="content_block">
      <div class="table_functions">
        <div class="filter_box">
          <a class="button action secondary next" href="institutions/new">Add an institution</a>
        </div>
        <div class="search_box">
          <form>
            <div class="form_elem">
              <input type="search" id="name_contains" v-model="searchName" placeholder="Search by institution name" />
              <label for="name_contains">Search Institutions</label>
            </div>
          </form>
        </div>
      </div>
      <div v-if="currentPageAllInstitutions.length">
        <div class="table_container">
          <table>
            <thead>
              <tr>
                <th>Name </th>
                <th>Has Site License?</th>
                <th>Type</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="institution in currentPageAllInstitutions" :key="institution.id">
                <td>{{institution.name}}</td>
                <td><span :class="{checked: institution.hasSiteLicense}"></span> </td>
                <td>{{institution.institutionType}}</td>
                <td>
                  <a class="button secondary" :href="institution.editURL">Edit</a>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        <tablePagination :items="filteredAllInstitutions" @paginate="paginateItems"></tablePagination>
        <button type="button" class="action secondary">Export this table view</button>
        <p style="background: aquamarine;">
          ^ Not done
        </p>
      </div>
      <div v-else>
        <h4 class="pink_text">No institutions found with those search parameters. </h4>
      </div>
    </div>
  </div>
</template>

<script lang='coffee'>`
module.exports = {
  name: 'institutions',
  props: ['maincontentClass'],
  components: {
    tablePagination: () => VComponents.get('vue/components/structure/tablePagination'),
  },
  created: function() {
    this.$store.dispatch("getAllInstitutions");
  },
  data() {
    return {
      active: false,
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
    },
    user(){
      return this.$store.getters.user;
    },
    environmentName(){
      if (this.user.environment === 'development'){return "Local"}
      if (this.user.environment === 'production'){return "Umich"}
      if (this.user.environment === 'beta'){return "App"}
    },
  },
  methods: {
    shiftContent() {
      this.active = !this.active;
      this.$emit('shiftContent', this.active)
    },
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
