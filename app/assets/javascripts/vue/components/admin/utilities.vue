<template>
  <div class="main_content" :class="maincontentClass">
    <div class="content_block intro">
      <h1>_App _or_ U-M_ Utilities</h1>
      <p style="background: aquamarine;">
        Note to E from S: the “App” vs “U-M” part of the heading above is conditional, based on which data side the admin is logged into.
      </p>
      <p>
        THIS WAS ONCE THE “TOOLS” SECTION from the old side nav.
      </p>
    </div>

    <div class="content_block">
      <p>
        Unlocks is the only thing we have right now?
      </p>
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
    }
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
