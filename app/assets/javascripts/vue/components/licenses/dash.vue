<template>
  <div>
    <licenses-course-selector>
    </licenses-course-selector>

    <div class="content_block bg-green_mint_2">
      <h2>My Subscription Cost</h2>
      <p>
        Based on your courses selected from the table above, your subscription cost will be:
      </p>
      <div class="subscription_cost">
        <h3 class="lining_figures">
          <span>
            <sup>$</sup>
            {{totalCost}}
          </span>
        </h3>
        <p>
          <strong>per month</strong>
        </p>
        new cost: {{newCost}}
        Currently paying (except if you upgrade enough to lower the price per course): {{originalCost}}
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
                  <!-- SOPHIA to ERIK: I think this "make primary" option could be a v-if situation? Because we only show this in the list for non-primary payment options -->
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

        <buttonModal button_class="secondary function add_something">
          <template slot="button-text">Add a new payment method</template>
          <template slot="heading">Add a new payment method</template>
          <template slot="content">
            <form>
              <licenses-payment-inputs ref="paymentInputs" :stripePk="stripePk"/>
              <button class="action" type="submit">Save</button>
            </form>
          </template>
        </buttonModal>


        <div class="form_options alt-2">
          <input type="checkbox" id="service_terms_agreement" checked="checked" required="required" />
          <label for="service_terms_agreement">I accept GradeCraft’s
            <a href="#">Terms of Service</a>
          </label>
        </div>

        <button type="submit" class="action">Save my changes</button>
      </form>
    </div>
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
    "licenses-payment-inputs": () => VComponents.get("vue/components/licenses/paymentInputs"),
    "licenses-buy-form": () => VComponents.get("vue/components/licenses/buyForm"),
    "licenses-renew-form": () => VComponents.get("vue/components/licenses/renewForm"),
    "licenses-course-selector": () => VComponents.get("vue/components/licenses/courseSelector"),
    "licenses-details": () => VComponents.get("vue/components/licenses/details"),
    buttonModal: () => VComponents.get('vue/components/structure/buttonModal'),
    dropdownDotsComponent: () => VComponents.get('vue/components/structure/dropdownDotsComponent')
  },
  data: function() {
    return {
        courses: [],
        showRenew: false,
      };
  },
  props: {
    stripePk: String,
  },
  computed: {
    activeBillingRecord(){
      let selectedCourseCount = this.selectedLicensedCourses.length
      for (let licenseType of this.licenseTypeOptions) {
        if (licenseType.minCourses <= selectedCourseCount && selectedCourseCount <= licenseType.maxCourses) {
          return licenseType
        }
      }
      return null
    },
    originalCost(){
      return this.totalCost - this.newCost;
    },
    totalCost(){
      return this.activeBillingRecord ? this.activeBillingRecord.pricePerCourse * this.selectedLicensedCourses.length : 0;
    },
    newCost(){
      return this.activeBillingRecord ? this.activeBillingRecord.pricePerCourse * this.newSubscribingCourseIds.length : 0;
    },
    paymentNeeded(){
      return this.newCost > 0;
    },
    licenseTypeOptions(){
      return this.$store.state.allLicenseTypes
    },
    userLicense(){
      return this.$store.state.userLicense
    },
    hasLicense(){
      return !!this.userLicense;
    },
    licenseType() {
      return (this.userLicense && this.licenseTypeOptions)
        ? this.licenseTypeOptions.find(lt => lt.id === this.userLicense.license_type_id)
        : undefined;
    },
    userCourses(){
      return this.$store.getters.userCourseMemberships
    },
    selectedLicensedCourses() {
      return this.userCourses.filter(course =>
          course.licensed || this.newSubscribingCourseIds.includes(course.id)
        );
    },
    newSubscribingCourseIds() {
      return this.$store.state.newSubscribingCourseIds;
    }
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
