<template>
  <div class="content_block">
    <p>Search for users across all courses and account types. </p>

    <h2>Search by:</h2>
    <form>
      <div class="form_elem">
        <input type="search" id="name_contains" v-model="searchName" placeholder="Name contains..." />
        <label for="name_contains">Name contains</label>
      </div>
      <div class="form_elem">
        <input type="search" id="username_contains" v-model="searchUsername" placeholder="Username contains..." />
        <label for="username_contains">Username contains</label>
      </div>
      <div class="form_elem">
        <input type="search" id="email_contains" v-model="searchEmail" placeholder="Email contains..." />
        <label for="email_contains">Email contains</label>
      </div>
    </form>
    <h2>Search Results:</h2>
    <div v-if="currentPageAllUsers.length">
      <div class="table_container">
        <table>
          <thead>
            <tr>
              <th>User ID </th>
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
              <td class="no_wrap"><a :href="user.url">{{user.firstName}}</a> </td>
              <td class="no_wrap"><a :href="user.url">{{user.lastName}}</a> </td>
              <td class="no_wrap">{{user.email}}</td>
              <template v-if="user.courses.length">
                <td>
                  <ul>
                    <li v-for="course in user.courses" :key="course.id">
                      <a :href="course.url" class="table_truncate">{{course.name}}</a>
                    </li>
                  </ul>
                </td>
                <td>
                  <ul><li v-for="course in user.courses" :key="course.id">{{course.role}}&nbsp;</li></ul>
                </td>
                <td>
                  <ul><li  v-for="course in user.courses" :key="course.id">{{course.semester}}&nbsp;</li></ul>
                </td>
                <td>
                  <ul><li v-for="course in user.courses" :key="course.id">{{course.year}}&nbsp;</li></ul>
                </td>
                <td>
                  <ul><li v-for="course in user.courses" :key="course.id">{{course.score}}&nbsp;</li></ul>
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
      <button type="button" class="action secondary">Export this table view</button>
      <p style="background: aquamarine;">
        ^ Not done
      </p>
    </div>
    <div v-else>
      <h4 class="pink_text">No users found with those search parameters. </h4>
    </div>
  </div>
</template>

<script lang='coffee'>`
module.exports = {
  name: 'users',
  components: {
    tablePagination: () => VComponents.get('vue/components/structure/tablePagination'),
  },
  created: function() {
    this.$store.dispatch("getAllUsers");
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
