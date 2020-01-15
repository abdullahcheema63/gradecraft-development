<template>
  <div>
    <alertComponent></alertComponent>

    <subscriptions-course-selector></subscriptions-course-selector>

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

      <div class="payment_today">
        <h3>Today’s payment total:</h3>
        <h3><sup>$</sup><span class="lining_figures">{{roundCents(proratedTotal)}}</span></h3>
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
        (make sure this link gets changed to /subscriptions on the public facing pages)
      </p>
    </div>

    <subscriptions-payment-card-display v-if="!userSubscription.stripe_connection_error" :stripePk="stripePk"></subscriptions-payment-card-display>
    <div v-else class="content_block bg-green_mint_2">
      <p>
        Uh oh! It looks like we can’t connect with Stripe right now. Please try again later!
      </p>
    </div>

    <div class="content_block bg-green_mint_2">
      <div class="form_options alt-2">
        <input type="checkbox" :id="termsOfService" v-model="termsOfService" :value="termsOfService" required="required" />
        <label :for="termsOfService">I accept GradeCraft’s
          <a href="https://gradecraft.com/terms_service/" target="_blank">Terms of Service</a>
        </label>
      </div>

      <buttonModal ref="checkoutSummaryModal" button_class="action" v-if="userSubscription.failed_last_payment">
        <template slot="button-text">Apply changes</template>
        <template slot="heading">Subscription Summary</template>
        <template slot="content">
          <h2>My Subscription Summary</h2>
          <p>
            Below is a summary of the changes you’re making to your subscription, including any costs you’ve incurred and will be charged for today.
          </p>
          <div class="subscription_summary">
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
            <div v-if="remainingSubscribedCourses.length">
              <h3>Courses to pay for</h3>
              <ul class="pink_dots">
                <li v-for="course of remainingSubscribedCourses" :key="course.id">
                  <p> <strong>{{course.number}} {{course.name}}</strong>
                    <br />
                    <template v-if="course.published">Published</template>
                  </p>
                  <!--- What price do we want to show for the course here? possibly have an old price vs what the new price per course is ??? -->
                  <p><strong><sup>$</sup>{{formatPrice(activeBillingRecord.pricePerCourse)}}</strong> per month</p>
                </li>
              </ul>
            </div>
            <div v-if="this.defaultPaymentMethod">
              <h3>Selected Payment Method</h3>
              <p v-if="this.defaultPaymentMethod">
                {{defaultPaymentMethod[0].nickname}}
                ({{defaultPaymentMethod[0].brand}})
                **** {{defaultPaymentMethod[0].last4}} &bull; expires {{defaultPaymentMethod[0].exp_month}}/{{defaultPaymentMethod[0].exp_year}}}
              </p>
            </div>
            <div class="total">
              <div>
                <h3 class="teal_text">Today’s payment total</h3>
              </div>
              <div class="today">
                <h3><span class="lining_figures"><sup>$</sup>{{ roundCents(proratedTotal) }}</span></h3>
                <p>
                  This amount reflects both your missed payment for courses you want to continue, as well as any courses you want to remove from your subscription.
                </p>
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
          <div v-if="remainingSubscribedCourses.length === 0" class="bg-blue_2">
            <h2> Thanks for using GradeCraft! </h2>
            <p>It looks like you’re deactivating your GradeCraft subscription. Hopefully you enjoyed our tool, and we look forward to seeing you again in the future! Go gameful!</p>
          </div>

          <button type="button" class="action" @click="retryFailedPayment()">Submit</button>
        </template>
      </buttonModal>

      <buttonModal button_class="action" v-else>
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

            <div v-if="remainingSubscribedCourses.length">
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
            <div v-if="this.defaultPaymentMethod">
              <h3>Selected Payment Method</h3>
              <p v-if="this.defaultPaymentMethod">
                {{defaultPaymentMethod[0].nickname}}
                ({{defaultPaymentMethod[0].brand}})
                **** {{defaultPaymentMethod[0].last4}} &bull; expires {{defaultPaymentMethod[0].exp_month}}/{{defaultPaymentMethod[0].exp_year}}}
              </p>
            </div>
            <div class="total">
              <div>
                <h3 class="teal_text">Today’s payment total</h3>
              </div>
              <div class="today">
                <h3><span class="lining_figures"><sup>$</sup>{{ roundCents(proratedTotal) }}</span></h3>
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
          <div v-if="!this.defaultPaymentMethod && newCost > 0">
            <p>(?Words and Stylleee) You must add a payment method before you continue with your subscription </p>
          </div>
          <button type="button" class="action" :disabled="!this.defaultPaymentMethod && newCost > 0" @click="updateSubscription()">Submit</button>
        </template>
      </buttonModal>
    </div>
  </div>
</template>

<script lang="coffee">
```
module.exports = {
  name: "subscriptions-dash",
  components: {
    "subscriptions-course-selector": () => VComponents.get("vue/components/subscriptions/courseSelector"),
    "subscriptions-payment-card-display": () => VComponents.get("vue/components/subscriptions/paymentCardDisplay"),
    alertComponent: () => VComponents.get('vue/components/structure/alertComponent'),
    modalComponent: () => VComponents.get('vue/components/structure/modalComponent'),
    buttonModal: () => VComponents.get('vue/components/structure/buttonModal'),
    dropdownDotsComponent: () => VComponents.get('vue/components/structure/dropdownDotsComponent')
  },
  data: function() {
    return {
        courses: [],
        errors: [],
        showRenew: false,
        modalState: false,
        termsOfService: false,
      };
  },
  props: {
    stripePk: String,
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
    proratedTotal(){
      var now = new Date();
      var daysInThisMonth = new Date(now.getFullYear(), now.getMonth()+1, 0).getDate();
      var remainingDaysInMonth = daysInThisMonth - now.getDate()
      if (remainingDaysInMonth === 0){ remainingDaysInMonth = 1}
      var pricePerDay = this.newCost / daysInThisMonth
      return pricePerDay * remainingDaysInMonth
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
    },
    hasErrors(){
      return !!this.errors.length
        || (this.$refs.paymentInputs && this.$refs.paymentInputs.errors.length)
        || (this.$refs.paymentInputs && this.$refs.paymentInputs.cardError);
    },
    failedPayment(){
      return this.$store.state.failedPayment
    },
    defaultPaymentMethod(){
      return this.$store.getters.defaultPaymentMethod
    },
    successAlertMessages(){
      return this.$store.state.successAlertMessages
    },
  },
  watch: {
    successAlertMessages(newMessages, oldMessages){
      if(newMessages[0]){
        this.$refs.checkoutSummaryModal.close()
        let wrapper = document.getElementById("main_wrapper")
        wrapper.classList.add("has_alert")
      }
    }
  },
  methods: {
    toggleRenew() {
      this.showRenew = !this.showRenew;
    },
    updateSubscription(){
      this.$store.dispatch('updateSubscription', this.selectedSubscribedCourses)
    },
    retryFailedPayment(){
      this.$store.dispatch('retryFailedPayment', [this.failedPayment.id, this.selectedSubscribedCourses])
    },
    formatPrice(price){
      return Math.floor(price);
    },
    roundCents(dollars){
      let cents = dollars * 100
      let roundedCents = Math.round(cents)
      return (roundedCents / 100)
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
