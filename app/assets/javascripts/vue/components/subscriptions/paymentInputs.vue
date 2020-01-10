<template>
  <div>
    <div v-if="hasCardError" class="inline_alert_msg" id="paymentCardError">
      <p>
        {{cardError}}
      </p>
    </div>
    <div v-if="hasCreditCardError" class="inline_alert_msg">
      <p>
        {{creditCardError}}
      </p>
    </div>
    <div v-if="errors.length" class="inline_alert_msg" id="genericPaymentError">
      <div v-for="error in errors">
        <p>
          {{error}}
        </p>
      </div>
    </div>
    <div>
      <h2>My Payment Information</h2>
      <div v-if="!editingBillingInfo" id="stripe"></div>
      <div v-else>
        <h3 class="pink_text">
          ({{paymentMethodInfo.brand}})
          **** **** **** {{paymentMethodInfo.last4}} &bull;
          Expires {{paymentMethodInfo.exp_month}}/{{paymentMethodInfo.exp_year}}
        </h3>
        <br />
      </div>
    </div>

    <h3>Billing Info</h3>
    <div class="form_elem">
      <input id="full_name" v-model="paymentMethodInfo.full_name" type="text" required="required" placeholder="Your full name, as it appears on the card" />
      <label for="full_name">Cardholder name</label>
    </div>
    <div class="flex-2 form_pair">
      <div class="form_elem">
        <input id="addr1" v-model="paymentMethodInfo.addr1" type="text" required="required" placeholder="Address, line 1" />
        <label for="addr1">Address Line 1</label>
      </div>
      <div class="form_elem">
        <input id="addr2" v-model="paymentMethodInfo.addr2" type="text" placeholder="Address, line 2" />
        <label for="addr2">Address Line 2</label>
      </div>
    </div>
    <div class="flex-2 form_pair">
      <div class="form_elem">
        <input id="city" v-model="paymentMethodInfo.city" type="text" required="required" placeholder="City" />
        <label for="city">City</label>
      </div>
      <div class="form_elem">
        <input id="country" v-model="paymentMethodInfo.country" type="text" required="required" placeholder="Country" />
        <label for="country">Country</label>
      </div>
    </div>
    <div class="flex-2 form_pair">
      <div class="form_elem">
        <input id="phone" v-model="paymentMethodInfo.phone" type="number" required="required" placeholder="Phone number" />
        <label for="phone">Phone</label>
      </div>
      <div class="form_elem">
        <input id="postal_code" v-model="paymentMethodInfo.postal_code" type="text" required="required" placeholder="ZIP code (postal code)" />
        <label for="postal_code">Zip Code</label>
      </div>
    </div>
    <br />
    <h3>Card Nickname</h3>
    <p>You can give this card an optional nickname as a reference for your own use. This can be beneficial if you have multiple payment cards.</p>
    <div class="form_elem">
      <input id="nickname" v-model="paymentMethodInfo.nickname" type="text" placeholder="Choose an (optional) nickname" />
      <label for="nickname">Card nickname</label>
    </div>

    <div v-if="!editingBillingInfo" class="form_options alt-2" >
      <input id="default" v-model="paymentMethodInfo.default_payment_method" type="checkbox"/>
      <label for="default">Make this my primary payment card</label>
    </div>

    <div v-else class="form_options alt-2">
      <input id="edit_default" v-model="paymentMethodInfo.default_payment_method" type="checkbox"/>
      <label for="edit_default">Make this my primary payment card</label>
    </div>

    <button v-if="!editingBillingInfo" class="action add_something" :disabled="hasCardError" @click.prevent="addCard()" type="submit">Add card</button>
    <button v-else class="action" :disabled="hasCardError" @click.prevent="editCardInfo()" type="submit">Save</button>
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
        default_payment_method: null,
        last4: null,
        exp_month: null,
        exp_year: null,
      },
      options: {
        easing: 'ease-in',
      },
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
  watch: {
    errors(newError, oldError){
      console.log("I'M TRYING TO SCROLL BUT ITS HARD IN HERE ): come find meee")
      this.$scrollTo("#genericPaymentError", 300, this.options)
    },
    cardError(newCardError, oldCardError){
      console.log("I'M TRYING TO SCROLL BUT ITS HARD IN HERE ): come find meee")
      this.$scrollTo("#paymentCardError", 300, this.options)
    },
    creditCardError(newCreditCardError, oldCreditCardError){
      console.log("I'M TRYING TO SCROLL BUT ITS HARD IN HERE ): come find meee")
      this.$scrollTo("#paymentCardError", 300, this.options)
    }
  },
  methods: {
    addCard: async function() {
      console.log("inside add card on payments input")
      if (this.checkRequiredInput() === true) {
        const paymentMethod = await this.createPaymentMethod();
        this.$store.dispatch('addCardToSubscription', paymentMethod)
      }
    },
    createPaymentMethod: async function(){
      console.log("inside createPaymentMethod")
      this.errors = []
      const paymentMethodInfo = Object.assign({}, this.paymentMethodInfo)
      let nickname = (this.paymentMethodInfo.nickname == "") ? null : this.paymentMethodInfo.nickname
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
          nickname: nickname
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
      if (this.checkRequiredInput() === true) {
        this.$store.dispatch('editCardInfo', this.paymentMethodInfo)
        document.body.style.cursor = "wait"
      }
    },
    selectedCardToEdit(selectedPaymentMethod) {
      console.log("inside selectedCardToEdit")
      console.log("PM passed in the method: ", selectedPaymentMethod)
      this.editingBillingInfo = true
      this.paymentMethodInfo = selectedPaymentMethod
    },
    checkRequiredInput(){
      pm = this.paymentMethodInfo
      if (pm.full_name && pm.phone && pm.addr1 && pm.city && pm.postal_code && pm.country ){
        return true
      }
      else {
        this.errors = ["?words? -- Please enter all the required fields"]
      }
    }
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
