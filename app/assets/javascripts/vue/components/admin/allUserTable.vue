<template>
  <div>
    <h2>Search for users across all courses and account types </h2>
    <h3>Search by: </h3>
    <form>
      <div class="form_elem">
        <input type="text" id="name_contains" v-model="searchName" placeholder="Name contains..." />
        <label for="name_contains">Name contains</label>
      </div>
      <div class="form_elem">
        <input type="text" id="username_contains" v-model="searchUsername" placeholder="Username contains..." />
        <label for="username_contains">Username contains</label>
      </div>
      <div class="form_elem">
        <input type="text" id="email_contains" v-model="searchEmail" placeholder="Email contains..." />
        <label for="email_contains">Email contains</label>
      </div>
    </form>
    <h3>Search Results:</h3>
    <div class="table_container">
      <table>
        <thead>
          <tr>
            <th>ID # </th>
            <th>First Name </th>
            <th>Last Name </th>
            <th>Email </th>
            <th>Courses </th>
            <th>Course User Type</th>
            <th>Semester </th>
            <th>Year </th>
            <th>Student Score </th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="user in currentPageAllUsers" :key="user.id">
            <td>{{user.id}}</td>
            <td><a :href="user.url">{{user.firstName}}</a> </td>
            <td><a :href="user.url">{{user.lastName}}</a> </td>
            <td>{{user.email}}</td>
            <template v-if="user.courses.length">
              <td>
                <ul><li v-for="course in user.courses" :key="course.id"><a :href="course.url">{{course.name}}</a> </li></ul>
              </td>
              <td>
                <ul><li v-for="course in user.courses" :key="course.id">{{course.role}} </li></ul>
              </td>
              <td>
                <ul><li  v-for="course in user.courses" :key="course.id">{{course.semester}}</li></ul>
              </td>
              <td>
                <ul><li v-for="course in user.courses" :key="course.id">{{course.year}}</li></ul>
              </td>
              <td>
                <ul><li v-for="course in user.courses" :key="course.id">{{course.score}}</li></ul>
              </td>
            </template>
            <template v-else>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            </template>
          </tr>
        </tbody>
      </table>
    </div>
    <tablePagination :items="filteredAllUsers" @paginate="paginateItems"></tablePagination>
  </div>
</template>

<script lang='coffee'>`
module.exports = {
  name: 'all-user-table',
  components: {
    tablePagination: () => VComponents.get('vue/components/structure/tablePagination'),
  },
  data() {
    return {
      searchName: "",
      searchUsername: "",
      searchEmail: "",
      currentPageItemMin: 0,
      currentPageItemMax: 10,
    }
  },
  computed: {
    allUsers(){
      return this.$store.state.allUsers;
    },
    filteredAllUsers(){
      var allUsers = this.allUsers;
      return allUsers.filter(this.filterAllUsers)
    },
    currentPageAllUsers(){
      return this.filteredAllUsers.slice(this.currentPageItemMin, this.currentPageItemMax);
    },
  },
  methods: {
    filterAllUsers(user){
      if(this.searchName){
        var name = user.firstName + " " + user.lastName
        name = name.toLowerCase();

        if(!(name.includes(this.searchName.toLowerCase()))) {return false}
      }
      if(this.searchEmail){
        if(!(user.email.includes(this.searchEmail))) {return false}
      }
      if(this.searchUsername){
        if(!(user.username.includes(this.searchUsername))) {return false}
      }
      return user
    },
    paginateItems(itemRange){
      this.currentPageItemMin = itemRange.min - 1;
      this.currentPageItemMax = itemRange.max;
    }
  }
}
`</script>
