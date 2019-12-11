<template>
  <div class="main_content" :class="maincontentClass">
    <div class="content_block intro">
      <h1>{{environmentName}} Utilities</h1>
      <p>
        THIS WAS ONCE THE “TOOLS” SECTION from the old side nav.
      </p>
    </div>

    <div class="content_block">
      <p>
        Unlocks is the only thing we have right now?
      </p>
    </div>
    <div class="yeti-loading_spin">
      <div></div>
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
