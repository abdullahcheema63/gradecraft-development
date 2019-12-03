<template>
  <div>
    <div v-if="hasCardError" class="inline_alert_msg">
      <p>
        {{cardError}}
      </p>
    </div>
    <div v-if="hasCreditCardError" class="inline_alert_msg">
      <p>
        {{creditCardError}}
      </p>
    </div>
    <div>
      <h2>My Payment Information</h2>
      <div v-if="!editingBillingInfo" id="stripe"></div>
      <div v-else>
        <p>**** **** **** {{paymentMethodInfo.last4}} <span></span> Expires {{paymentMethodInfo.exp_month}}/{{paymentMethodInfo.exp_year}}</p>
      </div>
    </div>

    <h3>Billing Info</h3>
    <div class="form_elem">
      <input id="nickname" v-model="paymentMethodInfo.nickname" type="text" />
      <label for="nickname">Display name</label>
    </div>
    <div class="form_elem">
      <input id="full_name" v-model="paymentMethodInfo.full_name" type="text" required="required" />
      <label for="full_name">Full Name as it appears on card</label>
    </div>
    <div class="flex-2 form_pair">
      <div class="form_elem">
        <input id="addr1" v-model="paymentMethodInfo.addr1" type="text" required="required" />
        <label for="addr1">Address Line 1</label>
      </div>
      <div class="form_elem">
        <input id="addr2" v-model="paymentMethodInfo.addr2" type="text" />
        <label for="addr2">Address Line 2</label>
      </div>
    </div>
    <div class="flex-2 form_pair">
      <div class="form_elem">
        <input id="city" v-model="paymentMethodInfo.city" type="text" required="required" />
        <label for="city">City</label>
      </div>
      <div class="form_elem">
        <input id="country" v-model="paymentMethodInfo.country" type="text" required="required" />
        <label for="country">Country</label>
      </div>
    </div>
    <div class="flex-2 form_pair">
      <div class="form_elem">
        <input id="phone" v-model="paymentMethodInfo.phone" type="number" required="required" />
        <label for="phone">Phone</label>
      </div>
      <div class="form_elem">
        <input id="postal_code" v-model="paymentMethodInfo.postal_code" type="text" required="required" />
        <label for="postal_code">Zip Code (postal code)</label>
      </div>
    </div>
    <div class="form_options alt-2">
      <input id="default" v-model="paymentMethodInfo.default" type="checkbox" value="default"/>
      <label for="default">Make this my primary payment method</label>
    </div>
    <button v-if="!editingBillingInfo" class="action" :disabled="hasCardError" @click.prevent="addCard()" type="submit">+ Add Card</button>
    <button v-else class="action" :disabled="hasCardError" @click.prevent="editCardInfo()" type="submit">?words? Apply changes</button>
  </div>
</template>

<script lang="coffee">
```
let stripe;
var card;

module.exports = {
  name: "subscriptions-payment-inputs",
  data: function() {
    return {
      errors: [],
      cardError: "",
      editingBillingInfo: false,
      paymentMethodInfo: {
        full_name: "",
        nickname: "",
        phone: "",
        addr1: "",
        addr2: "",
        city: "",
        postal_code: "",
        country: "",
        payment_method_id: "",
        default: false,
        last4: null,
        exp_month: null,
        exp_year: null,
      }
    }
  },
  props: {
    stripePk: String
  },
  computed: {
    hasCardError() {
      return !!this.cardError
    },
    hasCreditCardError(){
      return !!this.creditCardError
    },
    creditCardError() {
      return this.$store.state.creditCardError
    }
  },
  methods: {
    addCard: async function() {
      console.log("inside add card on payments input")
      const paymentMethod = await this.createPaymentMethod();
      this.$store.dispatch('addCardToSubscription', paymentMethod)
    },
    createPaymentMethod: async function(){
      console.log("inside createPaymentMethod", this.paymentMethodInfo.postal_code)
      const result = await stripe.createPaymentMethod('card', card, {
        billing_details: {
          address: {
            city: this.paymentMethodInfo.city,
            line1: this.paymentMethodInfo.addr1,
            line2: this.paymentMethodInfo.addr2,
            country: this.paymentMethodInfo.country,
            postal_code: this.paymentMethodInfo.postal_code,
          },
          phone: this.paymentMethodInfo.phone,
          name: this.paymentMethodInfo.full_name,
        },
        metadata: {
          nickname: this.paymentMethodInfo.nickname
        }
      });
      if (result.error) {
        console.log(result)
        this.errors.push(result.error.message);
      } else {
        console.log(result)
        this.paymentMethodInfo.payment_method_id = result.paymentMethod.id
      }
      return this.paymentMethodInfo
    },
    editCardInfo: async function() {
      console.log("inside edit card on payments input, PM info: ", this.paymentMethodInfo)
      this.$store.dispatch('editCardInfo', this.paymentMethodInfo)
    },
    selectedCardToEdit(selectedPaymentMethod) {
      console.log("inside selectedCardToEdit")
      console.log("PM passed in the method: ", selectedPaymentMethod)
      this.editingBillingInfo = true
      this.paymentMethodInfo = selectedPaymentMethod
    },
  },
  created: function() {
    console.log("pk stripe key", this.stripePk)
    console.log("for some reason Vue or Stripe don't like it when this.stripePk is used to initate connection with stripe")
    stripe = Stripe('pk_test_P34y48VrjTGbgCrh3ry80Qec');
  },
  mounted: function() {
    var style = {
      base: {
        fontSize: '16px',
      }
    };
    const self = this;
    const elements = stripe.elements();
    card = elements.create('card', {style: style});
    card.mount("#stripe");
    card.addEventListener('change', ({error}) => {
      if (error) {
        self.cardError = error.message;
        console.error(self.cardError);
      } else {
        self.cardError = '';
      }
    });
  },
}
```
</script>
