import { Show } from 'solid-js';

import { Dropdown } from '../../atoms';

export const ProfilePremium = (props) => (
  <Dropdown title="Premium">
    <div class="py-6 px-8">
      <div class="grid lg:grid-cols-2 gap-8">
        <div>
          <Show
            when={props.endDate && props.endTime}
            fallback={<p>You don't have active subscription.</p>}
          >
            <p>Your premium subscription ends {props.endDate} at {props.endTime} UTC</p>
          </Show>
        </div>
        <div>
          <p>Here you can see information about your active subscriptions.{ props.trialSubscriptionIsUsed ? '' : " You can activate trial subscription for 100 days without any credit card." }</p>
        </div>
      </div>
      <Show when={!props.trialSubscriptionIsUsed}>
        <a class="btn-primary btn-small mt-4" href={props.subscriptionsTrialPath}>Activate trial subscription</a>
      </Show>

      {/*DO NOT CHANGE ORDER_ID - IT CONTAINS UUID OF PAYING USER - WITHOUT IT SUBSCRIPTION WILL NOT BE CREATED*/}
      {/*DO NOT CHANGE CURRENCY AND AMOUNT - WITH INVALID DATA IN THESE FIELDS SUBSCRIPTION WILL NOT BE CREATED*/}
      <div class="grid lg:grid-cols-2 gap-8 mt-8 mb-2">
        <div id="crypto">
          <vue-widget
            shop_id="eRba0IjxBVaqvZUG"
            api_key="eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1dWlkIjoiTVRnME5qTT0iLCJ0eXBlIjoicHJvamVjdCIsInYiOiIyOGEzYjIwNDc3MWY5MTA1YmJiYjZjMjI1NzVjYThiYTM3ZDM1NjJmYjAzNzdlYTAxNGE5NDdlZmFjM2U0Yzc2IiwiZXhwIjo4ODEwNTgzMDA2MH0.Z9ZOPkzYYJ7heK078a7CzXanyZy77CqXWr_j7uUBdig"
            background="#fff"
            color="#000"
            border_color="#000"
            logo="color"
            width="300px"
            currency="EUR"
            amount="25"
            text_btn="Pay for regular 30 days"
            order_id={props.cryptocloudOrderIds.regular30}
          />
          <div class="my-2">
            <vue-widget
              shop_id="eRba0IjxBVaqvZUG"
              api_key="eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1dWlkIjoiTVRnME5qTT0iLCJ0eXBlIjoicHJvamVjdCIsInYiOiIyOGEzYjIwNDc3MWY5MTA1YmJiYjZjMjI1NzVjYThiYTM3ZDM1NjJmYjAzNzdlYTAxNGE5NDdlZmFjM2U0Yzc2IiwiZXhwIjo4ODEwNTgzMDA2MH0.Z9ZOPkzYYJ7heK078a7CzXanyZy77CqXWr_j7uUBdig"
              background="#fff"
              color="#000"
              border_color="#000"
              logo="color"
              width="300px"
              currency="EUR"
              amount="250"
              text_btn="Pay for regular 365 days"
              order_id={props.cryptocloudOrderIds.regular365}
            />
          </div>
          <vue-widget
            shop_id="eRba0IjxBVaqvZUG"
            api_key="eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1dWlkIjoiTVRnME5qTT0iLCJ0eXBlIjoicHJvamVjdCIsInYiOiIyOGEzYjIwNDc3MWY5MTA1YmJiYjZjMjI1NzVjYThiYTM3ZDM1NjJmYjAzNzdlYTAxNGE5NDdlZmFjM2U0Yzc2IiwiZXhwIjo4ODEwNTgzMDA2MH0.Z9ZOPkzYYJ7heK078a7CzXanyZy77CqXWr_j7uUBdig"
            background="#fff"
            color="#000"
            border_color="#000"
            logo="color"
            width="300px"
            currency="EUR"
            amount="50"
            text_btn="Pay for unlimited 30 days"
            order_id={props.cryptocloudOrderIds.unlimited30}
          />
          <div class="mt-2">
            <vue-widget
              shop_id="eRba0IjxBVaqvZUG"
              api_key="eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1dWlkIjoiTVRnME5qTT0iLCJ0eXBlIjoicHJvamVjdCIsInYiOiIyOGEzYjIwNDc3MWY5MTA1YmJiYjZjMjI1NzVjYThiYTM3ZDM1NjJmYjAzNzdlYTAxNGE5NDdlZmFjM2U0Yzc2IiwiZXhwIjo4ODEwNTgzMDA2MH0.Z9ZOPkzYYJ7heK078a7CzXanyZy77CqXWr_j7uUBdig"
              background="#fff"
              color="#000"
              border_color="#000"
              logo="color"
              width="300px"
              currency="EUR"
              amount="500"
              text_btn="Pay for unlimited 365 days"
              order_id={props.cryptocloudOrderIds.regular365}
            />
          </div>
        </div>
        <div>
          <p>Here you can pay for premium subscription with CryptoCloud service for 30 days (regular - 25 EURO, unlimited - 50 EURO) or 365 days (regular - 250 EURO, unlimited - 500 EURO) in crypto currency. Payment is non-refundable. If you have any questions about payment - please use feedback form.</p>
        </div>
      </div>
    </div>
  </Dropdown>
)

