<template>
  <div class="main_content" :class="maincontentClass">
    <div class="content_block intro">
      <h1>Subscriptions</h1>
      <p>
        Manage and view all instructors with active subscriptions.
      </p>
    </div>

    <div class="content_block">
      <div class="table_functions">
        <div class="filter_box">
        </div>
        <div class="search_box">
          <form>
            <div class="form_elem">
              <input type="search" id="name_contains" v-model="searchName" placeholder="Search by instructor name" />
              <label for="name_contains">Search instructors</label>
            </div>
          </form>
        </div>
      </div>
      <div v-if="currentPageAllSubscriptions.length">
        <div class="table_container">
          <table>
            <thead>
              <tr>
                <th>First Name </th>
                <th>Last Name </th>
                <th>Subscription Renewal Date </th>
                <th>Failed Last Payment </th>
                <th># Subscribed Courses </th>
                <th>Monthly Cost ($)</th>

                <th>Subscribed Courses </th>

                <th>Unpublished</th>
                <th>Date Last Paid</th>

                <th>Actions </th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="subscriber in currentPageAllSubscriptions" :key="subscriber.id">
                <!-- <td><a href="#">{{instructor.firstName}}</a> </td>
                <td class="no_wrap"><a href="#">{{instructor.lastName}}</a> </td> -->
                <!-- In the future, the users' name links will work -->
                <td>{{subscriber.firstName}} </td>
                <td class="no_wrap">{{subscriber.lastName}} </td>

                <td>{{formatDate(subscriber.renewalDate)}} </td>
                <td><span :class="{alert: !subscriber.failedLastPayment}">&nbsp;</span></td>
                <td>{{subscriber.subscribedCourses}} </td>
                <td>{{subscriber.costPerMonth}} </td>

                <template v-if="subscriber.courses">
                  <td>
                    <ul>
                      <li v-for="course in subscriber.courses" :key="course.id">
                        <a :href="course.url" class="table_truncate" :title="course.name">{{course.name}}</a>
                      </li>
                    </ul>
                  </td>
                  <td>
                    <ul>
                      <li v-for="course in subscriber.courses" :key="course.id">
                        <span :class="{alert: !course.published}">&nbsp;</span>
                      </li>
                    </ul>
                  </td>
                </template>
                <template v-else>
                  <td></td>
                  <td></td>
                  <td></td>
                </template>

                <td>{{formatDate(subscriber.lastPaymentDate)}} </td>

                <td>
                  <a class="button secondary" :href="'mailto:' + subscriber.email">Email</a>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        <tablePagination :items="filteredAllSubscriptions" @paginate="paginateItems"></tablePagination>
        <button type="button" class="action secondary">Export this table view</button>
        <p style="background: aquamarine;">
          ^ Not done
        </p>
      </div>
      <div v-else>
        <h4 class="pink_text">No users found with those search parameters. </h4>
      </div>
    </div>
  </div>
</template>

<script lang='coffee'>`
module.exports = {
  name: 'subscriptions',
  props: ['maincontentClass'],
  components: {
    tablePagination: () => VComponents.get('vue/components/structure/tablePagination'),
  },
  created: function() {
    this.$store.dispatch("getAllSubscriptions");
  },
  data() {
    return {
      active: false,
      currentPageItemMin: 0,
      currentPageItemMax: 10,
      searchName: "",
      showSubscribed: "",
      showUnsubscribed: "",
      showInActiveCourse: "",
      currentPageAllSubscriptions: {},
      filteredAllSubscriptions: {}
    }
  },
  computed: {
    allSubscriptions(){
      return this.$store.getters.adminAllSubscriptions;
    },
    filteredAllSubscriptions1(){
      var allSubscriptions = this.allSubscriptions
      console.log("all subscritpions: ", this.allSubscriptions)
      return allSubscriptions.filter(this.filterAllSubscriptions)
    },
    currentPageAllSubscriptions1(){
      return this.filteredAllSubscriptions.slice(this.currentPageItemMin, this.currentPageItemMax);
    }
  },
  watch: {
    allSubscriptions(newVal, oldVal){
      this.filteredAllSubscriptions = newVal.filter(this.filterAllSubscriptions)
      this.currentPageAllSubscriptions = this.filteredAllSubscriptions.slice(this.currentPageItemMin, this.currentPageItemMax);
    }
  },
  methods: {
    shiftContent() {
      this.active = !this.active;
      this.$emit('shiftContent', this.active)
    },
    formatDate(date){
      return moment(String(date)).format('LLLL')
    },
    filterAllSubscriptions(subscriber){
      if(this.searchName){
        var name = subscriber.firstName + " " + subscriber.lastName
        name = name.toLowerCase();
        if(!(name.includes(this.searchName.toLowerCase()))) {return false}
      }
      if(this.showInActiveCourse){
        if(this.hasActiveCourse(subscriber.courses) != true){return false}
      }
      return subscriber
    },
    paginateItems(itemRange){
      this.currentPageItemMin = itemRange.min - 1;
      this.currentPageItemMax = itemRange.max;
    },
    hasActiveCourse(courses){
      var isActive = false
      courses.forEach(function (course) {
        if(course.active === true){isActive = true}
      });
      return isActive
    }
  }
}
`</script>
