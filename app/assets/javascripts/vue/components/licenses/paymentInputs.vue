<template>
  <div>
    <div>
      <h2>My Payment Information</h2>
      <div id="stripe"></div>
    </div>

    <h3>Account Nickname</h3>
    <div class="form_elem">
      <input id="account_name" v-model="paymentMethodInfo.account_name" type="text" />
      <label for="account_name">Nickname for Card (Ex: Erik's Visa)</label>
    </div>

    <h3>Billing Info</h3>
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
        <input id="country" v-model="paymentMethodInfo.postal_code" type="text" required="required" />
        <label for="country">Zip Code (postal code)</label>
      </div>
    </div>
    <div class="form_elem">
      <input id="phone" v-model="paymentMethodInfo.phone" type="number" required="required" />
      <label for="phone">Phone</label>
    </div>
    <button class="action" @click.prevent="addCard()" type="submit">+ Add Card</button>
  </div>
</template>

<script lang="coffee">
```
let stripe;
var card;

module.exports = {
  name: "licenses-payment-inputs",
  data: function() {
    return {
      errors: [],
      cardError: "",
      paymentMethodInfo: {
        full_name: "",
        account_name: "",
        phone: "",
        addr1: "",
        addr2: "",
        city: "",
        postal_code: "",
        source_id: "",
      }
    }
  },
  props: {
    stripePk: String,
    stripeSk: String,
  },
  methods: {
    addCard: async function() {
      console.log("inside add card on payments input")
      const paymentMethod = await this.createSource();

      this.$store.dispatch('addCardToSubscription', paymentMethod)
    },
    createSource: async function() {
      console.log("inside createSource")
      const result = await stripe.createSource(card, { type: 'card' })
      if (result.error) {
        console.log(result)
        this.errors.push(result.error.message);
      } else {
        console.log(result)
        this.paymentMethodInfo.source_id = result.source.id
      }
      return this.paymentMethodInfo
    },
    createPaymentMethod: async function(){
      console.log("inside createPaymentMethod")
      const result = await stripe.createPaymentMethod('card', card, {
        billing_details: {
          address: {
            city: this.paymentMethodInfo.city,
            line1: this.paymentMethodInfo.addr1,
            postal_code: this.paymentMethodInfo.postal_code
          },
          phone: this.paymentMethodInfo.phone,
          name: this.paymentMethodInfo.full_name
        },
        });
      if (result.error) {
        console.log(result)
        this.errors.push(result.error.message);
      } else {
        console.log(result)
        this.paymentMethodInfo.source_id = result.paymentMethod.id
      }
      return this.paymentMethodInfo
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
        console.log("typing into card form")
      }
    });
  },
}
```
</script>
