FactoryBot.define do
  factory :payment do
    first_name { "Delphi" }
    last_name { "Diggory" }
    organization { "Slytherin" }
    phone { "555-555-5555" }
    addr1 { "7777 DefinitelyCanon Ln." }
    city { "Los Angeles" }
    state { "CA" }
    country { "USA" }
    amount_usd { 25.0 }

    factory :payment_stripe do
      stripe_token { "Mock Token" }
    end

    factory :payment_stripe_real do
      stripe_token {
        Stripe::Token.create(
          card: {
            number: "4242424242424242",
            exp_month: 1,
            exp_year: 2020,
            cvc: "314",
          },
        ).id
      }
    end

    factory :payment_legacy do
      source { "Legacy" }
    end
  end
end