<template>
  <div>
    <h2>Account Status</h2>
    <licenses-details v-if="hasLicense" :license="this.userLicense"/>
    <div v-else>
      <p>
        Your
        <b>free trial account,</b>
        allows you to explore GradeCraft as much as you’d like! <br />
        The only things you can’t do are:
      </p>
      <ul>
        <li>Integrate with other tools (like Canvas or Moodle)</li>
        <li>Import or add other users (such as assistants and students)</li>
      </ul>
      <p>
        If you like what you see, you can upgrade your account with a license of your choice!
        <a href="https://gradecraft.com/licenses/" target="_blank">Learn more about licensing options</a> to see what’s best for you; we have options for Higher Ed and K–12.
      </p>
    </div>

    <buttonModal button_class="action secondary" ref="buttonModal_license">
      <template slot="button-text" v-if="hasLicense">Renew my account license</template>
      <template slot="button-text" v-else>Upgrade my account!</template>

      <template slot="heading" v-if="hasLicense">Account license renewal</template>
      <template slot="heading" v-else>Account Upgrade</template>

      <template slot="content">
        <div>
          <licenses-renew-form @updated="onUpdated" v-if="hasLicense" :license="this.userLicense" :license-type="licenseType" :stripePk="stripePk" />
          <licenses-buy-form @updated="onUpdated" v-if="!hasLicense" :license-type-options="licenseTypeOptions" :stripePk="stripePk" />
        </div>
      </template>
    </buttonModal>
    <br />
    <p v-if="hasLicense">
      To change your license type or add additional licensed courses, please email us at
      <a href="mailto:help@gradecraft.com">help@gradecraft.com</a>. We’re more than happy to help!
    </p>
    <p v-else>
      If you need a license for an entire school or district, or a custom arrangement, please don’t hesitate to email us at
      <a href="mailto:help@gradecraft.com">help@gradecraft.com</a>. We’re more than happy to help!
    </p>

    <licenses-course-selector @updated="onUpdated" v-if="hasLicense" :license="this.userLicense" :courses="courses" />
  </div>
</template>

<script lang="coffee">
```
const data = {
  courses: [],
  showRenew: false,
};

module.exports = {
  name: "licenses-dash",
  components: {
    "licenses-buy-form": () => VComponents.get("vue/components/licenses/buyForm"),
    "licenses-renew-form": () => VComponents.get("vue/components/licenses/renewForm"),
    "licenses-course-selector": () => VComponents.get("vue/components/licenses/courseSelector"),
    "licenses-details": () => VComponents.get("vue/components/licenses/details"),
    buttonModal: () => VComponents.get('vue/components/buttonModal'),
  },
  data: function() { return data; },
  props: {
    licenseTypeOptions: Array,
    stripePk: String,
  },
  computed: {
    userLicense(){
      return this.$store.state.userLicense
    },
    licensedCourses(){
      return this.$store.state.userLicense.courses
    },
    hasLicense: function() {
      return !!this.userLicense;
    },
    licenseType: function() {
      return (this.userLicense && this.licenseTypeOptions)
        ? this.licenseTypeOptions.find(lt => lt.id === this.userLicense.license_type_id)
        : undefined;
    },
  },
  methods: {
    toggleRenew: function() {
      this.showRenew = !this.showRenew;
    },
    onUpdated: function(license) {
      console.log("onUpdated");
      console.log(license);
      data.license = license;
    },
    updateLicense(){
      this.$refs.buttonModal_license.toggleModalState()
    }
  },
  created: async function() {
    this.$store.dispatch("getUserLicense");
  },
}
```
</script>
