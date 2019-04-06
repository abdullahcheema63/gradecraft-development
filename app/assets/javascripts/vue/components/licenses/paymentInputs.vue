<template>
  <div>
    <div>
      <label for="first_name">First Name</label>
      <input id="first_name" v-model="payment.first_name"/>
    </div>
    <div>
      <label for="last_name">Last Name</label>
      <input id="last_name" v-model="payment.last_name" />
    </div>
    <div>
      <label for="organization">Organization</label>
      <input id="organization" v-model="payment.organization" />
    </div>
    <div>
      <label for="phone">Phone</label>
      <input id="phone" v-model="payment.phone" />
    </div>
    <div>
      <label for="addr1">Address Line 1</label>
      <input id="addr1" v-model="payment.addr1" />
    </div>
    <div>
      <label for="addr2">Address Line 2</label>
      <input id="addr2" v-model="payment.addr2" />
    </div>
    <div>
      <label for="city">City</label>
      <input id="city" v-model="payment.city" />
    </div>
    <div>
      <label for="country">Country</label>
      <input id="country" v-model="payment.country" />
    </div>
    <div>
      <label for="stripe">Credit Card</label>
      <div id="stripe" />
    </div>
  </div>
</template>

<script lang="coffee">
```
const data = {
  errors: [],
  cardError: "",
  payment: {
    first_name: "",
    last_name: "",
    organization: "",
    phone: "",
    addr1: "",
    addr2: "",
    city: "",
    country: "",
    stripe_token: "",
  }
};

let stripe;
let card;

module.exports = {
  name: "licenses-payment-inputs",
  data: function() { return data; },
  props: {
    stripePk: String,
  },
  methods: {
    getPayment: async function() {
      const {token, error} = await stripe.createToken(card);
      if (error) {
        this.errors.push(error.message);
      } else {
        this.payment.stripe_token = token.id;
      }
      return this.payment;
    },
  },
  created: function() {
    stripe = Stripe(this.stripePk);
  },
  mounted: function() {
    const self = this;
    const elements = stripe.elements();
    card = elements.create('card');
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