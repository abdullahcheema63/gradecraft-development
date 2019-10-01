<template>
  <div>
    <div>
      <h2>My Payment Information</h2>
      <div id="stripe"></div>
    </div>

    <h3>Billing Info</h3>
    <div class="flex-2 form_pair">
      <div class="form_elem">
        <input id="first_name" v-model="sourceInfo.first_name" type="text" required="required" />
        <label for="first_name">First Name</label>
      </div>
      <div class="form_elem form_pair">
        <input id="last_name" v-model="sourceInfo.last_name" type="text" required="required" />
        <label for="last_name">Last Name</label>
      </div>
    </div>
    <div class="form_elem">
      <input id="organization" v-model="sourceInfo.organization" type="text" />
      <label for="organization">Organization</label>
    </div>
    <div class="flex-2 form_pair">
      <div class="form_elem">
        <input id="addr1" v-model="sourceInfo.addr1" type="text" required="required" />
        <label for="addr1">Address Line 1</label>
      </div>
      <div class="form_elem">
        <input id="addr2" v-model="sourceInfo.addr2" type="text" />
        <label for="addr2">Address Line 2</label>
      </div>
    </div>
    <div class="flex-2 form_pair">
      <div class="form_elem">
        <input id="city" v-model="sourceInfo.city" type="text" required="required" />
        <label for="city">City</label>
      </div>
      <div class="form_elem">
        <input id="country" v-model="sourceInfo.country" type="text" required="required" />
        <label for="country">Country</label>
      </div>
    </div>
    <div class="form_elem">
      <input id="phone" v-model="sourceInfo.phone" type="number" required="required" />
      <label for="phone">Phone</label>
    </div>
    <button class="action" @click.prevent="addCard()" type="submit">+ Add Card</button>
  </div>
</template>

<script lang="coffee">
```
let stripe;
let card;

module.exports = {
  name: "licenses-payment-inputs",
  data: function() {
    return {
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
      },
      sourceInfo: {
        type: "card",
        customer_id: "",
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
    }
  },
  props: {
    stripePk: String,
    stripeSk: String,
  },
  methods: {
    addCard: async function() {
      console.log("inside add card on payments input")
      const source = await this.createSource();
      console.log("source:")
      console.log(source)
    },
    createSource: async function() {
      console.log("inside createSource after form submit plz")
      this.sourceInfo.customer_id = this.$store.state.userSubscription.customer_id
      console.log(this.sourceInfo)

      stripe.createSource(card, {
        customer: this.sourceInfo.customer_id
        },
      ).then(function(result){
        console.log("?created source?")
        console.log(result)
      });
      return this.sourceInfo
    },
    getPayment: async function() {
      console.log("inside getPayment after form submit plz")
      const {token, error} = await stripe.createToken(card);
      if (error) {
        this.errors.push(error.message);
      } else {
        console.log("inside createToken")
        this.payment.stripe_token = token.id;
      }
      return this.payment;
    },
  },
  created: function() {
    stripe = Stripe(this.stripePk);
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
