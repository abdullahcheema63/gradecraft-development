<template>
  <div>
    <licenses-course-selector :license="userLicense" :courses="userCourses" />

    <div class="content_block bg-green_mint_2">
      <h2>My Subscription Cost</h2>
      <div class="subscription_cost">
        <h3 class="lining_figures">
          <span>
            <sup>$</sup>
            40
          </span>
        </h3>
        <p>
          <strong>per month</strong>
        </p>
      </div>
      <p>
        You will be <strong>billed on the X of every month.</strong>
        <br />
        <a href="https://gradecraft.com/licenses/" target="_blank">Review our subscription price options</a>
      </p>
    </div>

    <div class="content_block bg-green_mint_2">
      <h2 class="unspace-top">My Payment Methods</h2>
      <form>
        <div class="form_options payment_method">
          <input type="radio" id="payment_1" checked="checked" name="payment_group" />
          <div>
            <p>
              <strong>Visa</strong>
              **** **** **** 4242 <span></span> Expires 04/2024
            </p>
            <dropdownDotsComponent>
              <template slot="content">
                <ul>
                  <li>
                    <a>Edit</a>
                  </li>
                  <li>
                    <a>Delete</a>
                  </li>
                </ul>
              </template>
            </dropdownDotsComponent>
          </div>
        </div>
        <div class="form_options payment_method">
          <input type="radio" id="payment_2" name="payment_group" />
          <div>
            <p>
              <strong>Mastercard</strong>
              **** **** **** 4242 <span></span> Expires 04/2024
            </p>
            <dropdownDotsComponent>
              <template slot="content">
                <ul>
                  <li>
                    <a><label for="payment_2">Make Primary</label></a>
                  </li>
                  <li>
                    <a>Edit</a>
                  </li>
                  <li>
                    <a>Delete</a>
                  </li>
                </ul>
              </template>
            </dropdownDotsComponent>
          </div>
        </div>

        <div class="form_options alt-2">
          <input type="checkbox" id="service_terms_agreement" checked="checked" />
          <label for="service_terms_agreement">I accept GradeCraft’s
            <a href="#">Terms of Service</a>
          </label>
        </div>

        <button type="submit" class="action">Save my changes</button>
      </form>
    </div>


    <!-- <div class="content_block bg-green_mint">
      <h2>Manage My License Package</h2>
      <licenses-details v-if="hasLicense" :license="this.userLicense" :license-type="licenseType" :courses="userCourses" />
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
            <licenses-renew-form v-if="hasLicense" :license="this.userLicense" :license-type="licenseType" :stripePk="stripePk" />
            <licenses-buy-form v-if="!hasLicense" :license-type-options="licenseTypeOptions" :stripePk="stripePk" />
          </div>
        </template>
      </buttonModal>

      <p v-if="hasLicense">
        To change your license package or add additional course licenses, please email us at
        <a href="mailto:help@gradecraft.com">help@gradecraft.com</a>. We’re more than happy to help!
      </p>
      <p v-else>
        If you need a license package for an entire school or district, or a custom arrangement, please don’t hesitate to email us at
        <a href="mailto:help@gradecraft.com">help@gradecraft.com</a>. We’re more than happy to help!
      </p>
    </div> -->

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
    buttonModal: () => VComponents.get('vue/components/structure/buttonModal'),
    dropdownDotsComponent: () => VComponents.get('vue/components/structure/dropdownDotsComponent')
  },
  data: function() { return data; },
  props: {
    stripePk: String,
  },
  computed: {
    licenseTypeOptions(){
      return this.$store.state.allLicenseTypes
    },
    userLicense(){
      return this.$store.state.userLicense
    },
    userCourses(){
      return this.$store.getters.userCourseMemberships
    },
    hasLicense(){
      return !!this.userLicense;
    },
    licenseType() {
      return (this.userLicense && this.licenseTypeOptions)
        ? this.licenseTypeOptions.find(lt => lt.id === this.userLicense.license_type_id)
        : undefined;
    },
  },
  methods: {
    toggleRenew() {
      this.showRenew = !this.showRenew;
    },
    updateLicense(){
      this.$refs.buttonModal_license.toggleModalState()
    }
  },
  created: function() {
    this.$store.dispatch("getUserLicense");
    this.$store.dispatch("getCourseMemberships");
    this.$store.dispatch("getAllLicenseTypes");
  },
}
```
</script>
