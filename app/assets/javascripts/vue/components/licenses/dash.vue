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
      </div>

      <div class="payment_today" v-if="newCost > 0">
        <h3>Today’s payment total:</h3>
        <h3><span class="lining_figures"><sup>$</sup>{{newCost}}</span></h3>
      </div>

      <p>
        <br />
        Currently paying (except if you upgrade enough to lower the price per course):
        {{originalCost}}
      </p>

      <h3>Subscription Timing</h3>
      <p>
        You will be <strong>billed on the X of every month.</strong>
        Courses you pay for between billing cycles will be prorated by day.
        <a href="https://gradecraft.com/licenses/" target="_blank">Review our subscription price options</a>
      </p>
    </div>

    <div class="content_block bg-green_mint_2">
      <h2 class="unspace-top">My Payment Methods</h2>
      <form>
        <div v-for="paymentMethod in userSubscription.paymentMethods" class="form_options payment_method">
          <input type="radio" :id="paymentMethod.id" :value="paymentMethod.id" checked="checked" name="payment_group" />
          <div>
            <p>
              <strong>{{paymentMethod.brand}}</strong>
              **** **** **** {{paymentMethod.last4}} <span></span> Expires {{paymentMethod.exp_month}}/{{paymentMethod.exp_year}}
            </p>
            <dropdownDotsComponent>
              <template slot="content">
                <ul>
                  <li>
                    <a>Edit</a>
                  </li>
                  <li>
                    <a @click="removePaymentMethod(paymentMethod.id)">Delete</a>
                  </li>
                </ul>
              </template>
            </dropdownDotsComponent>
          </div>
        </div>
        <!-- STATIC PAYMENT METHOD LEFT FOR REFERANCE  -->
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
              <licenses-payment-inputs :stripePk="stripePk" :stripeSk="stripeSk" />
            </form>
          </template>
        </buttonModal>

        <div class="form_options alt-2">
          <input type="checkbox" id="service_terms_agreement" checked="checked" required="required" />
          <label for="service_terms_agreement">I accept GradeCraft’s
            <a href="#">Terms of Service</a>
          </label>
        </div>

        <buttonModal button_class="action">
          <template slot="button-text">Apply changes</template>
          <template slot="heading">Subscription Summary</template>
          <template slot="content">
            <h2>My Subscription Summary</h2>
            <p>
              Below is a summary of the changes you’re making to your subscription, including any costs you’ve incurred and will be charged for today.
            </p>
            <div class="subscription_summary">
              <!-- v-if the user has ADDED courses -->
              <div v-if="newSubscribingCourses.length">
                <h3>Adding Courses</h3>
                <ul class="pink_dots">
                  <li v-for="course of newSubscribingCourses" :key="course.id">
                    <p> <strong>{{course.number}} {{course.name}}</strong>
                      <br />
                      <template v-if="course.published">Published</template>
                    </p>
                    <!--- What price do we want to show for the course here? possibly have an old price vs what the new price per course is ??? -->
                    <p><strong><sup>$</sup>{{formatPrice(activeBillingRecord.pricePerCourse)}}</strong> per month</p>
                  </li>
                </ul>
              </div>
              <!-- v-if the user has REMOVED courses -->
              <div v-if="removedSubscribedCourses.length">
                <h3>Removing Courses</h3>
                <ul class="pink_dots">
                  <li v-for="course of removedSubscribedCourses" :key="course.id">
                    <p><strong>{{course.number}} {{course.name}}</strong>
                      <br />
                      <template v-if="course.published">Published</template>
                    </p>
                    <!--- What price do we want to show for the course here? possibly have an old price vs what the new price per course is ??? -->
                    <p class="removed">
                      &ndash;
                      <sup>$</sup>{{formatPrice(activeBillingRecord.pricePerCourse)}}
                      per month
                    </p>
                  </li>
                </ul>
              </div>

              <div>
                  <h3>Continuing Courses</h3>
                  <ul class="pink_dots" >
                    <li v-for="course of remainingSubscribedCourses" :key ="course.id">
                      <p>
                        <strong> {{course.number}} {{course.name}} </strong>
                        <br />
                        <template v-if="course.published">Published</template>
                      </p>
                      <p>
                        <strong><sup>$</sup>{{ formatPrice(activeBillingRecord.pricePerCourse) }} </strong>
                        per month
                      </p>
                    </li>
                  </ul>
              </div>
              <div v-if="newCost > 0">
                <h3>Selected Payment Method</h3>
                <p>
                  Visa **** **** **** 4242 (expires 04/2024)
                </p>
              </div>
              <div class="total">
                <div>
                  <h3 class="teal_text">Today’s payment total</h3>
                </div>
                <div class="today">
                  <h3><span class="lining_figures"><sup>$</sup>{{ newCost }}</span></h3>
                </div>
              </div>
              <div class="total">
                <div>
                  <h3>Monthly bill total</h3>
                  <p>
                    You will be billed this amount on the X of every month
                  </p>
                </div>
                <div>
                  <h3><span class="lining_figures"><sup>$</sup>{{totalCost}}</span></h3>
                </div>
              </div>
            </div>
            <button type="button" class="action" @click="updateSubscription()">Submit</button>
          </template>
        </buttonModal>
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
    stripeSk: String,
  },
  computed: {
    activeBillingRecord(){
      let selectedCourseCount = this.selectedSubscribedCourses.length
      for (let billingScheme of this.billingSchemeTiers) {
        if (billingScheme.minCourses <= selectedCourseCount && selectedCourseCount <= billingScheme.maxCourses) {
          return billingScheme
        }
      }
      return null
    },
    originalCost(){
      return this.totalCost - this.newCost;
    },
    totalCost(){
      return this.activeBillingRecord ? this.activeBillingRecord.pricePerCourse * this.selectedSubscribedCourses.length : 0;
    },
    newCost(){
      return this.activeBillingRecord ? this.activeBillingRecord.pricePerCourse * this.newSubscribingCourses.length - this.subtractedCost : 0;
    },
    subtractedCost(){
      let originalCourseCount = this.previouslySubscribedCourses.length;
      let currentSubscriptionCount = this.currentSubscribedCourses.length;
      let subtractedCount = originalCourseCount - currentSubscriptionCount;
      return this.activeBillingRecord ? this.activeBillingRecord.pricePerCourse * subtractedCount : 0;
    },
    paymentNeeded(){
      return this.newCost > 0;
    },
    billingSchemeTiers(){
      return this.$store.state.allBillingSchemes
    },
    userLicense(){
      return this.$store.state.userLicense
    },
    hasLicense(){
      return !!this.userLicense;
    },
    userCourses(){
      return this.$store.getters.userCourseMemberships
    },
    selectedSubscribedCourses() {
      return this.userCourses.filter(course =>
          this.currentSubscribedCourses.includes(course) || this.newSubscribingCourses.includes(course)
        );
    },
    newSubscribingCourses() {
      return this.$store.state.newSubscribingCourses;
    },
    currentSubscribedCourses(){
      return this.$store.state.currentSubscribedCourses;
    },
    previouslySubscribedCourses(){
      return this.$store.state.previouslySubscribedCourses;
    },
    remainingSubscribedCourses(){
      return this.selectedSubscribedCourses.filter(course =>
        this.newSubscribingCourses.indexOf(course) === -1 )
    },
    removedSubscribedCourses(){
      return this.$store.getters.removedSubscribedCourses;
    },
    userSubscription(){
      return this.$store.state.userSubscription;
    }
  },
  methods: {
    toggleRenew() {
      this.showRenew = !this.showRenew;
    },
    removePaymentMethod(pID){
      this.$store.dispatch('removePaymentMethod', pID)
    },
    updateLicense(){
      this.$refs.buttonModal_license.toggleModalState()
    },
    updateSubscription(){
      this.$store.dispatch('updateSubscription', this.selectedSubscribedCourses)
    },
    formatPrice(price){
      return Math.floor(price);
    }
  },
  created: function() {
    this.$store.dispatch("getUserSubscription");
    this.$store.dispatch("getCourseMemberships");
    this.$store.dispatch("getAllBillingSchemes");
  },
}
```
</script>
