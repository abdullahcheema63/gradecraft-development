<template>
  <div class="main_content" :class="maincontentClass">
    <div class="content_block intro">
      <h1>{{environmentName}} Users</h1>
      <p>
        Manage and view all users.
      </p>
    </div>

    <tabContainer>
      <template slot="tabBarNav">
        <div v-for="option in tabBarOption">
          <input type="radio" :id="option" :value="option" v-model="tabSection[0]" name="tab_group_1" />
          <label :for="option">{{option}}</label>
        </div>
      </template>
      <template slot="tabSections">
        <div v-if="tabSection[0]==='Instructors'">
          <instructors></instructors>
        </div>
        <div v-if="tabSection[0]==='All Users'">
          <users></users>
        </div>
      </template>
    </tabContainer>
  </div>
</template>

<script lang='coffee'>`
module.exports = {
  name: 'userspage',
  props: ['maincontentClass'],
  components: {
    tabContainer: () => VComponents.get('vue/components/structure/tabContainer'),
    users: () => VComponents.get('vue/components/admin/users'),
    instructors: () => VComponents.get('vue/components/admin/instructors'),
  },
  created: function() {
    this.$store.dispatch("getAllUsers");
  },
  data() {
    return {
      active: false,
      tabSection: ["Instructors"],
      searchName: "",
      searchUsername: "",
      searchEmail: "",
      currentPageItemMin: 0,
      currentPageItemMax: 10,
    }
  },
  computed: {
    tabBarOption(){
      var options = ["Instructors", "All Users"]
      return options
    },
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
