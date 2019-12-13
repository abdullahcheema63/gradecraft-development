<template>
  <div class="table_pagination">
    <p>
      Results: <span class="displayed">{{itemDisplayRange}}</span> of <span class="total">{{totalPaginatedItems}}</span>
    </p>
    <div v-if="totalPaginatedItems">
      <button class="table_prev" :disabled="currentPage === 0" @click="updateCurrentPage(currentPage - 1)"></button>
      <button v-for="page in pageNumbers" :key="page" :class="{active :currentPage === page}" @click="updateCurrentPage(page)">{{page + 1}}</button>
      <button class="table_next" :disabled="currentPage === maxPageNumber - 1" @click="updateCurrentPage(currentPage + 1)"></button>
    </div>
  </div>
</template>

<script lang='coffee'>`
module.exports = {
  name: 'table-pagination',
  props: ['items'],
  data() {
    return {
      currentPage: 0,
      paginateBy: 10,
    }
  },
  computed: {
    totalPaginatedItems(){
      return this.items ? this.items.length : 0
    },
    maxPageNumber(){
      return Math.ceil(this.totalPaginatedItems / this.paginateBy);
    },
    pageNumbers(){
      return Array.apply(null, {length: this.maxPageNumber}).map(Number.call, Number);
    },
    currentPageItemMin(){
      if (this.items.length === 0){
        return 0
      } else {
        return this.currentPage * this.paginateBy + 1
      }
    },
    currentPageItemMax(){
      if (this.items.length === 0){
        return 0
      } else {
        return this.currentPage * this.paginateBy + this.paginateBy
      }
    },
    itemDisplayRange(){
      if (this.currentPageItemMin === this.totalPaginatedItems){
        return this.totalPaginatedItems
      } else if (this.totalPaginatedItems < this.currentPageItemMax) {
        return this.currentPageItemMin + "–" + this.totalPaginatedItems
      }
      return this.currentPageItemMin + "–" + this.currentPageItemMax
    }
  },
  methods: {
    updateCurrentPage(page){
      this.currentPage = page
      var itemRange = {
        min: this.currentPageItemMin,
        max: this.currentPageItemMax
      }
      this.$emit('paginate', itemRange)
    }
  }
}
`</script>
