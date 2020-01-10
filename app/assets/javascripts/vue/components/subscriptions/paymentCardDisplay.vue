<template>
  <div class="content_block bg-green_mint_2">
    <h2 class="unspace-top">My Payment Cards DISPLAY COMPONENT</h2>

    <div v-if="userSubscription.payment_methods" v-for="paymentMethod in userSubscription.payment_methods" class="form_options payment_method">
      <input type="radio" :id="paymentMethod.id" :value="paymentMethod.id" :checked="paymentMethod.default_payment_method" name="payment_group" />
      <div>
        <p>
          <strong>{{paymentMethod.nickname}}</strong>
          ({{paymentMethod.brand}})
          **** **** **** {{paymentMethod.last4}} <span></span> Expires {{paymentMethod.exp_month}}/{{paymentMethod.exp_year}}
        </p>
        <dropdownDotsComponent>
          <template slot="content">
            <ul>
              <li v-if="!paymentMethod.default_payment_method">
                <a @click="makePaymentMethodDefault(paymentMethod.id)">Make Primary</a>
              </li>
              <li>
                <a @click="openEditPaymentMethod(paymentMethod)">Edit</a>
              </li>
              <li>
                <a @click="removePaymentMethod(paymentMethod.id)">Delete</a>
              </li>
            </ul>
          </template>
        </dropdownDotsComponent>
      </div>
    </div>

    <buttonModal ref="paymentInputModal" button_class="secondary function add_something">
      <template slot="button-text">Add a new card</template>
      <template slot="heading">Add a new card</template>
      <template slot="content">
        <subscriptions-payment-inputs ref="paymentInputs" :stripePk="stripePk" />
      </template>
    </buttonModal>

    <modalComponent :modalState="modalState" @close="close()" class="component_container">
      <template slot="heading">Edit payment card</template>
      <template slot="content">
        <form>
          <subscriptions-payment-inputs ref="editPaymentInputs" :stripePk="stripePk"/>
        </form>
      </template>
      <template slot="submit-button"> </template>
    </modalComponent>

  </div>
</template>

<script lang="coffee">
```
module.exports = {
  name: "subscriptions-payment-card-display",
  components: {
    "subscriptions-payment-inputs": () => VComponents.get("vue/components/subscriptions/paymentInputs"),
    modalComponent: () => VComponents.get('vue/components/structure/modalComponent'),
    buttonModal: () => VComponents.get('vue/components/structure/buttonModal'),
    dropdownDotsComponent: () => VComponents.get('vue/components/structure/dropdownDotsComponent')
  },
  data() {
    return {
      modalState: false,
    }
  },
  props: {
    stripePk: String,
  },
  computed: {
    userSubscription(){
      return this.$store.state.userSubscription;
    },
    creditCardAddSuccess(){
      return this.$store.state.creditCardAddSuccess
    },
  },
  watch: {
    creditCardAddSuccess(newStatus, oldStatus){
      if(newStatus === true){
        this.$refs.paymentInputModal.close()
        let wrapper = document.getElementById("main_wrapper")
        wrapper.classList.add("has_alert")
      }
    },
  },
  methods: {
    openEditPaymentMethod(paymentMethod){
      console.log("editing payment method: ", paymentMethod)
      this.modalState = true
      this.$refs.editPaymentInputs.selectedCardToEdit(paymentMethod)
    },
    removePaymentMethod(pID){
      this.$store.dispatch('removePaymentMethod', pID)
    },
    makePaymentMethodDefault(pID){
      this.$store.dispatch('makePaymentMethodDefault', pID)
    },
    close() {
      this.modalState = false
    },
  }
}
```
</script>
